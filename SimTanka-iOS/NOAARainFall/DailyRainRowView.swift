//
//  DailyRainRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 09/08/22.
//
//  For plotting daily rainfall

import SwiftUI

struct DailyRainRowView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    // we need day
    var dayString: String
    
    // normalized rain in mm for plotting
    var normDailyRainMM: Double
    
    // daily rain in user units for caption
    var dailyRainInUserUnitString: String
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack (spacing:0) {
                Text(dayString)
                    .frame(width: geometry.size.width * 0.1, height: 20)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                ZStack (alignment: .leading){
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.gray)
                        .frame(width: geometry.size.width * 0.70, height: 20 )
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.70 * normDailyRainMM, height: 20 )
                }
                Group {
                    Text(dailyRainInUserUnitString)
                    Text(myTankaUnits.rainfallUnit.text).foregroundColor(.white)
                }.frame(width: geometry.size.width * 0.1, height: 20).foregroundColor(.black)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
            }
            
        }.frame(height: 20)
    }
}

struct DailyRainRowView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        DailyRainRowView(dayString: "1", normDailyRainMM: 0.8, dailyRainInUserUnitString: "200")
            .environmentObject(TankaUnits())
    }
}
