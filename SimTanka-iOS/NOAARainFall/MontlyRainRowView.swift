//
//  MontlyRainRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 21/01/22.
// For plotting monthly rainfall

import SwiftUI

struct MontlyRainRowView: View {
    
    // we need month
    var monthString:String
    
    // we need normalized rain in mm for plotting
    var normRain:Double
    
    // we need normalized monthly rainfall for the given year
    var monthRainString:String
    
    // we need users rain unit
    var rainUnitString:String
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack (spacing:0) {
                Text(monthString)
                    .frame(width: geometry.size.width * 0.1, height: 20)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                ZStack (alignment: .leading){
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.gray)
                        .frame(width: geometry.size.width * 0.60, height: 20 )
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.60 * normRain, height: 20 )
                }
                Group {
                    Text(monthRainString)
                    Text(rainUnitString)
                }.frame(width: geometry.size.width * 0.15, height: 20)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
            }
            
        }.frame(height: 20)
    }
}

struct MontlyRainRowView_Previews: PreviewProvider {
    static var previews: some View {
        MontlyRainRowView(monthString: "Jan", normRain: 0.7, monthRainString: "1000", rainUnitString: "inches")
    }
}
