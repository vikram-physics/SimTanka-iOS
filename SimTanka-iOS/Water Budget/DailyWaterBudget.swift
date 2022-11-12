//
//  DailyWaterBudget.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 09/03/22.
//

import Foundation
import SwiftUI

final class DailyBudget:ObservableObject {
    
    @Published var defaultBudget: UserDefaults
    @Published var demandStringArray:[String] = []
    
    init (defaultBudget: UserDefaults = .standard) {
        
        self.defaultBudget = defaultBudget
    }
    
    var dailyBudget: [Double] {
        
        get {
            defaultBudget.object(forKey:"dailyBudgetM3") as? [Double] ?? [Double]()
        }
        
    }
    
    func SaveWaterBudget(demandUnit: VolumeUnit) {
        
        // function to save water demand in m3
        
        // first convert from string to float
        var demandArray:[Double] = []
        demandArray = demandStringArray.map { Double($0) ?? 0.0}
        
        // find the converstion factor from user units to m3
        var convertFactor = 0.0
        
        switch demandUnit.rawValue {
            case 0: convertFactor = 0.001 // liter -> m3
                
            case  1: convertFactor = 1 // m3 -> m3
    
            case 2: convertFactor = 0.003785411784 // gallon -> m3
        default:
            convertFactor = 1.0
            
        }
        
        demandArray = demandArray.map { $0 * convertFactor }
        
        defaultBudget.set(demandArray, forKey: "dailyBudget")
        
    }
}
