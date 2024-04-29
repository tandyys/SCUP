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
                        appearance.setBackIndicatorImage(UIImage(systemName: "house"), transitionMaskImage: UIImage(systemName: "house"))
                        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
                        UINavigationBar.appearance().standardAppearance = appearance
                    }
            }
            .navigationViewStyle(.stack)
            
        }
    }
}
