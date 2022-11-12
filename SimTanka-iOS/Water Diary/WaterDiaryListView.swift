//
//  WaterDiaryListView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//

import SwiftUI

struct WaterDiaryListView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var waterDiaryModel:WaterDiaryModel
    
    var body: some View {
        
       // Text("Under construction")
    
            
            // create a list view of diary entries
        
     /*   List{
            ForEach(waterDiaryModel.waterDiaryArray) { diary in
                WaterDiaryRowView(date: diary.date!, amountOfWater: diary.amountM3, potable: Potable(rawValue: Int(diary.potable))!, comments: diary.diaryEntry!)
            }
        } */
        
            VStack {
                List(waterDiaryModel.waterDiaryArray) { diary in
                    NavigationLink(destination: WaterDiaryEditView(diary: diary), label: {
                        WaterDiaryRowView(date: diary.date!, amountOfWater: diary.amountM3, potable: Potable(rawValue: Int(diary.potable))!, comments: diary.diaryEntry!)
                    })
                    
                    
                }.frame(height:500)
                
                // create a button for adding new entry
                Spacer()
                if waterDiaryModel.AddWaterDiaryEntry() {
                    Button(action: {
                     }) {
                         NavigationLink(destination: WaterDiaryAddView()) {
                             HStack {
                                 //Spacer()
                                 Image(systemName: "note.text.badge.plus")
                                 //Spacer()
                                 Text("Add new diary entry")
                             }
                         }
                     }
                     .frame(width: 300, height: 40)
                     .padding(5)
                     .background(Color.purple)
                     .foregroundColor(.white)
                     .border(Color.purple, width: 5)
                }
               
                Spacer()
                
            }.navigationTitle(Text("Water Diary"))
            .navigationBarTitleDisplayMode(.inline)
        
    }
       
    }


extension WaterDiaryListView {
    func AddEditNewDiaryEntry() {
        // check if there is already an entry for today
        // if yes
        //          show that entry in detailed view
        // if no
        //      show an empty entry with today's date in detailed view
    }
}

struct WaterDiaryListView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    static var previews: some View {
        WaterDiaryListView()
            .environmentObject(TankaUnits())
            .environmentObject(WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
