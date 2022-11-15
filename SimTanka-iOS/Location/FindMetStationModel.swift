//
//  FindMetStationModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 05/11/22.
//
// class to find the location of the nearest met. station
// from the RWHS
// using NOAA API
//


import Foundation
import CoreLocationUI
import MapKit
import SwiftUI

final class FindMetStationModel: NSObject, ObservableObject {
    
    // For storing the details of the nearest Met. Station
    @AppStorage("metLat") private var metLat = 0.0
    @AppStorage("metLong") private var metLong = 0.0
    @AppStorage("metName") private var metName = ""
    @AppStorage("metID") private var metID = ""
    @AppStorage("distanceToMetMeters") private var distanceToMetMeters = 0.0
    
    // setMetStation is true when a met station is found
    @AppStorage("setMetStation") private var setMetStation = false
    
    // published variables
    @Published var metLocation = CLLocationCoordinate2D()
    @Published var msgMetStationSearch = MsgMetStations.searchingForMetStation
    
    // private
    private var locationOfRWHS = CLLocationCoordinate2D()
    
}

extension FindMetStationModel {
    func FindNearestMetStationFrom(rwhsLat: Double, rwhsLong: Double, atMaxDistanceOf: CLLocationDistance ) async throws {
        
        // create the location for rainwater harvesting system
        locationOfRWHS = CLLocationCoordinate2D(latitude: rwhsLat, longitude: rwhsLong)
        
        let clLocationOfRwhs = CLLocation(latitude: rwhsLat, longitude: rwhsLong)
        // create URL request
        
        let request = CreateURLrequestForMetStation(locationOfRWHS, regionRadius: atMaxDistanceOf)
        
        do {
            
            // inform the user that we have started search
            DispatchQueue.main.async {
                self.msgMetStationSearch = MsgMetStations.searchingForMetStation
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw DownloadError.invalidServerResponse
                }
            
            // decode the data
            let deCoder = JSONDecoder()
            let metStations = try? deCoder.decode(MetStations.self, from: data)
            
            let result = metStations?.results
          
            // sort the result to find the nearest met station
            
            if let result = result {
                let sortedStations = result.sorted(by: { (firstStation, secondStation) -> Bool in
                    return firstStation.distanceFromTanka(clLocationOfRwhs) < secondStation.distanceFromTanka(clLocationOfRwhs)
                })
                
                // store the details of the nearest met. station
                DispatchQueue.main.async {
                    self.metID = sortedStations[0].id
                    self.metName = sortedStations[0].name
                    self.metLat = Double(sortedStations[0].latitude)
                    self.metLong = Double(sortedStations[0].longitude)
                    self.metLocation = CLLocationCoordinate2D(latitude: self.metLat, longitude: self.metLong)
                    self.distanceToMetMeters = Double(sortedStations[0].distanceFromTanka(clLocationOfRwhs))
                    self.setMetStation = true
                    self.msgMetStationSearch = MsgMetStations.foundMetStation
                }
            } else {
                
                throw DownloadError.noResult
            }
            
            
            
        } catch DownloadError.invalidServerResponse {
            DispatchQueue.main.async {
                self.msgMetStationSearch = MsgMetStations.couldNotConnectToNOAA
                self.setMetStation = false
            }
           
        } catch DownloadError.noResult {
            DispatchQueue.main.async {
                self.msgMetStationSearch = MsgMetStations.couldNotFindMetStation
                self.setMetStation = false
            }
        }
    }
    
    func CreateURLrequestForMetStation(_ rwhsLocation: CLLocationCoordinate2D, regionRadius: CLLocationDistance) -> URLRequest {
        
        // regionRadius is the radius of the circle with in which we will search
        
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
        
        let token = ""   // token given by NOAA
        let baseURL = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?")!
        
        let url = baseURL.withQueries(query)!
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "token")
        
        return request
    }
}

enum MsgMetStations: Int, CaseIterable, Hashable {
   
    case searchingForMetStation = 0
    case foundMetStation = 1
    case couldNotFindMetStation = 2
    case couldNotConnectToNOAA = 3
    
    init(msgNumber: Int) {
        switch msgNumber {
        case 0: self = .searchingForMetStation
        case 1: self = .foundMetStation
        case 2: self = .couldNotFindMetStation
        case 3: self = .couldNotConnectToNOAA
        default: self = .searchingForMetStation
        }
    }
    
    var text: String {
        switch self {
        case .searchingForMetStation : return "Searching for met station .."
        case .foundMetStation : return "Nearest met station is "
        case .couldNotFindMetStation : return "Could not find a met station: You can only keep records of your RWHS using water diary"
        case .couldNotConnectToNOAA: return "Could not connect to NOAA server"
        
        }
    }
    
}
enum DownloadError: Error {
    
    case invalidServerResponse
    case noResult
    
}
