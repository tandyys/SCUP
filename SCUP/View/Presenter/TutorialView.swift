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
        VideoPlayerWrapper(player: AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/scup-8674e.appspot.com/o/videos%2FTutorialVidFix.mp4?alt=media&token=1a802011-5e39-4a90-9514-4883acc70da6")!))
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    TutorialView()
}
