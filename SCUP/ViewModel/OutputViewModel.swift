//
//  OutputViewModel.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 30/04/24.
//

import Foundation
import SwiftData
import Replicate
import SwiftUI

enum ControlNet: Predictable {
    static var modelID = "rossjillian/controlnet"
    static let versionID = "795433b19458d0f4fa172a7ccf93178d2adb1cb8ab2ad6c8fdc33fdbcd49f477"

    struct Input: Codable {
        let prompt: String
        let image: String
        let structure: String
        let seed: Int
        let image_resolution: Int
    }

    typealias Output = [URL]
  }

class OutputViewModel: ObservableObject {
    @Published var resultURL : String
    @State var generatedPrompt : String
    let urlString : String
    let apiKey : String // Replace with your actual API key
    @Published var prediction: ControlNet.Prediction? = nil
    
   init(
    resultURL : String = "", generatedPrompt : String = ""
   ) {
       self.resultURL = resultURL
       self.generatedPrompt = generatedPrompt
       self.urlString = "https://api.openai.com/v1/chat/completions"
       self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
   }
    
    
    let client = Replicate.Client(token: ProcessInfo.processInfo.environment["REPLICATE_API_KEY"] ?? "")
    
    
    func generate(sketchURL: String, prompt: String) async throws {
      prediction = try await ControlNet.predict(with: client,
                                                input: .init(prompt: prompt, image: sketchURL, structure: "scribble", seed: Int.random(in: 1..<100), image_resolution: 512))
      try await prediction?.wait(with: client)
    }

    func cancel() async throws {
      try await prediction?.cancel(with: client)
    }
    
   
    func genPrompt(with sketchURL: String, completion: @escaping (String?)-> Void) {
        print("reimagine()")
        
        // Ensure the URL is valid
        guard let url = URL(string: self.urlString) else {
            print("Invalid URL")
            return
        }

        // Construct the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "What is in the image, you can tell us how it looks and what are the key points, but don't point out that it is a sketch.",
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": sketchURL
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 50
        ]

        // Serialize your request body into JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Failed to serialize JSON")
            return
        }
        print(jsonData)

        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // Create a URL session
        let session = URLSession.shared

        // Create a data task
        session.dataTask(with: request) { data, response, error in
            // Check for errors, then parse the data
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // Handle HTTP response here
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //                    print("Response data string:\n \(dataString)")
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let dictionary = json as? [String: Any],
                              let choices = dictionary["choices"] as? [[String: Any]],
                              let firstChoice = choices.first,
                              let message = firstChoice["message"] as? [String: Any],
                              let content = message["content"] as? String else {
                            print("Error: Could not parse response data")
                            return
                        }
                            let prompt = "\(content) with a Fun, not too realistic Illustration"
                        
                        DispatchQueue.main.async {
                            completion(prompt)
                        }
                        
                    } catch {
                        print("Error: Could not parse response JSON")
                    }
                }
            } else {
                if let response = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(response.statusCode)")
                }
            }
            
        }
        .resume()
    }
    
}
