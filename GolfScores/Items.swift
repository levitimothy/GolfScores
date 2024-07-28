//
//  Items.swift
//  GolfScores
//
//

import Foundation
import SwiftUI

struct Item: Identifiable, Hashable{
    var id = UUID()
    var score: Int
    var numHoles: String
    var courseRating: Double
    var slopeRating: Int
    var scoreDiff: Double
}

class MyStuff: ObservableObject {
    
    @Published var items = [Item]()
    @Published var lowScore18 = Int()
    @Published var lowScore9 = Int()
    @Published var num18 = 0
    @Published var num9 = 0
    @Published var handicap = 0.0
}

