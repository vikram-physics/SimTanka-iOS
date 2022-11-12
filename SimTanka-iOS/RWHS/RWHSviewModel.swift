//
//  RWHSviewModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 07/02/22.
//

import Foundation

enum RunOff:Double, CaseIterable, Hashable {
    
    case Roof = 0.8
    case Pavement = 0.6
    case GroundTreated = 0.5
    case GroundNatural = 0.3
    
    init (type: Int) {
        switch type {
        case 0: self = .Roof
        case 1: self = .Pavement
        case 2: self = .GroundTreated
        case 3: self = .GroundNatural
        default: self = .Roof
        }
    }
    
    var text: String {
        switch self {
        case .Roof : return "Roof"
        case .Pavement : return "Pavement"
        case .GroundTreated : return "Ground"
        case .GroundNatural : return "Soil/Rock"
        }
    }
}

