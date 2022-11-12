//
//  MetStationNetworkNOAA.swift
//  SimTanka-CV
//
//  Created by Vikram on 07/08/20.
//  Copyright © 2020 Vikram Vyas. All rights reserved.
//

import Foundation
import MapKit


class MetStationNetworkNOAA: NSObject, ObservableObject {
    
    @Published var nearestMetStation: MetStation?
    
    func fetchNearestMetStation(_ tankaLocation: CLLocation, regionRadiusInMeters: Double) {
        
        // create the query from the map region
        
        
        let mapRegion = MKCoordinateRegion.init(center: tankaLocation.coordinate, latitudinalMeters: regionRadiusInMeters * 2.0, longitudinalMeters: regionRadiusInMeters * 2.0)
        
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
                    
                    self.nearestMetStation = sortedStations[0]
                    //print(sortedStations[0])
                } else {
                    //print("could not find met station")
                }
            }
        }
    }
}

struct MetStationFromNOAA {
    
    func fetchMetStations(matching query:[String:String], completion: @escaping ([MetStation]? ) -> Void) {
        
        let token = "JxkmOioEJdncYVlrTERqCpjrnpyuVcuB"   // token given by NOAA
        let baseURL = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?")!
        
        guard let url = baseURL.withQueries(query) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "token")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data,
                let metStations = try? decoder.decode(MetStations.self, from: data) {
                completion(metStations.results)
            } else {
                completion(nil)
                return
            }
        }
        
        task.resume()
        
    }
}


