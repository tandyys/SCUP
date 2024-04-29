//
//  MenuView.swift
//  SCUP
//
//  Created by Vincent Saranang on 26/04/24.
//

import SwiftUI

struct MenuView: View {
    @State private var animateGradient: Bool = false

//    let colors = [.init(hex: "#f5888e"), .init(hex: "#fad5a7"), .init(hex: "#93b5a7"), .init(hex: "#93a0cb"), Color.red ]
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("AppIcon2")
                    .resizable()
                    .frame(width: 256, height: 256)
                    .padding(.vertical, 72)
                
                HStack(spacing: 60) {
                    //1
                    NavigationLink(destination: ContentView(),label:{
                        Image("StartScribble")
                            .resizable()
                            .frame(width: 168, height: 168)
                        }
                    )
                    
                    //2
                    NavigationLink(destination: ContentViewTest(),label:{
                        Image("AccessAlbumAssets")
                            .resizable()
                            .frame(width: 168, height: 168)
                        }
                    )
                    
                    //3
                    NavigationLink(destination: TutorialView(),label:{
                        Image("HowToUse")
                            .resizable()
                            .frame(width: 168, height: 168)
                        }
                    )
                    
                }
                    
                    Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .background(
                Image("AdditionalBackground")
                    .resizable()
                    .frame(width: 1366, height: 1366)
                    .opacity(0.5)
            )
            
        }
        .background{
            LinearGradient(colors: [.init(hex: "#f5888e"), .init(hex: "#fad5a7"), .init(hex: "#93b5a7"), .init(hex: "#93a0cb")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .hueRotation(.degrees(animateGradient ? 120 : 0))
                .onAppear{
                    withAnimation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)){
                            animateGradient.toggle()
                        }
                }
        }
    }
}

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0

        Scanner(string: cleanHexCode).scanHexInt64(&rgb)

        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
