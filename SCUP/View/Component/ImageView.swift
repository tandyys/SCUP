//
//  ImageView.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 29/04/24.
//

import SwiftUI

struct ImageView: View {
    @State var imageURL : String
    @State var imageURL2 : String
    
    
    init(url: String, url2: String = "") {
        self.imageURL = url
        self.imageURL2 = url2
    }
    
    
    var body: some View {
        if imageURL2 == "" {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 512, height: 512)
        } else {
            HStack(spacing: 0) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                    .scaledToFill()
                    .frame(width: 256, height: 512)
                    .clipped()
                AsyncImage(url: URL(string: imageURL2)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                    .scaledToFill()
                    .frame(width: 256, height: 512)
                    .clipped()
            }
            .padding(0)
        }
    }
}

#Preview {
    ImageView(url: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", url2: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&")
}
