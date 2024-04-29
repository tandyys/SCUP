//
//  TutorialView.swift
//  SCUP
//
//  Created by Vincent Saranang on 29/04/24.
//

import SwiftUI
import AVKit

struct VideoPlayerWrapper: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct TutorialView: View {
    var body: some View {
        VideoPlayerWrapper(player: AVPlayer(url: URL(string: "linknya taro sini")!))
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    TutorialView()
}
