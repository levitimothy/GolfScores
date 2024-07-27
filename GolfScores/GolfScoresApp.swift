//
//  GolfScoresApp.swift
//  GolfScores
//
//

import SwiftUI

@main
struct GolfScoresApp: App {
    @StateObject private var arr = MyStuff()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(arr)
        }
    }
}
