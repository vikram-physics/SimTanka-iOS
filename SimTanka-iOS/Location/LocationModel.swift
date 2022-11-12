//
//  LocationViewModel.swift
//  SimTankaPE
//
//  Created by Vikram Vyas on 30/01/21.
//

import SwiftUI
import CoreLocation
import MapKit

class LocationViewModel:NSObject, ObservableObject{
    @EnvironmentObject var myTankaUnits: TankaUnits
    @State private var distanceUnit = DistanceUnit.km
    
    private let locationManager = CLLocationManager()
    
    @Published var useUserLocation = true
    @Published var useManualLocation = false
    
    @Published var rwhsLocation: CLLocation?
    
    @Published var manLatitude = "" // location entered by the user manually
    @Published var manLongitude = ""
    
    @Published var distOfMetFromRWHS = 0.0
    
    @Published var metStationForTanka: MetStation? /* {
          willSet{
              objectWillChange.send()
          }
      } */
    
    @Published var searchMsg = "Searching for Met. Station"
    
    override init() {
      super.init()
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.requestWhenInUseAuthorization()
      self.locationManager.startUpdatingLocation()
    }
    
}

extension LocationViewModel: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.rwhsLocation = location
    
    // to get the location only once
    self.locationManager.stopUpdatingLocation()
    manager.delegate = nil
    
   // print(location)
  }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied: self.useUserLocation = false
            
        default:
            self.useUserLocation = true
        }
        }
    
    func setCoordOfRWHS()-> CLLocationCoordinate2D {
        var coordRWHS = CLLocationCoordinate2DMake(0.0, 0.0)
        
        if self.useUserLocation == true && self.useManualLocation == false{
            coordRWHS = self.rwhsLocation?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)
        } else {
            let latitude = Double(self.manLatitude) ??  0.0
            let longitude = Double(self.manLongitude) ?? 0.0
            coordRWHS = CLLocationCoordinate2DMake(latitude, longitude)
        }
        
        return coordRWHS
    }
    
    func setLocationOfRWHS() -> CLLocation? {
        
        
        if self.useUserLocation == true && self.useManualLocation == false {
            
           return  self.rwhsLocation
            
        } else {
            
            return CLLocation(latitude: Double(self.manLatitude) ?? 0.0, longitude: Double(self.manLongitude) ?? 0.0)
        }
    
    }
    
    func findLocationOfMetStation() -> CLLocation? {
        
        let rwhsLocation = CLLocation(latitude: setCoordOfRWHS().latitude, longitude: setCoordOfRWHS().longitude)
        
        fetchMetStationsNearTanka(rwhsLocation)
        
        guard let metStationForTanka = self.metStationForTanka  else { return nil }
        return CLLocation(latitude: CLLocationDegrees(metStationForTanka.latitude), longitude: CLLocationDegrees(metStationForTanka.longitude))
    }
    
    
    // Find Met. Station nearest to the Met Station
    
    
    func fetchMetStationsNearTanka(_ tankaLocation: CLLocation)  {
        
        // create the query from the map region
        
        let regionRadius: CLLocationDistance = 100 * 1000 // meters - to put in settings
        
        let mapRegion = MKCoordinateRegion.init(center: tankaLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        // find the lat and long of the sw corner
        let swLat = mapRegion.center.latitude - (mapRegion.span.latitudeDelta/2.0)
        let swLong = mapRegion.center.longitude - (mapRegion.span.longitudeDelta/2.0)
        
        // find the lat and long of the ne corner
        let neLat = mapRegion.center.latitude + (mapRegion.span.latitudeDelta/2.0)
        let neLong = mapRegion.center.longitude + (mapRegion.span.longitudeDelta/2.0)
        
        let extentRegion = "\(swLat),\(swLong),\(neLat),\(neLong)"
        
        //
        // create the query for NOAA API
        // startdate - past five years rainrecords - dataset GHCND
        //
        
        // find the year
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let myStartdate = String("\(year-5)-01-01")
        
        let query = [ "extent": extentRegion,
                      "startdate": myStartdate,
                      "limit": "1000",
                      "datasetid": "GHCND",
                      //"datasetid": "GSOM",
            "datacategoryid": "PRCP"
        ]
        
        //var metStations = [MetStation]() // structure defined in Models group
        let metStationFinder = MetStationFromNOAA() // structure defined in NOAA group
        
        metStationFinder.fetchMetStations(matching: query) { (items) in
            DispatchQueue.main.async {
                if let items = items {
                    
                    //metStations = items
                    
                    let sortedStations = items.sorted(by: { (firstStation, secondStation) -> Bool in
                        return firstStation.distanceFromTanka(tankaLocation) < secondStation.distanceFromTanka(tankaLocation)
                    })
                    
                    self.metStationForTanka = sortedStations[0]
                    //print(sortedStations[0])
                } else {
                    self.searchMsg = "Could not find a Met. Station"
                }
            }
        }
        
        
        
    }
}

