//
//  DailyRainfallStruc.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 13/12/21.
//

import Foundation

// Model for storing daily rainfall data from NOAA

struct DailyRainfallNOAA: Codable {
    var dateTime: String
    var rainfall: Int
    
    // computed property e.g of dateTime 2018-04-11T00:00:00
    
       var date: String {
           let substring = dateTime.dropLast(9) // removes the timestamp
           return String(substring)
           // return dateTime.
       }
       
       var year: String{
           let substring = dateTime.dropLast(15) // removes the timestamp + day + month
           return String(substring)
       }
    var month: String {
        let start = dateTime.index(dateTime.startIndex, offsetBy: 5)
               let end = dateTime.index(dateTime.endIndex, offsetBy: -12)
               let range = start..<end
        let subString = dateTime[range]
        return String(subString)
    }
    
    var day: String {
        let start = dateTime.index(dateTime.startIndex, offsetBy: 8)
               let end = dateTime.index(dateTime.endIndex, offsetBy: -9)
               let range = start..<end
        let subString = dateTime[range]
        return String(subString)
    }
    // to match the keys with the JSON Data
    enum CodingKeys: String, CodingKey {
        case dateTime = "date"
        case rainfall = "value"
    }
    
}

// An array of Model Objects
struct RainfallForAYear: Codable {
    var results: [DailyRainfallNOAA] // key matches with the JSON data key
    
    // custum initializer for decoding from JSON data
    enum CodingKeys: String, CodingKey {
        case results
    }
}

struct RainfallForMonth: Codable {
    var results: [DailyRainfallNOAA] // key matches with the JSON data key
    
    // custum initializer for decoding from JSON data
    enum CodingKeys: String, CodingKey {
        case results
    }
}

