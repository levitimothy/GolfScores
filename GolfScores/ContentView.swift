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
            //temp variables for let comparison
            let temp18 = arr.lowScore18
            let temp9 = arr.lowScore9
            
            // verify if scores have been entered yet and display best scores accordingly
            if arr.lowScore18 < 1 {
                Text("Best Score for 18 Holes: No Score").padding()
            } else {
                Text("Best Score for 18 Holes: " + String(temp18)).padding()
            }
            
            // display number of 18 hole courses played
            Text("18 Holes Played: " + String(arr.num18)).padding()
            
            // verify if scores have been entered yet and display best scores accordingly
            if arr.lowScore9 < 1 {
                Text("Best Score for 9 Holes: No Score").padding()
            } else {
                Text("Best Score for 9 Holes: " + String(temp9)).padding()
            }
            // display number of 9 hole courses played
            Text("9 Holes Played: " + String(arr.num9)).padding()
            Text("Handicap: " + String(arr.handicap)).padding()
        }.onChange(of: scenePhase) {
            newPhase in
            if newPhase == .active{
                readDatabase(items: &arr.items, lowScore18: &arr.lowScore18, lowScore9: &arr.lowScore9, num18: &arr.num18, num9: &arr.num9, handicap: &arr.handicap)
            } else if newPhase == .inactive{
                writeDatabase(items: &arr.items, lowScore18: &arr.lowScore18, lowScore9: &arr.lowScore9, num18: &arr.num18, num9: &arr.num9, handicap: &arr.handicap)
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
                    // check if arr.items is empty and set display accordingly
                    let temp = $arr.items.isEmpty
                    
                    //display empy list if array is empty
                    if temp == true {
                        List{
                            
                        }
                        .toolbar{
                            ToolbarItem{
                                NavigationLink("Add"){
                                    NewScore(arr: self.$arr.items).navigationBarBackButtonHidden(true)
                                }.accessibilityLabel("Add")
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Scores")
                        .padding()
                    } else if temp == false {
                        //display list of scores from newest to oldest
                        List{
                            ForEach(arr.items) {
                                item in
                                    VStack{
                                        let index = arr.items.firstIndex(of: Item(score: item.score, numHoles: item.numHoles, courseRating: item.courseRating, slopeRating: item.slopeRating, scoreDiff: item.scoreDiff))
                                        NavigationLink(destination: EditScore(arr: self.$arr.items, index: index ?? 0, tempScore: String(item.score), tempNumHoles: item.numHoles, tempCourseRating: String(item.courseRating), tempSlopeRating: String(item.slopeRating), tempScoreDiff: String(item.scoreDiff), previousNumHoles: item.numHoles ).navigationBarBackButtonHidden(true)){
                                            
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
                                    NewScore(arr: self.$arr.items).navigationBarBackButtonHidden(true)
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
                readDatabase(items: &arr.items, lowScore18: &arr.lowScore18, lowScore9: &arr.lowScore9, num18: &arr.num18, num9: &arr.num9, handicap: &arr.handicap)
            } else if newPhase == .inactive{
                writeDatabase(items: &arr.items, lowScore18: &arr.lowScore18, lowScore9: &arr.lowScore9, num18: &arr.num18, num9: &arr.num9, handicap: &arr.handicap)
            }
        }
    }
}

struct EditScore: View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var temp: MyStuff
    @Binding var arr: [Item]
    @State var index: Int
    @State var tempScore: String
    @State var tempNumHoles: String
    @State var tempCourseRating: String
    @State var tempSlopeRating: String
    @State var tempScoreDiff: String
    @State var previousNumHoles: String
    
    var body: some View{
        
        VStack{
            // get user input for all elements
            HStack{
                Text("Score: ")
                TextField(String(arr[index].score) , text: $tempScore)
                    .accessibilityValue(tempScore)
            }.padding()
            HStack{
                Text("Number of holes: ")
                TextField(arr[index].numHoles , text: $tempNumHoles)
                    .accessibilityValue(tempNumHoles)
            }.padding()
            HStack{
                Text("Course Rating: ")
                TextField(String(arr[index].courseRating), text: $tempCourseRating)
                    .accessibilityValue(tempCourseRating)
            }.padding()
            HStack{
                Text("Slope Rating: ")
                TextField(String(arr[index].slopeRating), text: $tempSlopeRating)
                    .accessibilityValue(tempSlopeRating)
            }.padding()
            HStack{
                Text("Score Differential: ")
                TextField(String(arr[index].scoreDiff), text: $tempScoreDiff)
                    .accessibilityValue(tempScoreDiff)
                Spacer()
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Save"){
                    // verify how many holes played
                    if Int(tempNumHoles)! == 18 {
                        // if the score was previously 9 holes subtract from total
                        if Int(previousNumHoles)! == 9{
                            temp.num9 = temp.num9 - 1;
                        }
                        //add one to total of 18 holes played
                        temp.num18 = temp.num18 + 1
                        //compare to see if have a new bext score for 18 holes
                        if temp.lowScore18 > Int(tempScore)! || temp.lowScore18 == 0 {
                            temp.lowScore18 = Int(tempScore)!
                        }
                    } else if Int(tempNumHoles)! == 9 {
                        //if score was previously for 18 holes subtract from total
                        if Int(previousNumHoles)! == 18{
                            temp.num18 = temp.num18 - 1;
                        }
                        //add one to total of 9 holes played
                        temp.num9 = temp.num9 + 1
                        //compare to see if have a new best score for 9 holes
                        if temp.lowScore9 > Int(tempScore)! || temp.lowScore9 == 0 {
                            temp.lowScore9 = Int(tempScore)!
                        }
                    }
                    //recalculate differential. Also removes the ability for users to change this
                    let diff = ((Double(tempScore)! - Double(tempCourseRating)!) * 113 / Double(tempSlopeRating)!)
                    arr[index + 1] = (Item(score: Int(tempScore)!, numHoles: tempNumHoles, courseRating: Double(tempCourseRating)!, slopeRating: Int(tempSlopeRating)!, scoreDiff: diff))
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Edit Score")
        .padding()
    }
}

struct NewScore: View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var temp: MyStuff
    @Binding var arr: [Item]
    @State var tempScore: String = ""
    @State var tempNumHoles: String = ""
    @State var tempCourseRating: String = ""
    @State var tempSlopeRating: String = ""
    
    var body: some View{
        VStack{
            HStack{
                Text("Score: ")
                TextField("", text: $tempScore).accessibilityLabel("addScore")
            }.padding()
            HStack{
                Text("Number of Holes: ")
                TextField("", text: $tempNumHoles).accessibilityLabel("addNumHoles")
            }.padding()
            HStack{
                Text("Course Rating: ")
                TextField("", text: $tempCourseRating).accessibilityLabel("addCourseRating")
            }.padding()
            HStack{
                Text("Course Slope: ")
                TextField("", text: $tempSlopeRating).accessibilityLabel("addSlopeRating")
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Save"){
                    if Int(tempNumHoles)! == 18 {
                        temp.num18 = temp.num18 + 1
                        if temp.lowScore18 > Int(tempScore)! || temp.lowScore9 == 0 {
                            temp.lowScore18 = Int(tempScore)!
                        }
                    } else if Int(tempNumHoles)! == 9 {
                        temp.num9 = temp.num9 + 1
                        if temp.lowScore9 > Int(tempScore)! || temp.lowScore9 == 0 {
                            temp.lowScore9 = Int(tempScore)!
                        }
                    }
                    // calculate the score differenatial by subtracting score from course rating then multiply by 113 then divide all by the slope rating
                    let diff = ((Double(tempScore)! - Double(tempCourseRating)!) * 113 / Double(tempSlopeRating)!)
                    arr.append(Item(score: Int(tempScore)!, numHoles: tempNumHoles, courseRating: Double(tempCourseRating)!, slopeRating: Int(tempSlopeRating)!, scoreDiff: diff))
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

func readDatabase(items: inout [Item], lowScore18: inout Int, lowScore9: inout Int, num18: inout Int, num9: inout Int, handicap: inout Double){
    @EnvironmentObject var temp: MyStuff
    items.removeAll()
    lowScore18 = 0
    lowScore9 = 0
    num18 = 0
    num9 = 0
    var arrDiff = [Double]()
    handicap = 0.0
    
    var db: OpaquePointer?
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scores.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    
    //create table
    let createTableQuery = "CREATE TABLE IF NOT EXISTS Scores (id INTEGER PRIMARY KEY AUTOINCREMENT, score INTEGER, numHoles VARCHAR, courseRating DOUBLE, slopeRating INTEGER, scoreDiff DOUBLE)"
    
    if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    //query to get all elements to send to views to display information
    let selectQuery = "SELECT * FROM Scores"
    
    var stmt: OpaquePointer?
    
    if sqlite3_prepare(db, selectQuery, -1, &stmt, nil) != SQLITE_OK{
        print("Error")
        return
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW){
        //set variables to correct columns
        let score = sqlite3_column_int(stmt, 1)
        let numHoles = String(cString: sqlite3_column_text(stmt, 2))
        let course = sqlite3_column_double(stmt, 3)
        let slope = sqlite3_column_int(stmt, 4)
        let diff = sqlite3_column_double(stmt, 5)
        
        //if score is for 18 holes add one to the total of 18 holes played and compare for best score for 18 holes
        if Int(numHoles) == 18 {
            num18 = num18 + 1;
            if Int(score) < lowScore18 || lowScore18 == 0{
                lowScore18 = Int(score)
            }
        }
        //if score is for 9 holes add one to the total of 18 holes played and compare for best score for 9 holes
        if Int(numHoles) == 9{
            num9 = num9 + 1;
            if Int(score) < lowScore9 || lowScore9 == 0{
                lowScore9 = Int(score)
            }
        }
        
        //append to array for display in list
        items.append(Item( score: Int(score), numHoles: String(numHoles), courseRating: course, slopeRating: Int(slope), scoreDiff: diff))
    }
    
    //query to get the 8 smallest score differentials for handicap calculation
    let hanidcapQuery = "SELECT * FROM Scores ORDER BY scoreDiff asc LIMIT 8"
    
    var stmt2: OpaquePointer?
    
    if sqlite3_prepare(db, hanidcapQuery, -1, &stmt2, nil) != SQLITE_OK{
        print("Error")
        return
    }
    var i = 0
    //add elements to an array for later calculations
    while(sqlite3_step(stmt2) == SQLITE_ROW){
        let scoreDiff = sqlite3_column_double(stmt2, 5)
        arrDiff.append(scoreDiff)
        i = i + 1
    }
    if i <= 3 {
        //if have less then 3 scores take the smallest score differential and subtact 2
        handicap = arrDiff[0] - 2
    } else if i == 4 {
        //if have exactly 4 scores take the smallest score differential and subtact 1
        handicap = arrDiff[0] - 1
    } else if i == 5 {
        //if have exactly 5 scores take the smallest score differential
        handicap = arrDiff[0]
    } else if i == 6 {
        //if have exactly 6 scores take the average of the smallest 2 score differentials and subtact 1
        var temp1 = 0
        while(temp1 < 2){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 2) - 1
    } else if i >= 7 && i <= 8 {
        //if have between 7 and 8 scores take the average of the smallest 2 score differentials and subtact 1
        var temp1 = 0
        while(temp1 < 2){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 2) - 1
    } else if i >= 9 && i <= 11 {
        //if have between 9 and 11 scores take the average of the smallest 3 score differentials
        var temp1 = 0
        while(temp1 < 3){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 3)
    } else if i >= 12 && i <= 14 {
        //if have between 12 and 14 scores take the average of the smallest 3 score differentials
        var temp1 = 0
        while(temp1 < 3){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 3)
    } else if i >= 15 && i <= 16 {
        //if have between 15 and 16 scores take the average of the smallest 5 score differentials
        var temp1 = 0
        while(temp1 < 5){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 5)
    } else if i >= 17 && i <= 18 {
        //if have between 17 and 18 scores take the average of the smallest 6 score differentials
        var temp1 = 0
        while(temp1 < 6){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 6)
    } else if i == 19 {
        //if exactly 19 scores take the average of the smallest 7 score differentials
        var temp1 = 0
        while(temp1 < 7){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 7)
    } else if i >= 20 {
        //if have greater than 20 scores take the average of the smallest 8 score differential
        var temp1 = 0
        while(temp1 < 8){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 8)
    }
}

func writeDatabase(items: inout [Item], lowScore18: inout Int, lowScore9: inout Int, num18: inout Int, num9: inout Int, handicap: inout Double){
    var db: OpaquePointer?
    lowScore18 = 0
    lowScore9 = 0
    num18 = 0
    num9 = 0
    var arrDiff = [Double]()
    handicap = 0.0
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scores.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    let deleteQuery = "Delete FROM Scores"
    
    if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    let selectQuery = "INSERT INTO Scores (score, numHoles, courseRating, slopeRating, scoreDiff) VALUES (?,?,?,?,?)"
    
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
        
        if sqlite3_bind_double(stmt, 3, item.courseRating) != SQLITE_OK{
            print("Error2")
        }
        
        if sqlite3_bind_int(stmt, 4, Int32(item.slopeRating)) != SQLITE_OK{
            print("Error2")
        }
        
        if sqlite3_bind_double(stmt, 5, item.scoreDiff) != SQLITE_OK{
            print("Error2")
        }
        var i = 0
        if sqlite3_step(stmt) != SQLITE_DONE {
            let score = sqlite3_column_int(stmt, 1)
            let numHoles = String(cString: sqlite3_column_text(stmt, 2))
            let scoreDiff = sqlite3_column_double(stmt, 5)
            arrDiff.append(scoreDiff)
            i = i + 1
            
            if Int(numHoles) == 18 {
                num18 = num18 + 1;
                if Int(score) < lowScore18 || lowScore18 == 0{
                    lowScore18 = Int(score)
                }
            }
            if Int(numHoles) == 9{
                num9 = num9 + 1;
                if Int(score) < lowScore9 || lowScore9 == 0{
                    lowScore9 = Int(score)
                }
            }
        }
    }
    //query to get the 8 smallest score differentials for handicap calculation
    let hanidcapQuery = "SELECT * FROM Scores ORDER BY scoreDiff asc LIMIT 8"
    
    var stmt2: OpaquePointer?
    
    if sqlite3_prepare(db, hanidcapQuery, -1, &stmt2, nil) != SQLITE_OK{
        print("Error")
        return
    }
    var i = 0
    //add elements to an array for later calculations
    while(sqlite3_step(stmt2) == SQLITE_ROW){
        let scoreDiff = sqlite3_column_double(stmt2, 5)
        arrDiff.append(scoreDiff)
        i = i + 1
    }
    if i <= 3 {
        //if have less then 3 scores take the smallest score differential and subtact 2
        handicap = arrDiff[0] - 2
    } else if i == 4 {
        //if have exactly 4 scores take the smallest score differential and subtact 1
        handicap = arrDiff[0] - 1
    } else if i == 5 {
        //if have exactly 5 scores take the smallest score differential
        handicap = arrDiff[0]
    } else if i == 6 {
        //if have exactly 6 scores take the average of the smallest 2 score differentials and subtact 1
        var temp1 = 0
        while(temp1 < 2){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 2) - 1
    } else if i >= 7 && i <= 8 {
        //if have between 7 and 8 scores take the average of the smallest 2 score differentials and subtact 1
        var temp1 = 0
        while(temp1 < 2){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 2) - 1
    } else if i >= 9 && i <= 11 {
        //if have between 9 and 11 scores take the average of the smallest 3 score differentials
        var temp1 = 0
        while(temp1 < 3){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 3)
    } else if i >= 12 && i <= 14 {
        //if have between 12 and 14 scores take the average of the smallest 3 score differentials
        var temp1 = 0
        while(temp1 < 3){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 3)
    } else if i >= 15 && i <= 16 {
        //if have between 15 and 16 scores take the average of the smallest 5 score differentials
        var temp1 = 0
        while(temp1 < 5){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 5)
    } else if i >= 17 && i <= 18 {
        //if have between 17 and 18 scores take the average of the smallest 6 score differentials
        var temp1 = 0
        while(temp1 < 6){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 6)
    } else if i == 19 {
        //if exactly 19 scores take the average of the smallest 7 score differentials
        var temp1 = 0
        while(temp1 < 7){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 7)
    } else if i >= 20 {
        //if have greater than 20 scores take the average of the smallest 8 score differential
        var temp1 = 0
        while(temp1 < 8){
            handicap = handicap + arrDiff[temp1]
            temp1 = temp1 + 1
        }
        handicap = (handicap / 8)
    }
    sqlite3_close(db)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
