//
//  AnnualRainRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 18/01/22.
//
// Provides the row for the annual rainfall view
// Plots annual rainfall

import SwiftUI

struct AnnualRainRowView: View {
    
    // we need year
    var year:Int
    
    // we need normalized rainfall in users unit
    // we need annual rainfall in users unit
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack(spacing:0){
                Text(String(year))
                    .frame(width: geometry.size.width * 0.15, height: 20)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                ZStack (alignment: .leading){
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.gray)
                        .frame(width: geometry.size.width * 0.65, height: 20 )
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.60 * downloadRainModel.NormAnnualRain(year: year), height: 20 )
                }
                Group{
                    Text(downloadRainModel.AnnualRainYear(year: year, rainUnit: self.myTankaUnits.rainfallUnit))
                    Text(self.myTankaUnits.rainfallUnit.text)
                }.frame(height: 20)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(Color.black)
            }
            
        }.frame(height: 20)

    }
}

struct AnnualRainRowView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        AnnualRainRowView(year: 2020)
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
    }
}
