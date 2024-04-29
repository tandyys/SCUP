//
//  AppDelegate.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 29/04/24.
//

import Foundation
import FirebaseCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
