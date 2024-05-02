//
//  GalleryView.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 30/04/24.
//

import SwiftUI
import SwiftData
import UIKit

private enum AlertType {
    case isDownloadSketch, isDownloadResult
}

struct GalleryView: View {
    @State private var animateGradient: Bool = false
    @State var hasScrolled = false
    var showsIndicator: ScrollIndicatorVisibility = .hidden
    var showPagingControl: Bool = true
    var pagingControlSpacing: CGFloat = 20
    var spacing : CGFloat = 10
    var titleScrollSpeed : CGFloat = 0.6
    @State private var opacity : Double = 0.4
    
    @State private var trigger : Bool = false
    
    @State private var showPopover : Bool = false
    @State private var showOutputView : Bool = false
    
    @State private var sketchToReimagine : SketchModel?
    
    @Query var sketches : [SketchModel]
    @Environment(\.modelContext) var context
    
    @State private var scrollPos: SketchModel.ID?
    
    @State private var activeAlert = false
    @State private var alertId : AlertType = .isDownloadResult
    
    @State private var downloadedSketch : UIImage?
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: spacing) {
                        ForEach(sketches.reversed()) { sketch in
                            VStack {
                                //                                if sketch.sketchURL != "" {
                                ImageView(url: sketch.sketchURL, url2: sketch.resultURL)
                                //                                } else {
                                //                                    ImageView(url: sketch.sketchURL)
                                //                                }
                                    .frame(width: 512, height: 512)
                                    .cornerRadius(15)
                                    .hoverEffect(.lift)
                                    .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 10)
                                    .shadow(color: Color(white: 0, opacity: 0.25), radius: 40)
                                    .scrollTransition(topLeading: .interactive, bottomTrailing: .interactive, axis: .horizontal) { effect, phase in
                                        effect
                                            .scaleEffect(1 - abs(phase.value))
                                            .opacity(1 - abs(phase.value))
                                            .rotation3DEffect(.degrees(1 * phase.value * 90), axis: (x: 0, y: 2, z: 0.4))
                                    }
                                
                                    .onTapGesture(count: 1) {
                                        showPopover.toggle()
                                        print(showPopover)
                                        print("+==== Current Sketch: ===+")
                                        print("id:", self.scrollPos ?? "-1")
                                        if let match = sketches.first(where: { $0.id == scrollPos }) {
                                            print(match.persistentModelID)
                                        }
                                        else {
                                            print("NOT FOUND!!")
                                        }
                                    }
                                
                                //
                                
                                HStack(spacing: 30) {
                                    Button {
                                        activeAlert.toggle()
                                        alertId = .isDownloadSketch
                                        
                                    }
                                label: {
                                    Image("DownloadImage")
                                        .resizable()
                                        .frame(width: 52, height: 52)
                                        .padding(16)
                                        .background(Color.white)
                                        .foregroundColor(.primary)
                                        .cornerRadius(20)
                                        .shadow(radius: 8)
                                    
                                }
                                    Button {
                                        showOutputView.toggle()
                                        print(showOutputView)
                                        
                                        if let match = sketches.first(where: { $0.id == scrollPos }) {
                                            sketchToReimagine = match
                                        } else {
                                            print("Not found!")
                                        }
                                        
                                    }
                                label: {
                                    Image("ReReimaging")
                                        .resizable()
                                        .frame(width: 52, height: 52)
                                        .padding(16)
                                        .background(Color.white)
                                        .foregroundColor(.primary)
                                        .cornerRadius(20)
                                        .shadow(radius: 8)
                                    
                                }
                                    Button {
                                        activeAlert.toggle()
                                        alertId = .isDownloadResult
                                    }
                                label: {
                                    Image("DonwloadReimaging")
                                        .resizable()
                                        .frame(width: 52, height: 52)
                                        .padding(16)
                                        .background(Color.white)
                                        .foregroundColor(.primary)
                                        .cornerRadius(20)
                                        .shadow(radius: 8)
                                }
                                }
                                .padding(.top, 60)
                                .scrollTransition(topLeading: .interactive, bottomTrailing: .interactive, axis: .horizontal) { effect, phase in
                                    effect
                                        .scaleEffect(1 - abs(phase.value))
                                        .opacity(1 - abs(phase.value))
                                        .rotation3DEffect(.degrees(1 * phase.value * 90), axis: (x: 0, y: 2, z: 0.4))
                                }
                            }
                        }
                        
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollPos, anchor: .center)
                .scrollIndicators(showsIndicator)
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
            .background(
                Image("AdditionalBackground")
                    .resizable()
                    .frame(width: 1500, height: 1500)
                    .opacity(0.5)
            )
//            .safeAreaPadding([.horizontal, .top], 50)
            
            if showOutputView {
                OutputView(sketch: sketchToReimagine!)
                    .transition(.slide)
            }
        }
//        .opacity(0.2)
        .background {
            LinearGradient(colors: [.init(hex: "#f5888e", colorOpacity: 0.4), .init(hex: "#fad5a7", colorOpacity: 0.4), .init(hex: "#93b5a7", colorOpacity: 0.4), .init(hex: "#93a0cb", colorOpacity: 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            .hueRotation(.degrees(animateGradient ? 120 : 0))
            .onAppear{
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)){
                        animateGradient.toggle()
                    }
            }
        }
        .onAppear {
            print("GalleryView:", sketches.count)
            if sketches.count > 0 {
                scrollPos = sketches[sketches.count-1].id
            }
            sketches.forEach { sketch in
                print(sketch.id, ":", sketch.persistentModelID)
                let s = context.model(for: sketch.persistentModelID)
                print(s.id)
            }
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
            if let match = sketches.first(where: { $0.id == scrollPos }) {
                ImageSliderView(containerWidth: UIScreen.main.bounds.height, containerHeight: UIScreen.main.bounds.height, stringURL1: match.sketchURL, stringURL2: match.resultURL
                )
                .frame(alignment: .center)
            } else {
                Text("")
            }
        }
        
        .alert(isPresented: $activeAlert) {
            print(alertId)
            switch alertId {
            case .isDownloadSketch:
                if let match = sketches.first(where: { $0.id == scrollPos }) {
                    guard match.sketchURL != "" else {
                        return Alert(title: Text("Error"), message: Text("Failed to save. Please try again."), dismissButton: .default(Text("OK")))
                    }
                    
                    let url = URL(string: match.sketchURL)!
                    DispatchQueue.global().async {
                        // Fetch Image Data
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                // Create Image and Update Image View
                                self.downloadedSketch = UIImage(data: data)
                            }
                        }
                    }
                    if let imageData = self.downloadedSketch?.jpegData(compressionQuality: 1) {
                        return Alert(title: Text("Download Sketch"), message: Text("Do you want to save the sketch to your photo library?"), primaryButton: .default(Text("Save"), action: {
                            UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                        }), secondaryButton: .cancel())
                    } else {
                        return Alert(title: Text("Error"), message: Text("Failed to capture sketch. Please try again."), dismissButton: .default(Text("OK")))
                    }
                }
            case .isDownloadResult:
                if let match = sketches.first(where: { $0.id == scrollPos }) {
                    let resultURL : String = match.resultURL ?? ""
                    guard resultURL !=  "" || resultURL == nil else {
                        return Alert(title: Text("Error"), message: Text("Failed to save. Please try again."), dismissButton: .default(Text("OK")))
                    }
                    
                    
                    print("result url:", resultURL)
                    let url : URL = URL(string: resultURL)!                    
                    DispatchQueue.global().async {
                        // Fetch Image Data
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                // Create Image and Update Image View
                                self.downloadedSketch = UIImage(data: data)
                            }
                        }
                    }
                    if let imageData = self.downloadedSketch?.jpegData(compressionQuality: 1) {
                        return Alert(title: Text("Download Result"), message: Text("Do you want to save the result to your photo library?"), primaryButton: .default(Text("Save"), action: {
                            UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                        }), secondaryButton: .cancel())
                    } else {
                        return Alert(title: Text("Error"), message: Text("Failed to capture result. Please try again."), dismissButton: .default(Text("OK")))
                    }
                }
            }
            return Alert(title: Text("Error"), message: Text("Failed to capture result. Please try again."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SketchModel.self, configurations: config)
    
    let sketches = [
        SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1233239336254701669/owl.png?ex=6632f6a2&is=6631a522&hm=2b5084b017b49ccde312c7a160c0a939d5e3f132dc62180c129ea9d268f349ba&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1233239337018069052/result_colored.jpg?ex=6632f6a2&is=6631a522&hm=2f9f86565e7960f0adb2f4386d1727254a870eada4ce5ba810c991785502ed32&", generatedPrompt: "an owl"),
        SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "", generatedPrompt: "an owl"),
    ]
    
    for sketch in sketches {
        container.mainContext.insert(sketch)
        print(sketch.id)
    }
    
    return GalleryView()
        .modelContainer(container)
}
