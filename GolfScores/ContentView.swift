//
//  ContentView.swift
//  GolfScores
//
//

import SwiftUI
import SQLite3

struct ContentView: View {
    @EnvironmentObject var arr: MyStuff
    var body: some View {
        TabView{
            HomeView().tabItem{ Text("Home")}
            ScoresView().tabItem{ Text("Scores")}
        }
    }
}

struct HomeView: View{
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var arr: MyStuff
    var body: some View{
        VStack{
            let temp = arr.lowScore
            if arr.lowScore < 1 {
                Text("Best Score: No Score")
            } else {
                Text("Best Score: " + String(temp))
            }
            Text("18 Holes Played")
            Text("9 Holes Played")
            Text("Handicap")
        }.onChange(of: scenePhase) {
            newPhase in
            if newPhase == .active{
                readDatabase(items: &arr.items, lowScore: &arr.lowScore)
            } else if newPhase == .inactive{
                writeDatabase(items: &arr.items)
            }
        }

    }
}

struct ScoresView: View{
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var arr: MyStuff
    var body: some View{
        HStack{
            NavigationView{
                VStack{
                    let temp = $arr.items.isEmpty
                    if temp == true {
                        List{
                            
                        }
                        .toolbar{
                            ToolbarItem{
                                NavigationLink("Add"){
                                    NewItem(arr: self.$arr.items).navigationBarBackButtonHidden(true)
                                }.accessibilityLabel("Add")
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Scores")
                        .padding()
                    } else if temp == false {
                        List{
                            ForEach(arr.items) {
                                item in
                                    VStack{
                                        let index = arr.items.firstIndex(of: Item(score: item.score, numHoles: item.numHoles))
                                        NavigationLink(destination: EditItem(arr: self.$arr.items, index: index ?? 0, tempShort: String(item.score), tempLong: item.numHoles).navigationBarBackButtonHidden(true)){
                                            
                                            Text("Score: " + String(item.score)).font(.title3)
                                            Text(" Holes: " + item.numHoles).font(.subheadline)
                                        }
                                    }
                                
                            }
                            .onDelete(perform: {
                                indexSet in arr.items.remove(atOffsets: indexSet)
                            })
                        }
                        .toolbar{
                            ToolbarItem{
                                NavigationLink("Add"){
                                    NewItem(arr: self.$arr.items).navigationBarBackButtonHidden(true)
                                }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Scores")
                        .padding()
                    }
                    
                }
            }
        }.onChange(of: scenePhase) {
            newPhase in
            if newPhase == .active{
                readDatabase(items: &arr.items, lowScore: &arr.lowScore)
            } else if newPhase == .inactive{
                writeDatabase(items: &arr.items)
            }
        }
    }
}

struct EditItem: View{
    @Environment(\.dismiss) var dismiss
    @Binding var arr: [Item]
    @State var index: Int
    @State var tempShort: String
    @State var tempLong: String
    
    var body: some View{
        VStack{
            HStack{
                Text("Score: ")
                TextField(String(arr[index].score), text: $tempLong)
                    .accessibilityLabel("editScore")
                    .accessibilityValue(tempShort)
            }.padding()
            HStack{
                Text("Number of holes: ")
                TextField(arr[index].numHoles, text: $tempLong)
                    .accessibilityLabel("editNumHoles")
                    .accessibilityValue(tempLong)
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Save"){
                    arr[index + 1] = (Item(score: Int(tempShort)!, numHoles: tempLong))
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Edit Score")
        .padding()
    }
}

struct NewItem: View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var temp: MyStuff
    @Binding var arr: [Item]
    @State var temp1: String = ""
    @State var temp2: String = ""
    
    var body: some View{
        VStack{
            HStack{
                Text("Score: ")
                TextField("", text: $temp1).accessibilityLabel("addScore")
            }.padding()
            HStack{
                Text("Number of Holes: ")
                TextField("", text: $temp2).accessibilityLabel("addNumHoles")
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Save"){
                    arr.append(Item(score: Int(temp1)!, numHoles: temp2))
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Add New Score")
        .padding()
    }
}

struct DismissView: View{
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        Button("Cancel"){
            dismiss()
        }
    }
}

func readDatabase(items: inout [Item], lowScore: inout Int){
    @EnvironmentObject var temp: MyStuff
    items.removeAll()
    
    var db: OpaquePointer?
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scores.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    
    let createTableQuery = "CREATE TABLE IF NOT EXISTS Scores (id INTEGER PRIMARY KEY AUTOINCREMENT, score INTEGER, numHoles VARCHAR)"
    
    if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    let selectQuery = "SELECT * FROM Scores"
    
    var stmt: OpaquePointer?
    
    if sqlite3_prepare(db, selectQuery, -1, &stmt, nil) != SQLITE_OK{
        print("Error")
        return
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW){
        let sDesc = sqlite3_column_int(stmt, 1)
        let lDesc = String(cString: sqlite3_column_text(stmt, 2))
        
        if Int(sDesc) < lowScore {
            //temp.lowScore = Int(sDesc)
            lowScore = Int(sDesc)
        } else if lowScore == 0 {
//            temp.lowScore = Int(sDesc)
            lowScore = Int(sDesc)
        }
//        else {
////            temp.lowScore = 100
//            lowScore = 1000
//        }
        
        items.append(Item( score: Int(sDesc), numHoles: String(lDesc)))
    }
    
    let selectQuery2 = "SELECT MIN(score) FROM Scores;"

    var stmt2: OpaquePointer?

    if sqlite3_prepare(db, selectQuery2, -1, &stmt2, nil) != SQLITE_OK{
        print("Error")
        return
    }

    
    
}

func writeDatabase(items: inout [Item]){
    var db: OpaquePointer?
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scores.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    let deleteQuery = "Delete FROM Scores"
    
    if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    let selectQuery = "INSERT INTO Scores (score, numHoles) VALUES (?,?)"
    
    var stmt: OpaquePointer?
    
    for item in items{
        if sqlite3_prepare(db, selectQuery, -1, &stmt, nil) != SQLITE_OK{
            print("Error1")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(item.score)) != SQLITE_OK{
            print("Error2")
        }
        
        if sqlite3_bind_text(stmt, 2, (item.numHoles as NSString).utf8String, -1, nil) != SQLITE_OK{
            print("Error3")
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Error5")
        }
    }
    sqlite3_close(db)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
