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
}

class MyStuff: ObservableObject {
    
    @Published var items = [Item]()
    @Published var lowScore = Int()
}

