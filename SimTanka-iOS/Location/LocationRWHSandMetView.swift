//
//  LocationRWHSandMetView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 30/10/22.
//
// View to be displayed only if location of the RWHS is not set


import SwiftUI
import CoreLocation
import CoreLocationUI
import Network


struct LocationRWHSandMetView: View {
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    // For storing the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    @AppStorage("setLocation") private var setLocation = false
    
    // for the met station
    @AppStorage("setMetStation") private var setMetStation = false
    @AppStorage("metName") private var metName = ""
    @AppStorage("distanceToMetMeters") private var distanceToMetMeters = 0.0
    
    // units
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    @StateObject var locationManager = LocationManager()
    @StateObject var findMetStationModel = FindMetStationModel()
    
    @State private var choosenLocation = Locations.CurrentLocation
    @State var latitudeStrg = String()
    @State var longitudeStrg = String()
    @State private var userGivenLatitude = 0.0
    @State private var userGivenLongitude = 0.0
    
    @State private var showSaveLocationButton = false
    @State private var alertSavingLocation = false
    @State private var alertNoInternet = false
    @State private var searchMetStarted = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 1.0) {
            HStack {
                Text("**Source of Rainfall Data**")
                    .font(.title3)
              Spacer()
            }.padding(5).background(myColor5).foregroundColor(.black)
                .cornerRadius(5)
            
            // if met station found then display the details
            if setMetStation {
                VStack(alignment:.leading, spacing: 0) {
                    HStack {
                        Text(displayMetStationName()).foregroundColor(.white)
                            .padding(.horizontal, 5)
                        Spacer()
                    }
                    HStack {
                        Text(displayMetStationDistance()).foregroundColor(.white)
                            .padding(.horizontal, 5)
                        Spacer()
                    }
                }.background(myColor4).cornerRadius(5).font(.caption2)
            }
            
            // setting location
            
            if !setLocation {
                Picker("Location", selection: $choosenLocation) {
                    
                    ForEach(Locations.allCases, id:\.self) {
                        Text($0.text)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                
                if choosenLocation.rawValue == 0 {
                    VStack(alignment: .leading, spacing: 0) {
                       /* Text("Use current location as the location of RWHS")
                            .font(.callout)
                            .foregroundColor(.black)
                            .background(myColor5)
                            .clipShape(RoundedRectangle(cornerRadius: 10)) */
                        HStack {
                            
                            
                            LocationButton (.currentLocation) {
                               // locationManager.startUpdatingLocation() -- Apple's demo code has this
                                locationManager.locationManager.startUpdatingLocation()
                            }.labelStyle(.titleAndIcon).font(.callout)
                                .cornerRadius(50).padding(1)
                                .foregroundColor(.white)
                                .symbolVariant(.fill)
                            .tint(.blue)
                            Spacer()
                            Button(action: {
                                showSaveLocationButton = true
                                saveCurrentLocation()}, label: {
                                Text("Show on the map")
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(myColor4)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            })
                            Spacer()
                        }
                        
                       
                                       
                    }.background(myColor5).cornerRadius(10)
                }
                
                if choosenLocation.rawValue == 1 {
                    VStack(alignment: .leading, spacing: 0){
                        Text("Enter the location of the RWHS").foregroundColor(.black)
                        HStack{
                            Text("Latitude:")
                            TextField("latitude", text: $latitudeStrg).keyboardType(.numbersAndPunctuation)
                               
                        }
                        HStack{
                            Text("Longitude:")
                            TextField("Longitude", text: $longitudeStrg).keyboardType(.numbersAndPunctuation)
                                
                        }

                        HStack{
                            Spacer()
                            // validate and save location of the RWHS
                            if validUserGivenLocation(latString: latitudeStrg, longString: longitudeStrg) {
                                
                                Button(action: {
                                    showSaveLocationButton = true
                                   saveUserGivenLocation()
                                }, label:{
                                    Text("Show on the map")
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .padding(1)
                                        .background(myColor4)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } )
                            }
                            Spacer()
                        }
                       
                    }.padding().font(.callout).background(myColor5)
                        .cornerRadius(5)
                        .onTapGesture {
                            self.hideKeyboard()
                          }
                }
            }
            
            
            // Show location on the map
            
            SimTankaMapView(rwhsLatitude: userGivenLatitude, rwhsLongitude: userGivenLongitude).cornerRadius(1).frame(height:200)
            
            // Allow user to save the location
            HStack{
                if !setLocation && showSaveLocationButton {
                    Button(action: {
                        
                        alertSavingLocation = true
                    },
                    label: {
                        Text("Save Location")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(myColor4)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }).alert("This location will be used to find the nearest met. station, you will not be able to change it later!", isPresented: $alertSavingLocation) {
                        Button("Save") { saveRWHSLocation()}
                        Button("Cancel", role: .cancel) { }
                       
                    }
                }
               
            }
            // if internet connection available then allow user
            // user to download nearest met. station.
            HStack {
                Spacer()
                if setLocation && !setMetStation {
                    Button(action: {
                        Internet.start()
                        if !Internet.active {
                            alertNoInternet = true
                        }
                        searchMetStarted.toggle()
                        Task{
                            do {
                               try await findMetStationModel.FindNearestMetStationFrom(rwhsLat: rwhsLat, rwhsLong: rwhsLong, atMaxDistanceOf: Helper.MaxDistanceToSearchForMetStation())
                            }
                            
                        }
                    }, label: {
                        if searchMetStarted {
                            Text(findMetStationModel.msgMetStationSearch.text)
                        } else {
                            Text("Find Met. Station")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(myColor4)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        
                    }).alert("No internet connection!", isPresented: $alertNoInternet) {
                        Button("Cancel", role: .cancel) { }
                       
                    }
                }
                
                
            }
            
            // Rainfall view
            // view for displaying and downloading rainfall
            if setMetStation {
                RainfallView()
            }
            
           
            
            
             Spacer()
            
        }.padding(.horizontal)
            .onAppear{
                Internet.start()
                userGivenLatitude = rwhsLat
                userGivenLongitude = rwhsLong
            }
    }
}

// Utility functions

extension LocationRWHSandMetView {
    
    func validUserGivenLocation(latString: String, longString: String) -> Bool {
        
        
        if Double(latString) == nil {
            
            return false
        }
        
        if Double(longString) == nil {
            return false
        }
        
        return true
    }
    
    func saveCurrentLocation() {
        // reset the values
        rwhsLat = 0.0
        rwhsLong = 0.0
        
        if let location = locationManager.location {
            userGivenLatitude = location.latitude
            userGivenLongitude = location.longitude
        }
    }
    
    func saveUserGivenLocation() {
        // validated before using
        userGivenLatitude = Double(latitudeStrg)!
        userGivenLongitude = Double(longitudeStrg)!
        
    }
    
    func saveRWHSLocation() {
        rwhsLat = userGivenLatitude
        rwhsLong = userGivenLongitude
        setLocation = true
    }
    
    func displayMetStationDistance() -> String {
        var distance = 0.0
        var distanceString = "Distance from the RWHS: "
        
        guard self.setMetStation else {
            return "Could not find a met. station near the RWHS"
        }
        if myTankaUnits.distanceUnit.rawValue == 0 {
            // using km
            distance = distanceToMetMeters/1000.0
            distanceString = distanceString + String(format: "%.0f", distance)
            distanceString = distanceString + " \(myTankaUnits.distanceUnit.text)"
        } else {
            // using miles
            distance = distanceToMetMeters * 0.000621371
            distanceString = distanceString + String(format: "%.0f", distance)
            distanceString = distanceString + " \(myTankaUnits.distanceUnit.text)"
        }
        
        return distanceString
    }
    
    func displayMetStationName() -> String {
        
        let display = "Met. Station: " + self.metName
        
        return display
    }
}



struct LocationRWHSandMetView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRWHSandMetView()
    }
}

// Structure for checking network connection
// Taken from
// https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
// answer by Bobby

struct Internet {
 
 private static let monitor = NWPathMonitor()
 
 static var active = false
 static var expensive = false
 
 /// Monitors internet connectivity changes. Updates with every change in connectivity.
 /// Updates variables for availability and if it's expensive (cellular).
 static func start() {
  guard monitor.pathUpdateHandler == nil else { return }
  
  monitor.pathUpdateHandler = { update in
   Internet.active = update.status == .satisfied ? true : false
   Internet.expensive = update.isExpensive ? true : false
  }
  
  monitor.start(queue: DispatchQueue(label: "InternetMonitor"))
 }
 
}
