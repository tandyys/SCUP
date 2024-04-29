//
//  SketchModel.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 29/04/24.
//

import Foundation
import SwiftData


@Model
class SketchModel: Identifiable {
    var id: String// Unique identifier
    var data: Data? // Encoded image data
    
    init(
        id: String = UUID().uuidString,
        data: Data? = nil
    ) {
        self.id = id
        self.data = data
    }
}
