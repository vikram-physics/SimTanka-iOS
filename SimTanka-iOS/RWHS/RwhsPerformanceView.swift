//
//  RwhsPerformanceView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 25/06/22.
//

import SwiftUI

struct RwhsPerformanceView: View {
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var simTanka: SimTanka
    @EnvironmentObject var demandModel:DemandModel
    @AppStorage("tankSizeM3") private var tankSizeM3 = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color.teal)
                    .frame(height: geometry.size.height * 1.0)
                List {
                    HStack{
                        Text("Estimated Performance of Your RWHS for Different Tank Sizes ").font(.headline)
                        Spacer()
                    }.listRowBackground(Color.teal)
                    HStack{
                        Text("The first row is your tanks size")
                        Spacer()
                    }.listRowBackground(Color.teal)
                    
                    
                    ForEach(simTanka.displayResults, id: \.self ) { result in
                        
                        HStack{
                            Text("Tank = \(Helper.VolumeStringFrom(volumeM3: result.tanksizeM3, volumeUnit: myTankaUnits.volumeUnit))   \(myTankaUnits.volumeUnit.text)")
                            Spacer()
                            Text("Reliabilty: \(Helper.LikelyHoodProbFrom(reliability: result.annualSuccess))")
                        }.listRowBackground(( tankSizeM3 == result.tanksizeM3 ? Color.purple : Color.blue))
                            .foregroundColor(Color.white)
                    }
                   // Spacer()
                    HStack {
                        Text("Annual demand of \(Helper.VolumeStringFrom(volumeM3: demandModel.AnnualWaterDemandM3(), volumeUnit: myTankaUnits.volumeUnit))")
                        Text(myTankaUnits.volumeUnit.text)
                    }.font(.subheadline)
                        .listRowBackground(Color.gray)
                        .foregroundColor(.white)
                }.environment(\.defaultMinListRowHeight, 30)
                 .frame(height: geometry.size.height * 0.6)
                 .listStyle(PlainListStyle())
            }
            
            
        }
        
    }
}

struct RwhsPerformanceView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        RwhsPerformanceView()
            .environmentObject(TankaUnits())
            .environmentObject(SimTanka(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
