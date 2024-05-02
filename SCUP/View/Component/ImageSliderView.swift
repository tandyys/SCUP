//
//  ImageSliderView.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 30/04/24.
//
import SwiftUI

struct ImageSliderView: View {

    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @State private var maskWidth: CGFloat = 0.0

    @State var startPoint: CGFloat = 0
    @State var endPoint: CGFloat = 0
    @State var yPoint: CGFloat = 0

    var sliderWidth: CGFloat = 30
    var containerWidth: CGFloat
    var containerHeight: CGFloat
    
    let stringURL1 : String
    let stringURL2 : String
    
    var body: some View {
        
        ZStack {
           // Gabisa pake imageview yang udh dibuat harus bikin baru/benerin/pake UIImage (?)
            ZStack() {
                AsyncImage(url: URL(string: stringURL1), scale: 1) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                    .frame(width: containerWidth, height: containerHeight)
                
                if stringURL2 != "" {
                    AsyncImage(url: URL(string: stringURL2), scale: 1) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: containerWidth, height: containerHeight)
                    .mask(mask)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: containerWidth, height: containerHeight)
                        Image("QuestionMark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.05)
                            .frame(width: containerWidth, height: containerHeight)
                    }
                    .mask(mask)
                }
            }
            .clipped()
            
            Slider
            
        }
        .clipped()
        .frame(width: containerWidth, height: containerHeight)
        .onAppear {
            yPoint = containerHeight/2
            location = CGPoint(x: containerWidth/2, y: yPoint)
            maskWidth = containerWidth/2
            endPoint = containerWidth
    }
}

var dragAction: some Gesture {
    DragGesture()
        .onChanged { value in
            updateDragView(point: value.location)
            updateMaskView(point: value.translation)
        }
//        .onEnded { value in
//            setInitialPosition()
//        }
}

var mask: some View {
    HStack {
        Spacer()
        Rectangle()
            .mask(Color.black)
            .frame(width: maskWidth, height: containerHeight)
    }
}

var Slider: some View {
    VStack(spacing: 0) {
        Rectangle()
            .fill(Color.white)
            .frame(width: 4)
        Image(systemName: "circle.circle.fill")
            .foregroundColor(.white)
            .frame(width: sliderWidth, height: sliderWidth)
            .font(.system(size: sliderWidth))
        Rectangle()
            .fill(Color.white)
            .frame(width: 4)
    }
    .position(location)
    .gesture(dragAction)
    .shadow(radius: 4)
}

func updateDragView(point: CGPoint) {
    let locX = point.x
    if locX > startPoint && locX < endPoint {
        self.location = CGPoint(x: point.x, y: yPoint)
    }
}

func updateMaskView(point: CGSize) {
    let width = -(point.width)
    let newWidth = ((containerWidth/2)+width)
    if newWidth > 0 {
        maskWidth = ((containerWidth/2)+width)
    } else {
        setInitialPosition()
    }
}

func setInitialPosition() {
    withAnimation {
        location = CGPoint(x: containerWidth/2, y: yPoint)
        maskWidth = containerWidth/2
    }
}
}

#Preview {
    print(UIScreen.main.bounds.height)
    return ImageSliderView(containerWidth: UIScreen.main.bounds.height, containerHeight: UIScreen.main.bounds.height, stringURL1: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", stringURL2: "")
}
