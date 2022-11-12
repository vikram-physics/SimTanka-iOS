//
//  NameLocationView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 03/01/22.
//
// To be presented to the user first time for
// naming the RWHS and obtaining the location of the user.

import SwiftUI
import CoreLocationUI


struct NameLocationView: View {
    
    @AppStorage("setLocation") private var setLocation = false
    @AppStorage("setName") private var setName = false
    @AppStorage("nameOfTanka") private var nameOfTanka = ""
    
    @AppStorage("setMetStation") private var setMetStation = false
    @AppStorage("metName") private var metName = ""
    @AppStorage("distanceToMetMeters") private var distanceToMetMeters = 0.0
    
    @ObservedObject var locationModel: RWHSLocationViewModel
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @State private var distanceUnit = DistanceUnit.km
    
    
    
    
    var body: some View {
        VStack{
            Spacer()
            if !setLocation {
                HStack{
                    Text("Set the location of the RWHS")
                        .foregroundColor(.white)
                    LocationButton (.shareCurrentLocation) {
                        locationModel.locationManager.startUpdatingLocation()
                    }.labelStyle(.titleOnly)
                    .cornerRadius(50)
                    .foregroundColor(.white)
                    .symbolVariant(.fill)
                    .tint(.blue)
                }
            }
            
            if setLocation {
                VStack{
                    SimTankaMapView()
                        .cornerRadius(25)
                        
                    Text(self.distanceToMetStation())
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(6)
                        
                }
                
            }
        }.onAppear{
            
            self.distanceUnit = self.myTankaUnits.distanceUnit

        }
        .navigationBarTitle(Text("Rainfall Data"))
        
        
    }
}

extension NameLocationView {
    
    func distanceToMetStation() -> String {
        var distance = 0.0
        var distanceString = "Source of rainfall data is " + self.metName + " at distance of "
        
        guard self.setMetStation else {
            return "Could not find a met. station near the RWHS"
        }
        if distanceUnit.rawValue == 0 {
            // using km
            distance = distanceToMetMeters/1000.0
            distanceString = distanceString + String(format: "%.0f", distance)
            distanceString = distanceString + " \(self.distanceUnit.text)"
        } else {
            // using miles
            distance = distanceToMetMeters * 0.000621371
            distanceString = distanceString + String(format: "%.0f", distance)
            distanceString = distanceString + " \(self.distanceUnit.text)"
        }
        
        return distanceString
    }
}

struct NameLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NameLocationView(locationModel: RWHSLocationViewModel())
            .environmentObject(TankaUnits())
            
    }
}
