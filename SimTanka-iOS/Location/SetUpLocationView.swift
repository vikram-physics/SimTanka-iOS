//
//  SetUpLocationView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 17/12/21.
//

import SwiftUI
import CoreLocationUI
import MapKit

// View for showing the location of the RWHS
// Show the nearest met station?
// Show the downloaded rainfall?

struct SetUpLocationView: View {
    @AppStorage("setLocation") private var setLocation = false
    @AppStorage("setMetStation") private var setMetStation = false
    @AppStorage("metName") private var metName = ""
    @AppStorage("metID") private var metID = ""
    @AppStorage("distanceToMetMeters") private var distanceToMetMeters = 0.0
    
    // Rainfall download
    // Base year is the year from which is monthly rainfall record starts
    @AppStorage("setBaseYear") private var setBaseYear = false
    @AppStorage("baseYear") private var baseYear = 0
    
    // msg for setup
    @AppStorage("msgLocationMetStation") private var  msgLocationMetStation = "SimTanka needs location to obrain daily rainfall records from NOAA"
    
    @StateObject private var viewModel = RWHSLocationViewModel()
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA

    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @State private var distanceUnit = DistanceUnit.km
    
    var body: some View {
        
        
        Spacer()
        VStack( spacing: 1){
            NameLocationView(locationModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(Color.gray)
               // .opacity(setLocation ? 1:0)
            
            Spacer()
            
            ZStack{
                Rectangle()
                    .fill(Color.blue)
                if setMetStation {
                    DisplayRainNOAAView()
                }
               // Rectangle()

            }
           
                
          //  Spacer()
                
            
            
        } .task {
           // print(self.metName)
           // self.checkForBaseYear()
           // self.displayRainfall()
            // Display rainfall
           // await printRainFor(month: 1, year: 2021, metID: self.metID)
            //await downloadRainModel.DownloadMonthRainFor(self.baseYear, self.metID)
        }
        .onDisappear{
            self.msgForLocationSetup()
        }
        
      
    }
    
    func setTitle() -> String {
        if setMetStation {
            return "Met. Station is \(self.distanceToMetStation()) away"
        } else {
            return "Monthly Rainfall"
        }
    }
    func distanceToMetStation() -> String {
        var distance = 0.0
        var distanceString = ""
        if distanceUnit.rawValue == 0 {
            // using km
            distance = distanceToMetMeters/1000.0
            distanceString = String(format: "%.0f", distance)
            distanceString = distanceString + " \(self.distanceUnit.text)"
        } else {
            // using miles
            distance = distanceToMetMeters * 0.000621371
            distanceString = String(format: "%.0f", distance)
            distanceString = distanceString + " \(self.distanceUnit.text)"
        }
        
        return distanceString
    }
    
}

extension SetUpLocationView {
    
    func checkForBaseYear() {
        if !setBaseYear {
            // find current year
            let today = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: today)
            self.baseYear = year - 10 // tmp
            self.setBaseYear = true
            //print(baseYear)
        }
       // print(setBaseYear)
       // print(baseYear)
    }
    func displayRainfall() {
        
        // check if we have base five year rainall
        if downloadRainModel.rainArrayForViews.count != 0 {
            
        }
       // print(downloadRainModel.rainArrayForViews.count)
    }
    
    func msgForLocationSetup() {
        if setMetStation {
            self.msgLocationMetStation = "Rainfall data from the met station " + metName + " is avaialable"
        } else {
            self.msgLocationMetStation = "Could not find a met station"
        }
    }
}

struct SetUpLocationView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        SetUpLocationView()
            .environmentObject(TankaUnits())
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
    }
}
