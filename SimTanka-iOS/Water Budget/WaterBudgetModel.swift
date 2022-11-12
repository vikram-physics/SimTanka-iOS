//
//  WaterBudgetModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 26/01/22.
//

import Foundation
import SwiftUI
import CoreData

 class WaterBudgetModel:NSObject, ObservableObject, NSFetchedResultsControllerDelegate  {
    
    let defaultBudget = UserDefaults.standard
   // @EnvironmentObject var myTankaUnits: TankaUnits
    
    
 /*   @Published var demandArrayInM3:[Double] = UserDefaults.standard.array(forKey: "demandArray") as? [Double] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] {
        didSet{
            
            defaultBudget.set(demandArrayInM3, forKey: "demandArray")
        }
    } */
    
    var demandArrayInM3 : [Double] {
        
        get {
            defaultBudget.object(forKey: "demandArray") as? [Double] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            }
        
        set {
            defaultBudget.set(newValue, forKey: "demandArray")
        }
    }
    
    
    
    @Published var demandStringArray:[String] = ["0","0","0","0","0","0","0","0","0","0","0","0"]
    @Published var normalizedDemandArray:[Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
    func WaterBudgetInUnits(demandUnit: VolumeUnit) {
        
        // returns daily demand for each month in user's unit
        var demandArrayForDisplay = self.demandArrayInM3
        
        // set the demand array to zero elements
        self.demandStringArray = [] 
        // convert the array elements from m3 to the user units
        
        // find the converstion factor
        var convertFactor = 0.0
        switch demandUnit.rawValue {
            case 0: convertFactor = 1000.0 // liters Convert from m3 to liters
            case 1: convertFactor = 1     // m3 -> m3
            case 2: convertFactor = 264.172052 // m3 -> gallon
        default:
            convertFactor = 1.0
        }
        
        demandArrayForDisplay = demandArrayForDisplay.map {$0 * convertFactor}
        
       self.demandStringArray = demandArrayForDisplay.map { String(format:"%.1f", $0)}
    }
    
    func NormalisedDemand() -> [Double] {
        
        //find the max demand
        let maxDemand = demandArrayInM3.max() ?? 1.0
        
        return demandArrayInM3.map { $0 / maxDemand }
            
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
        
        self.demandArrayInM3 = demandArray
       // defaultBudget.set(demandArrayInM3, forKey: "demandArray")
        
    }

    
    func WaterBudgetIsSet() -> Bool {
        
        // check if there are non-zero demand months
        let totalDemand = self.demandArrayInM3.reduce(0, +)
        
        if totalDemand > 0 {
            return true
        } else {
            return false
        }
    }
    
}
