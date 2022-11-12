//
//  RainfallView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 09/11/22.
//
// To download and display rainfall data
//
import SwiftUI

struct RainfallView: View {
    
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    // user storage data
    // base year is the year from which user starts using SimTanka
    @AppStorage("setBaseYear") private var setBaseYear = false
    @AppStorage("baseYear") private var baseYear = 0
    
    // met station for downloading found in LocationRWHSandMetView()
    @AppStorage("metID") private var metID = ""
    
    
    var body: some View {
        VStack{
            HStack{
                Text("Downloading rainfall")
            }
        }.onAppear {
            checkForBaseYear()
        }
        .task {
           
        }
       
    }
}

extension RainfallView {
    
    func checkForBaseYear() {
    
        if !setBaseYear {
            // find current year
            let year = Helper.CurrentYear()
            self.baseYear = year
            self.setBaseYear = true
        }
       
    }
    
    
}
struct RainfallView_Previews: PreviewProvider {
    static var previews: some View {
        RainfallView()
    }
}
