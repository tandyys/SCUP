//
//  SCUPApp.swift
//  SCUP
//
//  Created by tandyys on 23/04/24.
//

import SwiftUI

@main
struct SCUPApp: App {
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
    }
}
