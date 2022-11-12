//
//  PrefernceView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 27/12/21.
//

import SwiftUI

struct PrefernceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    @State private var rainfallUnit = RainfallUnit.mm
    @State private var areaUnit = AreaUnit.sqFeet
    @State private var volumeUnit = VolumeUnit.cubicMeter
    @State private var demandUnit = DemandUnit.liter
    @State private var distanceUnit = DistanceUnit.km
    @State private var showAlertForDelete = false
    
    
    var body: some View {
        List{
            
            Spacer()
            // Rainfall Units
             
             Text("Rainfall: \(rainfallUnit.text)")
                 .font(.system(.title3, design: .rounded))
                 .padding(2)
                .listRowBackground(Color.green)
            
             Picker(selection: $rainfallUnit, label: Text("Rainfall Unit"), content: {
                 ForEach(RainfallUnit.allCases, id:\.self){ rainUnit in
                     Text(rainUnit.text)
                     }
             }).pickerStyle(SegmentedPickerStyle())
             .onAppear{
                 self.rainfallUnit = self.myTankaUnits.rainfallUnit
             }
             .listRowBackground(Color.blue)
            
            // Catchment Area Units
             
             Text("Cathment area: \(areaUnit.text) ")
                 .font(.system(.title3, design: .rounded))
                 .padding(2)
                .listRowBackground(Color.green)
            
             Picker(selection: $areaUnit, label: Text("Catchment Area Unit"), content: {
                 ForEach(AreaUnit.allCases, id:\.self) {
                     unitForArea in
                     Text(unitForArea.text)
                 }
             }).pickerStyle(SegmentedPickerStyle())
             .onAppear{
                 self.areaUnit = self.myTankaUnits.areaUnit
             }
             .listRowBackground(Color.blue)
            
            // Storage Tank Units
            
            Text("Storage tank: \(volumeUnit.text)")
                .font(.system(.title3, design: .rounded))
                .padding(2)
                .listRowBackground(Color.green)
            
            Picker(selection: $volumeUnit, label: Text("Storage Tank Unit"), content: {
                ForEach(VolumeUnit.allCases, id:\.self){
                    unitForVolume in
                    Text(unitForVolume.text)
                }
            }).pickerStyle(SegmentedPickerStyle())
            .onAppear{
                self.volumeUnit = self.myTankaUnits.volumeUnit
            }
            .listRowBackground(Color.blue)
            
           
            // Distance Unit
             
             Text("Distance: \(distanceUnit.text)")
                     .font(.system(.title3, design: .rounded))
                     .padding(2)
                    .listRowBackground(Color.green)
            
             Picker(selection: $distanceUnit, label: Text("Distance Unit"), content: {
                 ForEach(DistanceUnit.allCases, id:\.self){
                     unitForDistance in
                     Text(unitForDistance.text)
                 }
             }).pickerStyle(SegmentedPickerStyle())
             .onAppear{
                 self.distanceUnit = self.myTankaUnits.distanceUnit
             }
             .listRowBackground(Color.blue)
            
            //
            VStack(alignment: .leading) {
                
                // Water Budget Units
                HStack{
                    Text("Water Budget: \(demandUnit.text)")
                        .font(.system(.title3, design: .rounded))
                        .padding(2)
                    Spacer()
                }.background(.green)
                
                
                Picker(selection: $demandUnit, label: Text("Water Budget Unit"), content: {
                    ForEach(DemandUnit.allCases, id:\.self){
                        unitForDemand in
                        Text(unitForDemand.text)
                    }
                }).pickerStyle(SegmentedPickerStyle())
            }.onAppear {
                self.demandUnit = self.myTankaUnits.demandUnit
            }
            .padding()
            .listRowBackground(Color.gray)
            
        }.navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save", action: {
                saveUnits()
            }))
    }
        
    func saveUnits() {
        self.myTankaUnits.rainfallUnit = self.rainfallUnit
        self.myTankaUnits.areaUnit = self.areaUnit
        self.myTankaUnits.volumeUnit = self.volumeUnit
        self.myTankaUnits.demandUnit = self.demandUnit
        self.myTankaUnits.distanceUnit = self.distanceUnit
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct PrefernceView_Previews: PreviewProvider {
    static var previews: some View {
        PrefernceView()
            .environmentObject(TankaUnits())
    }
}
