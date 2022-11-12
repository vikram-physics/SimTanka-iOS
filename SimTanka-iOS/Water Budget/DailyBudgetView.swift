//
//  DailyBudgetView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 25/05/22.
//

import SwiftUI

struct DailyBudgetView: View {
    @AppStorage("setUpBudgetMsg") private var setUpBudgetMsg =  "Please set up your water budget, this will allow SimTanka to predict future performances"
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var demandModel:DemandModel
    
    // for showing detailed view
    @State private var selcetedMonth: Int = 0
    @State private var showSheet = false
   
    @State private var demandsDisplay:[DemandDisplay] = []
    
    let myBlue = Color(red: 0.1, green: 0.1, blue: 90)
    let myGray = Color(red: 30, green: 0, blue: 100)
    let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
    
    var body: some View {
        List {
            Section(header: Text("Tap to enter the daily water budget").bold().font(.title3).foregroundColor(.blue)){
                
                ForEach(demandModel.demandDisplayArray.indices, id: \.self) { month in
                    
                    HStack{
                        Text(demandModel.demandDisplayArray[month].monthStr)
                        Spacer()
                        Text(demandModel.demandDisplayArray[month].demand)
                        Text(myTankaUnits.demandUnit.text)
                    }.containerShape(Rectangle())
                    .onTapGesture {
                        self.selcetedMonth = month
                        self.showSheet = true
                        print(selcetedMonth)
                    }
                        .foregroundColor(.white)
                        .listRowBackground((month % 2 == 0 ? Color.purple : skyBlue))
                }
               
            }
           
        }.onAppear{
           
            demandModel.FromCoreDataToUserDisplay(userDemandUnit: myTankaUnits.demandUnit)
        }
        .sheet(isPresented: $showSheet) {
            DemandRowView(monthIndex: self.$selcetedMonth)
        }
        .onDisappear {
            demandModel.SaveUserDemandToCoreData(userDemandUnit: myTankaUnits.demandUnit)
            self.setWaterBudgetMsg()
        }
        .navigationTitle(Text("Daily Water Budget"))
        .listStyle(PlainListStyle())
       
        
    }
}

extension DailyBudgetView {
   
    
    func fromCDtoDisplayArray() {
        for month in 1...12 {
            // find the user demand in M3 from Core Data
            let demandCD = demandModel.dailyDemandM3Array[month - 1]
            let demandM3 = demandCD.dailyDemandM3
            
            // user demand
            let userDemand = Helper.M3toDemandUnit(demandM3: demandM3, demandUnit: myTankaUnits.demandUnit)
            // month
            let deamandMonth = demandCD.month
            
            let newDemandToDisplay = DemandDisplay(userUnits: myTankaUnits.demandUnit, month: Int(deamandMonth), demand: String(userDemand))
            
            self.demandsDisplay.append(newDemandToDisplay)
           
        }
    }
    
    func setWaterBudgetMsg() {
        if demandModel.BudgetIsSet() {
            setUpBudgetMsg = "Water budget is set."
        }
    }
}

struct DailyBudgetView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        DailyBudgetView()
            .environmentObject(TankaUnits())
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}

struct Demand {
    var month: Int
    let demand: Double  // demand in user unit
    
}

struct DemandDisplay {
    
    var userUnits = DemandUnit(rawValue: 0)
    var month: Int
    var demand: String
    
    var monthStr:String {
        return Helper.intMonthToShortString(monthInt: self.month)
    }
    
    
}


