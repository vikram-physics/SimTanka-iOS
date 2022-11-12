//
//  MetStationNOAA.swift
//  SimTanka-CV
//
//  Created by Vikram on 06/08/20.
//  Copyright © 2020 Vikram Vyas. All rights reserved.
//

import Foundation
import MapKit

// Modal object for a metrological station from NOAA

struct MetStations: Codable {
    let results: [MetStation]
}

struct MetStation: Codable {
    
    // name and id of the station
    var name: String
    var id: String
    // location of the station
    var longitude: Float
    var latitude: Float
    // elevation
    var elevationUnit: String
    var elevation: Float
    // range of observations recorded
    var maxDate: String                 //later to be converted to Date
    var minDate: String
    // data coverage (what does it mean, in NOAA API)
    //var dataCoverage: Float
    
    // computed property
    
    var locationOfStation : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    // function to calculate distance from the tanka
    func distanceFromTanka(_ tankaLocation: CLLocation) -> Float{
        
        let stationCoord = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        return Float(tankaLocation.distance(from: stationCoord))
    }
    
    // To match the keys with the JSON data
    enum CodingKeys: String, CodingKey {
        case name                   // same as JSON
        case id                     // same as JSON
        case longitude              // same as JSON
        case latitude               // same as JSON
        case elevationUnit          // same as JSON
        case elevation              // same as JSON
        case maxDate = "maxdate"
        case minDate = "mindate"
        //case dataCoverage = "datacoverage"
    }
    
    // coustum initializer for decoding from JSON object
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self) // values obtained from the JSON object
        name = try values.decode(String.self, forKey: CodingKeys.name)
        id = try values.decode(String.self, forKey: CodingKeys.id)
        longitude = try values.decode(Float.self, forKey: CodingKeys.longitude)
        latitude = try values.decode(Float.self, forKey: CodingKeys.latitude)
        elevationUnit = try values.decode(String.self, forKey: CodingKeys.elevationUnit)
        elevation = try values.decode(Float.self, forKey: CodingKeys.elevation)
        maxDate = try values.decode(String.self, forKey: CodingKeys.maxDate)
        minDate = try values.decode(String.self, forKey: CodingKeys.minDate)
    }
    
}


