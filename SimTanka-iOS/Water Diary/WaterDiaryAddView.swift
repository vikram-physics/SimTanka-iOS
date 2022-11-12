//
//  WaterDiaryDetailView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 14/06/22.
//

import SwiftUI

struct WaterDiaryAddView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var waterDiaryModel:WaterDiaryModel
    
    @AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    
    //@Binding var diary:WaterDiary
    @State  var comments:String = "Please enter any relevent obervations "
    @State  var waterInTank:Double = 0.0
    @State private var potable = Potable.NonPotable
        
    var body: some View {
        GeometryReader { _ in
            
            VStack {
                ScrollView {
                    HStack{
                        Text("Water Diary")
                        Spacer()
                        }
                    
                    
                    VStack {
                        HStack{
                            Text("Select the amount of water in the tank")
                            Spacer()
                        }
                        HStack{
                            Slider(value: $waterInTank, in: 0...tankSizeM3).padding()
                            Spacer()
                            Text(Helper.VolumeStringFrom(volumeM3: waterInTank, volumeUnit: myTankaUnits.volumeUnit))
                            Text(myTankaUnits.volumeUnit.text)
                        }.border(Color.purple, width: 2)
                    }
                    
                    VStack {
                        HStack {
                            Text("Select the potability of water")
                            Spacer()
                        }
                         // allow user to choose
                        Picker("Potable?", selection: $potable){
                            ForEach(Potable.allCases, id:\.self){
                                Text($0.text)
                                //Text("\($0.text)").font(.caption)
                            }

                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .border(Color.purple, width: 2)
                    
                    TextEditor(text: $comments)
                       // .background(.white)
                        //.foregroundColor(.white)
                        .border(.blue, width: 1)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .frame(height: 300)
                    
                   
                }
                
                
                
                Button(action: { self.saveEnteryToCoreData()
                 }) {
                     HStack {
                         
                         Image(systemName: "square.and.arrow.down.fill")
                         
                         Text("Save new diary entry")
                     }
                 }
                 .frame(width: 300, height: 40)
                 .padding(5)
                 .background(Color.purple)
                 .foregroundColor(.white)
                 .border(Color.purple, width: 5)
               
                Spacer()
            }.padding()
                .navigationTitle(Text("Diary entery for \(Date(), style: .date)"))
                .navigationBarTitleDisplayMode(.inline)
                
            
        }
       
    }
}

extension WaterDiaryAddView {
    
    func saveEnteryToCoreData() {
        
        self.waterDiaryModel.SaveNewEntryToCD(waterInTankM3: waterInTank, potability: potable, entry: comments)
        
    }
}


struct WaterDiaryDetailView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        WaterDiaryAddView(comments: "The tank is full and water is potable")
            .environmentObject(TankaUnits())
            .environmentObject(WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext))
        
    }
} 
