//
//  DemandRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 26/05/22.
//

import SwiftUI

struct DemandRowView: View {
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var demandModel:DemandModel
    @Binding var monthIndex: Int
   // @Binding var dailyWater: String
    
    @FocusState private var dailyDemandIsFocused: Bool
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack{
                
                Color.blue
                HStack{
                    Text(Helper.intMonthToShortString(monthInt: monthIndex + 1)).padding()
                    Spacer()
                    TextField("Daily Demand ", text: $demandModel.demandDisplayArray[monthIndex].demand)
                    Text(myTankaUnits.demandUnit.text)
                }.frame(width: geometry.size.width, height: 50, alignment: .leading)
                    .background(Color.clear)
                    .focused($dailyDemandIsFocused)
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.primary)
                .onTapGesture {
                              dailyDemandIsFocused = false
                }
            }
            
            
        }
        
        
    }
}

struct DemandRowView_Previews: PreviewProvider {
    
    
    static var previews: some View {
       
        ZStack{
            DemandRowView(monthIndex: .constant(3))
                .previewLayout(.fixed(width: 400, height: 200))
                .environmentObject(TankaUnits())
        }
       
    }
}
 
