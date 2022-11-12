//
//  MonthlyRainfallView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 12/01/22.
//
// View for displaying monthly rainfall for a given year
// To be presented as a sheet

import SwiftUI

struct MonthlyRainfallView: View {
    
    var myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    var myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 1))
    var myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 1))
    
    
    @Binding var year:Int
    
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    // for detailed view of the monthly rainfall
    @State private var selectedMonth: Int = 0
    @State private var showSheet = false

    var body: some View {
        GeometryReader { geometry in
           
            ZStack(alignment: .center){
                Rectangle()
                    .fill(myColorThree)
                    .frame(height: geometry.size.height * 1.0)
                List {
                    
                    HStack{
                        Spacer()
                        Text("Rainfall for the Year " + String(year))
                            .foregroundColor(.black)
                            .font(.title)
                        Spacer()
                        }.listRowBackground(myColorOne)
                    
                    ForEach(downloadRainModel.RainForView(year: year, rainUnit: self.myTankaUnits.rainfallUnit), id: \.self ) { record in
                        
                        NavigationLink (destination: DailyRainfallView(year: year, month: Helper.MonthIntFromMMMstring(monthStr: record.month)), label: {
                            MontlyRainRowView(monthString: record.month, normRain: record.normRainMM, monthRainString: record.rainInUserUnit, rainUnitString: myTankaUnits.rainfallUnit.text)
                        }).listRowInsets(EdgeInsets()).listRowBackground(myColorTwo).listRowSeparator(.hidden)
                      
                      /*  HStack {
                            MontlyRainRowView(monthString: record.month, normRain: record.normRainMM, monthRainString: record.rainInUserUnit, rainUnitString: myTankaUnits.rainfallUnit.text)
                        }.listRowBackground(myColorOne) */
                        
                          
                       
                        
                    }
                    
                   
                }.listStyle(PlainListStyle()).listRowSeparator(.hidden)
                    .environment(\.defaultMinListRowHeight, 23).listRowInsets(EdgeInsets()).listStyle(.plain)
                    .listRowBackground(myColorTwo)
                    .frame(height: geometry.size.height * 0.5)
                    .navigationBarTitle("Monthly Rainfall")
                    

                
            }
        }
    }
}

struct MonthlyRainfallView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        MonthlyRainfallView(year: .constant(2017))
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
        
    }
}
