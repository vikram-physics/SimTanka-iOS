

//
//  SettingsModel.swift
//  SimTankaPE
//
//  Created by Vikram on 17/01/21.
//

import Foundation
import SwiftUI

final class TankaUnits: ObservableObject {
    
    @Published var defaultUnits: UserDefaults
    
    init (defaultUnits: UserDefaults = .standard) {
        self.defaultUnits = defaultUnits
        
        defaultUnits.register(defaults: [
            "view.preferences.rainfallUnit" : 0,
            "view.preferences.areaUnit" : 0,
            "view.preferences.volumeUnit": 0,
            "view.preferences.distanceUnit": 0,
            "view.preferences.demandUnit": 0
        ])
    }
    
    var rainfallUnit: RainfallUnit{
        
        get {
            RainfallUnit(type: defaultUnits.integer(forKey: "view.preferences.rainfallUnit"))
        }
        
        set {
            defaultUnits.set(newValue.rawValue, forKey: "view.preferences.rainfallUnit")
        }
    }
    
    var areaUnit: AreaUnit {
        get {
            AreaUnit(type: defaultUnits.integer(forKey: "view.preferences.areaUnit"))
        }
        
        set {
            defaultUnits.set(newValue.rawValue, forKey: "view.preferences.areaUnit")
        }
    }
    
    var volumeUnit: VolumeUnit {
        get {
            VolumeUnit(type: defaultUnits.integer(forKey: "view.preferences.volumeUnit"))
        }
        
        set {
            defaultUnits.set(newValue.rawValue, forKey: "view.preferences.volumeUnit")
        }
    }
    
    var distanceUnit: DistanceUnit{
        
        get {
            DistanceUnit(type: defaultUnits.integer(forKey: "view.preferences.distanceUnit"))
        }
        
        set {
            defaultUnits.set(newValue.rawValue, forKey: "view.preferences.distanceUnit")
        }
    }
    
    var demandUnit: DemandUnit {
        get {
            DemandUnit(type: defaultUnits.integer(forKey: "view.preferences.demandUnit"))
        }
        
        set {
            defaultUnits.set(newValue.rawValue, forKey: "view.preferences.demandUnit")
        }
    }
    
}

enum RainfallUnit: Int, CaseIterable {
    case mm = 0
    case inches = 1
    
    init (type: Int) {
        switch type {
        case 0: self = .mm
        case 1: self = .inches
        default: self = .mm
        }
    }
    
    var text: String {
        switch self {
        case .mm : return "mm"
        case .inches: return "inches"
        }
    }
}

enum AreaUnit: Int, CaseIterable {
    
    case sqFeet = 0
    case sqMeter = 1
    
    init (type: Int) {
        switch type {
        case 0: self = .sqFeet
        case 1: self = .sqMeter
        default: self = .sqFeet
        }
    }
    var text:String {
        switch self {
            case .sqFeet: return "ft\u{00B2}"
            case .sqMeter: return "\u{33A1}" //return "\u{33A1}"
        }
    }
}

enum VolumeUnit: Int, CaseIterable {
    
    case liter = 0
    case cubicMeter = 1
    case gallon = 2
    
    init (type: Int) {
        switch type {
        case 0: self = .liter
        case 1: self = .cubicMeter
        case 2: self = .gallon
        default: self = .liter
        }
    }
    
    var text:String {
        switch self {
            case .liter: return "L" // U+006C
            case .cubicMeter: return String("\u{33A5}") // meter^3
            case .gallon: return "gal"
            
        }
    }
}

enum DistanceUnit: Int, CaseIterable {
    
    case km = 0
    case miles = 1
    
    init (type: Int) {
        switch type {
        case 0: self = .km
        case 1: self = .miles
        default: self = .km
        }
    }
    
    var text:String {
        switch self {
        case .km: return "Km"
        case .miles: return "Miles"
        }
    }
    
    
}

enum DemandUnit: Int, CaseIterable {
    
    case liter = 0
    case cubicMeter = 1
    case gallon = 2
    
    init (type: Int) {
        switch type {
        case 0: self = .liter
        case 1: self = .cubicMeter
        case 2: self = .gallon
        default: self = .liter
        }
    }
    
    var text:String {
        switch self {
            case .liter: return "L" // U+006C
            case .cubicMeter: return String("\u{33A5}") // meter^3
            case .gallon: return "gal"
            
        }
    }
    
    

}
