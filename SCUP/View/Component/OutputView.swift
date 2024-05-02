//
//  OutputView.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 30/04/24.
//

import Foundation
import SwiftUI
import SwiftData

struct OutputView: View {
    @State var sketch : SketchModel
    let urlString = "https://api.openai.com/v1/chat/completions"
    @ObservedObject var outputViewModel = OutputViewModel()
    @State var generatingPrompt: Bool = false
    
    @State private var showPopover : Bool = false
    
    var body: some View {
        ZStack {
            if generatingPrompt {
                ZStack{
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(40)
                        .shadow(radius: 100)
                        .frame(width: UIScreen.main.bounds.height * 0.1, height: UIScreen.main.bounds.height * 0.1)
                    ProgressView()
                        .controlSize(.large)
                        .frame(width: UIScreen.main.bounds.height * 0.8, height: UIScreen.main.bounds.height * 0.8)
                }
            }
            if let pred = self.outputViewModel.prediction {
                switch pred.status {
                case .starting, .processing:
                    ZStack{
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                            .frame(width: UIScreen.main.bounds.height * 0.1, height: UIScreen.main.bounds.height * 0.1)
                        ProgressView()
                            .controlSize(.large)
                            .frame(width: UIScreen.main.bounds.height * 0.8, height: UIScreen.main.bounds.height * 0.8)
                    }.onAppear {
                        generatingPrompt = false
                    }
                case .succeeded:
                    if let url = self.outputViewModel.prediction?.output?.first {
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: UIScreen.main.bounds.height * 0.95, height: UIScreen.main.bounds.height * 0.95)
                                .onAppear {
                                    showPopover.toggle()
                                    sketch.resultURL = url.absoluteString
                                    print(sketch.resultURL)
                                }
                        }
                    }
                case .failed:
                    Text("")
                case .canceled:
                    Text("")
                }
            }
        }
        .background(Color.clear.edgesIgnoringSafeArea(.all))
        .scaledToFill()
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .task {
            print(sketch.sketchURL)
            generatingPrompt = true
            outputViewModel.genPrompt(with: sketch.sketchURL) { prompt in
                print(prompt ?? "?")
                Task {
                    do {
                        try await outputViewModel.generate(sketchURL: sketch.sketchURL, prompt: prompt ?? "")
                    } catch {
                        print("Err: \(error)")
                    }
                }
            }
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
            ImageSliderView(containerWidth: UIScreen.main.bounds.height, containerHeight: UIScreen.main.bounds.height, stringURL1: sketch.sketchURL, stringURL2: sketch.resultURL
            )
            .frame(alignment: .center)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SketchModel.self, configurations: config)
    
    let sketch = SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=6633b745&is=663265c5&hm=93ace225126939da830a861b50e9cff1cddbfbc7945f876d7511d2c432f7be67&", resultURL: "", generatedPrompt: "")
    
    return OutputView(sketch: sketch)
        .modelContainer(container)
}
