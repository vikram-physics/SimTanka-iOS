//
//  WaterDiaryRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//

import SwiftUI

struct WaterDiaryRowView: View {
    var myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    var date:Date
    var amountOfWater:Double
    var potable: Potable
    var comments: String
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Spacer()
                Text("\(date, style: .date)").font(.title3)
                Spacer()
            } .padding(0).background(Color.blue).foregroundColor(.white)
            HStack{
                Text("Water in the tank  =  \(Helper.VolumeStringFrom(volumeM3: amountOfWater, volumeUnit: myTankaUnits.volumeUnit))")
                Text(myTankaUnits.volumeUnit.text)
                Spacer()
            }.padding(4).background(Color.green)
                //.font(.system(size: 14))
            HStack{
                Text("Potability of water ").font(.caption)
                Spacer()
                Text(potable.text)
                    .foregroundColor(potable.text == "Potable" ? .white : .black)
                
            }.padding(4).background(myColorOne)
           
            HStack{
                Text(comments)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .border(.purple, width: 1)
                   // .frame(width:.infinity)
                Spacer()
            }.font(.body)
            Spacer()
        }.frame(height: 150).padding(2).background(Color.gray)
    }
}

struct WaterDiaryRowView_Previews: PreviewProvider {
    static var previews: some View {
        WaterDiaryRowView(date: Date(), amountOfWater: 5000.0, potable: Potable.Potable, comments: "All is well")
            .environmentObject(TankaUnits())
            .frame(height: 100)
    }
}
