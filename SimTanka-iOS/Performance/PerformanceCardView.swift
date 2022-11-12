//
//  PerformanceCardView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 10/06/22.
//

import SwiftUI





struct PerformanceCardView: View {
    
    @EnvironmentObject var performancdModel:PerformanceModel
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    @Binding var startDay:Date
    @Binding var endDay:Date
    @Binding var intialWaterM3:Double
    
    var body: some View {
        Text ("Hello")
      /*  List{
            Section(header: Text("Performance: \(startDay, style: .date) - \(endDay, style: .date)").bold().font(.caption).foregroundColor(.blue)) {
                HStack{
                    Text("Daily Demand ")
                    Text(displayDemand())
                    Text(myTankaUnits.demandUnit.text)
                    Spacer()
                    Text(meetingDemandReliability())
                    
                }.padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .font(.caption)
                
                HStack{
                    Text("Water harvested 5000 L")
                    Spacer()
                    Text("Reliability = 95%")
                   
                }.padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .font(.caption)
                
                VStack {
                    HStack{
                        Text("Water in the tank: \(endDay, style: .date)")
                    }
                    HStack{
                        Text("Amount: 4000 L")
                        Spacer()
                        Text("Reliability = 95%")
                    }
                }.padding(10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .font(.caption)
                
            }
        }.listStyle(PlainListStyle()) */
        

        
    }
}

extension PerformanceCardView {
    
    func displayDemand() -> String {
        
        let monthIndex = Helper.MonthFromDate(date: startDay) - 1
        let dailyDemandM3 = self.performancdModel.dailyDemandArray[monthIndex].dailyDemandM3
        return Helper.DemandStringFrom(dailyDemandM3: dailyDemandM3, demandUnit: myTankaUnits.demandUnit)
        
    }
    
}

struct PerformanceCardView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        PerformanceCardView(startDay: .constant(Date()), endDay: .constant(Date()), intialWaterM3: .constant(5000.0))
            .environmentObject(PerformanceModel(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
    }
}
