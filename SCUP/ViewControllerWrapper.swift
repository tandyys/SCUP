//
//  ViewControllerWrapper.swift
//  SCUP
//
//  Created by Vincent Saranang on 24/04/24.
//

import SwiftUI

struct ViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
