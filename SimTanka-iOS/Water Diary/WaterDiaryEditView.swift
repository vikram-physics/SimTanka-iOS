//
//  WaterDiaryEditView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 18/06/22.
//

import SwiftUI

struct WaterDiaryEditView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @Environment(\.managedObjectContext) var dbContext
   // @EnvironmentObject var waterDiaryModel:WaterDiaryModel
    @AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    
    let diary:WaterDiary?
    let myBlue = Color(red: 0.1, green: 0.1, blue: 90)
    
    @State private var waterInTankM3:Double = 0.0
    @State private var potable:Potable = Potable.Unknown
    @State private var entry:String = ""
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text("The amount of water in the tank is")
                    Spacer()
                }
                HStack {
                    Slider(value: $waterInTankM3, in: 0...tankSizeM3).padding()
                    Spacer()
                    Text(Helper.VolumeStringFrom(volumeM3: waterInTankM3, volumeUnit: myTankaUnits.volumeUnit))
                    Text(myTankaUnits.volumeUnit.text)
                }.border(Color.black, width: 2)
            }
            
            VStack{
                HStack{
                    Text("Potability of water")
                }
                Picker("Potable?", selection: $potable) {
                    ForEach(Potable.allCases, id:\.self){
                        Text($0.text)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .border(Color.black, width: 2)
            
            TextEditor(text: $entry)
               // .background(.primary)
               // .foregroundColor(.black)
                .border(.purple, width: 1)
            
            Button(action: { self.savedEditedChanges()
             }) {
                 HStack {
                     
                     Image(systemName: "square.and.arrow.down.fill")
                     
                     Text("Save edited diary entry")
                 }
             }
             .frame(width: 300, height: 40)
             .padding(5)
             .background(Color.purple)
             .foregroundColor(.white)
             .border(Color.purple, width: 5)
           
            Spacer()
            
        }
        .navigationTitle(Text("Editing entery for \((diary!.date ?? Date()), style: .date)"))
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            waterInTankM3 = diary?.amountM3 ?? 0.0
            potable = Potable(rawValue: Int(diary!.potable)) ?? Potable.NonPotable
            entry = diary!.diaryEntry ?? ""
        }
        .background(Color.teal)
        
    }
}

extension WaterDiaryEditView {
    
    func savedEditedChanges() {
        
        // save amount of water
        diary?.amountM3 = self.waterInTankM3
        // save potability
        diary?.potable = Int16(self.potable.rawValue)
        // save diary entry
        diary?.diaryEntry = self.entry
        // save to the data base
        do {
            try self.dbContext.save()
        } catch {
            print("Error saving  edited water diary record")
        }
    }
}

struct WaterDiaryEditView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    static var diary = WaterDiary(context: persistenceController.container.viewContext)
    static var previews: some View {
        WaterDiaryEditView(diary: diary)
            .environmentObject(TankaUnits())
    }
}
