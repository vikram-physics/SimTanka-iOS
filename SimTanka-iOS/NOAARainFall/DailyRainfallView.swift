//
//  DailyRainfallView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 08/08/22.
//
// View for displaying daily rainfall for a given month in a given year
// To be presented as a sheet

import SwiftUI

struct DailyRainfallView: View {
    
    let myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    let myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 1))
    let myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 1))
    
     var year:Int
     var month:Int
    
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                // background
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: geometry.size.height * 1.0)
                
                // List to display daily rainfall
                List {
                    HStack{
                        //Spacer()
                        Text("Daily Rainfall for " + Helper.intMonthToShortString(monthInt: month) + " " + String(year))
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding(0)
                        //Spacer()
                    }.listRowBackground(Color.gray)
                    
                    ForEach(downloadRainModel.DailyRainForView(year: year, month: month, rainUnit: myTankaUnits.rainfallUnit), id: \.self) { record in
                        
                        HStack{
                            DailyRainRowView(dayString: record.dayStr, normDailyRainMM: record.normDailyRain, dailyRainInUserUnitString: record.dailyRainUserUnitStr)
                        }.padding(0)
                       
                           
                        
                    }.listRowInsets(EdgeInsets()).listRowBackground(myColorTwo).listRowSeparator(.hidden)
                }.environment(\.defaultMinListRowHeight, 20).listRowInsets(EdgeInsets()).listStyle(.plain)
                
                
                
            }
            
        }.navigationBarTitle("Daily Rainfall")
            .navigationBarTitleDisplayMode(.inline)

    }
}

struct DailyRainfallView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        DailyRainfallView(year: 2017, month: 2)
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
    }
}
