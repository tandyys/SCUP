//
//  File.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 30/04/24.
//

import Foundation
import SwiftData

@Model
class SketchModel : Identifiable, Hashable {
    @Attribute(.unique) let id : String
    var sketchURL : String
    var resultURL : String
    var generatedPrompt : String
    
    init(
        id : String = UUID().uuidString,
        sketchURL : String = "",
        resultURL : String = "",
        generatedPrompt : String = ""
    ) {
        self.id = id
        self.sketchURL = sketchURL
        self.resultURL = resultURL
        self.generatedPrompt = generatedPrompt
    }
}
//
//var sketches = [
//    SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", generatedPrompt: "an owl"),
//    SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", generatedPrompt: "an owl"),
//    SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", generatedPrompt: "an owl"),
//    SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", generatedPrompt: "an owl"),
//    SketchModel(sketchURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234352149539061791/big_banana.jpeg?ex=66330e85&is=6631bd05&hm=e284ebabf2b943b16877ccd6755eee309ba5ec4727694133dd0aae8acdeac445&", resultURL: "https://cdn.discordapp.com/attachments/735684785438982175/1234658174116565094/out-0.png?ex=6632da07&is=66318887&hm=12adc0553613b2755bc4d8fc1fcfc618971cc213c8dc0a9636b0e00ae079dd84&", generatedPrompt: "an owl"),
//
//]
