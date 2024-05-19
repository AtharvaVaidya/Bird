//
//  Item.swift
//  BirdSampleApp
//
//  Created by Atharva Vaidya on 19/05/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
