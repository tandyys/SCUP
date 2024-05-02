//
//  SCUPApp.swift
//  SCUP
//
//  Created by tandyys on 23/04/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UIKit
import Replicate

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SCUPApp: App {
    let container : ModelContainer = {
        let schema = Schema([SketchModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: config)
        
        return container
    }()
    
    let client = Replicate.Client(token: ProcessInfo.processInfo.environment["REPLICATE_API_KEY"] ?? "")
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                MenuView()
                    .onAppear {
                        let appearance = UINavigationBarAppearance()
                        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
                        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear] // Hide the "Back" text
                        UINavigationBar.appearance().standardAppearance = appearance
                    }
            }
            .navigationViewStyle(.stack)
        }
        .modelContainer(container)
    }
}
