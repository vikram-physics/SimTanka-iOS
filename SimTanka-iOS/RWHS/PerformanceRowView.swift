//
//  PerformanceRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 16/02/22.
//
// View to display estimated performance for a given month
import SwiftUI

struct PerformanceRowView: View {
   
    // month
    var monthIndex = 0 // 0 is jan 
    var monthName = "Jan"
    // normalised water budget for the month
    var normalizedDemand = 1.0
    // normalised success rate for the month
    var successRate = 0.6
    // daily demand
    var dailyDemand = "5000"
    var userUnit = "L"
    // reliability
    var reliabilty = "70"

    var body: some View {
        GeometryReader { geometry in
            HStack (spacing:0) {
                Text(monthName)
                    .frame(width: geometry.size.width * 0.1, height: 50)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                
                VStack(alignment: .trailing) {
                    Text("Demand: " + dailyDemand + userUnit)
                        .foregroundColor(.white)
                    Text("Reiliablity: " + reliabilty + "%")
                        .foregroundColor(.white)
                }.font(.caption)
                    .frame(width: geometry.size.width * 0.4, height: 50)
                    .background(Color.purple)
                
                
                
                VStack (alignment: .leading, spacing: 0) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.red)
                        .frame(width: geometry.size.width * 0.45 * normalizedDemand, height: 25 )
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.45 * successRate, height: 25 )
                }
                
               
              /*
                VStack(alignment: .leading) {
                    Text("Daily Demand")
                    Text(" 500 L")
                }.font(.caption)
                    .frame(width: geometry.size.width * 0.2, height: 50)
                    .foregroundColor(.white)
                    .background(Color.blue) */
            }
            
            
            
            
        }.frame(height: 50)
    }
}

struct PerformanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceRowView()
            
    }
}
