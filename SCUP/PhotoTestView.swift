//
//  PhotoTestView.swift
//  SCUP
//
//  Created by tandyys on 25/04/24.
//

import SwiftUI

struct ViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
