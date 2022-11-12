//
//  LocationViewModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 19/12/21.
//

import Foundation
import CoreLocationUI
import MapKit
import SwiftUI

final class RWHSLocationViewModel: NSObject,ObservableObject, CLLocationManagerDelegate{
    
    // For storing the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    
    // For storing the details of the nearest Met. Station
    @AppStorage("metLat") private var metLat = 0.0
    @AppStorage("metLong") private var metLong = 0.0
    @AppStorage("metName") private var metName = ""
    @AppStorage("metID") private var metID = ""
    @AppStorage("distanceToMetMeters") private var distanceToMetMeters = 0.0
    
    // setlocation is true when the location is found
    @AppStorage("setLocation") private var setLocation = false
    
    // setMetStation is true when a met station is found
    @AppStorage("setMetStation") private var setMetStation = false
    
    @Published var rwhsLocation = CLLocationCoordinate2D()
    @Published var metLocation = CLLocationCoordinate2D()
    @Published var msgLocation = ""
    @Published var msgMetStation = " "
    
    private var location = CLLocation()
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self 
    }
    
   /* func requestAllowOnceLocationPermission() {
        locationManager.requestLocation()
        }
    */
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.last else {
            // show an error
            print("some thing went wrong")
            return
        }
        
        DispatchQueue.main.async {
            self.location = latestLocation
            self.rwhsLocation = latestLocation.coordinate
            self.rwhsLat = latestLocation.coordinate.latitude
            self.rwhsLong = latestLocation.coordinate.longitude
            self.msgLocation = "Finding Met Station"
            Task {
                do {  try await self.findNearestMetStation()
                    
                } catch DownloadError.invalidServerResponse {
                    self.msgLocation = "NOAA is Down!"
                    print(self.msgLocation)
                }
                
            }
            self.setLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension RWHSLocationViewModel {
    // This extension is to find the nearest Met. Station.
    
    // Create urlquery
    
    func createURLrequestForMetStation( _ rwhsLocation: CLLocationCoordinate2D) -> URLRequest {
        
        // create the query from the map region
        
        // regionRadius is the radius of circle in which we will search for a met. station
        // this is hard coded to 50Km
        
        let regionRadius: CLLocationDistance = 50 * 1000 // meters - to put in settings
        
        let mapRegion = MKCoordinateRegion.init(center: rwhsLocation, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
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
        let myStartdate = String("\(year-1)-01-01")
        
        let query = [ "extent": extentRegion,
                      "startdate": myStartdate,
                      "limit": "1000",
                      "datasetid": "GHCND",
                      //"datasetid": "GSOM",
            "datacategoryid": "PRCP"
        ]
        
        let token = "JxkmOioEJdncYVlrTERqCpjrnpyuVcuB"   // token given by NOAA
        let baseURL = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?")!
        
        let url = baseURL.withQueries(query)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "token")
        
        return request
    }
    
    func findNearestMetStation() async throws {
        
        let request = createURLrequestForMetStation(rwhsLocation)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw DownloadError.invalidServerResponse
                }
            
            // decode the data
            let deCoder = JSONDecoder()
            let metStations = try? deCoder.decode(MetStations.self, from: data)
            
            let result = metStations?.results
            
            if let result = result {
                let sortedStations = result.sorted(by: { (firstStation, secondStation) -> Bool in
                    return firstStation.distanceFromTanka(self.location) < secondStation.distanceFromTanka(self.location)
                })
                
                // neareste met station
                // sort according to max date
                DispatchQueue.main.async {
                    if sortedStations.count == 0 {
                        self.msgMetStation = "Could not find a met. station"
                        self.msgLocation = "Could not find a met. station near your location"
                        self.setMetStation = false
                        print("No Met. Stations around your location")
                    }
                    self.metID = sortedStations[0].id
                    self.metName = sortedStations[0].name
                    self.metLat = Double(sortedStations[0].latitude)
                    self.metLong = Double(sortedStations[0].longitude)
                    self.metLocation = CLLocationCoordinate2D(latitude: self.metLat, longitude: self.metLong)
                    self.distanceToMetMeters = Double(sortedStations[0].distanceFromTanka(self.location))
                    self.setMetStation = true
                    self.msgLocation = self.metName
                   // print(sortedStations[0])
                    //print(sortedStations[1])
                }
                
                
            } /* else {
                DispatchQueue.main.async {
                    self.msgMetStation = "Could not find a met. station"
                    self.msgLocation = "Could not find a met. station near your location"
                    self.setMetStation = false
                    print("No Met. Stations around your location")
                }
               
            } */
        } catch {
            
            print(error)
        }
       
        
        
        
       
        
    }
}


