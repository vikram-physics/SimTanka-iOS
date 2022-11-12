//
//  WaterBudgetView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 26/01/22.
//
// For displaying and editing daily water demand for each month


import SwiftUI

struct WaterBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject  var  waterBudget:WaterBudgetModel
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    // Core Data
    
    // Core data fetch requests
    @Environment(\.managedObjectContext) var dbContext
    @FetchRequest(entity: WaterDemand.entity(), sortDescriptors: []) var dailyDemandCoreData:FetchedResults<WaterDemand>
    
    
    let myBlue = Color(red: 0.1, green: 0.1, blue: 90)
    let myGray = Color(red: 30, green: 0, blue: 100)
    let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
    
    // for showing detailed view
    @State private var selcetedMonth: Int = 0
    @State private var showSheet = false
    
   
    
    
    var body: some View {
        
       
       
        List{
            HStack{
                Text("Tap to enter daily water demand for the given month")
                Spacer()
            }.font(.title2)
                .foregroundColor(.black)
                .padding(4)
                .listRowBackground(Color.gray)

            ForEach(waterBudget.demandStringArray.indices, id: \.self) { month in
                
                HStack{
                    Text(Helper.intMonthToShortString(monthInt: month + 1))
                    Spacer()
                   // Text("\(waterBudget.demandArrayInM3[month], specifier: "%.f")")
                    Text(waterBudget.demandStringArray[month])
                    Text(myTankaUnits.volumeUnit.text)
                }.frame(height:20)
                    .foregroundColor(.white)
                    .listRowBackground((month % 2 == 0 ? Color.purple : skyBlue))
                    .onTapGesture {
                        self.selcetedMonth = month
                        self.showSheet = true
                    }
                
            }
           
        }.navigationBarTitle(Text("Water Budget"),displayMode: .automatic)
            .navigationBarItems(trailing: Button("Save", action: {
                self.waterBudget.SaveWaterBudget(demandUnit: myTankaUnits.volumeUnit)
                self.presentationMode.wrappedValue.dismiss()
            }))
        .listStyle(PlainListStyle())
        .sheet(isPresented: $showSheet) {
                
                WaterBudgetRowView(month: self.$selcetedMonth, dailyWater: self.$waterBudget.demandStringArray[self.selcetedMonth])
                
        }
        .environment(\.defaultMinListRowHeight, 30)
        .onAppear {
            waterBudget.WaterBudgetInUnits(demandUnit: myTankaUnits.volumeUnit)
        }
        .onDisappear{
            self.waterBudget.SaveWaterBudget(demandUnit: myTankaUnits.volumeUnit)
        } 
        
    }
}

extension WaterBudgetView {
    
     func createDemandArray() -> [String] {
        
        var demandArrayForDisplay = waterBudget.demandArrayInM3
        
        // convert the array elements from m3 to the user units
        
        // find the converstion factor
        var convertFactor = 0.0 
        switch self.myTankaUnits.volumeUnit.rawValue {
        case 0: convertFactor = 1000.0 // liters Convert from m3 to liters
        case 1: convertFactor = 1     // m3 -> m3
        case 2: convertFactor = 264.172052 // m3 -> gallon
        default:
            convertFactor = 1.0
        }
        
        demandArrayForDisplay = demandArrayForDisplay.map {$0 * convertFactor}
        
        return demandArrayForDisplay.map { String($0)}
    }
}

struct WaterBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        WaterBudgetView()
            .environmentObject(TankaUnits())
            .environmentObject(WaterBudgetModel())
    }
}
