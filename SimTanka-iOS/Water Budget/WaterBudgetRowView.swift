//
//  WaterBudgetRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 28/01/22.
//

import SwiftUI

struct WaterBudgetRowView: View {
    let myBlue = Color(red: 0.1, green: 0.1, blue: 90)
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    @FocusState private var dailyDemandIsFocused: Bool
    
    @Binding var month: Int
    @Binding var dailyWater: String
    var body: some View {
        HStack{
            //Spacer()
            Text(Helper.intMonthToShortString(monthInt: month + 1))
            Text(" Daily Water Demand in " + myTankaUnits.volumeUnit.text)
           // Spacer()
            TextField("daily demand", text: self.$dailyWater)
                .focused($dailyDemandIsFocused)
                .keyboardType(.numberPad)
                .frame(width: 100)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
           // Text(myTankaUnits.volumeUnit.text)

        }.padding()
        .foregroundColor(.white)
        .frame(width: 350, height: 100, alignment: .leading)
        .background(Color.gray)
        .onTapGesture {
                  dailyDemandIsFocused = false
                }
    }
}

struct WaterBudgetRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            WaterBudgetRowView(month: .constant(0), dailyWater: .constant("500"))
                .previewLayout(.fixed(width: 400, height: 200))
                .environmentObject(TankaUnits())
        }
        
        
    }
}
