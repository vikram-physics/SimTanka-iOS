//
//  DemandModel.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 19/05/22.
//
// Class for handling storing and retriving daily water budget

import Foundation
import SwiftUI
import CoreData

class DemandModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    // daily water demand from core data
    private let waterDemandController: NSFetchedResultsController<WaterDemand>
    private let dbContext: NSManagedObjectContext
    
    @Published var dailyDemandM3Array: [WaterDemand] = [] // from Core Data
    @Published var demandDisplayArray = [
        DemandDisplay(month: 1, demand: ""),
        DemandDisplay(month: 2, demand: ""),
        DemandDisplay(month: 3, demand: ""),
        DemandDisplay(month: 4, demand: ""),
        DemandDisplay(month: 5, demand: ""),
        DemandDisplay(month: 6, demand: ""),
        DemandDisplay(month: 7, demand: ""),
        DemandDisplay(month: 8, demand: ""),
        DemandDisplay(month: 9, demand: ""),
        DemandDisplay(month: 10, demand: ""),
        DemandDisplay(month: 11, demand: ""),
        DemandDisplay(month: 12, demand: "")
    ]
    
    
    init(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest:NSFetchRequest<WaterDemand> = WaterDemand.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "month", ascending: true)]
        
        waterDemandController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.dbContext = managedObjectContext
        super.init()
        
        waterDemandController.delegate = self
        
        do {
            try waterDemandController.performFetch()
            dailyDemandM3Array = waterDemandController.fetchedObjects ?? []
            if dailyDemandM3Array.count == 0 {
                createWaterBudgetInCoreData()
            }
        } catch {
            print("Could not fetch daily water demand records")
        }
    }
    
    // save users data to Core Data
    func SaveUserDemandForMonthInM3(rowIndex:Int, userDemandUnit: DemandUnit) {
        
        // convert user demand in user units to M3
        let demandString = self.demandDisplayArray[rowIndex].demand
        let demandInM3 = Helper.DemandInM3From(demandString: demandString, demandUnit: userDemandUnit)
        
        // write to WaterDemand array - Core Data Array
        self.dailyDemandM3Array[rowIndex].dailyDemandM3 = demandInM3
        
        // save to Core Data
        // update the database
        do {
            try self.dbContext.save()
        } catch {
            print("Error saving record")
        }
        
    }
    func SaveUserDemandToCoreData(userDemandUnit: DemandUnit) {
        
        for monthIndex in 0...11 {
            
            SaveUserDemandForMonthInM3(rowIndex: monthIndex, userDemandUnit: userDemandUnit)
            
        }
    }
    
    func FromCoreDataToUserDisplay( userDemandUnit: DemandUnit) {
        
        for monthIndex in 0...11 {
            let demandM3 = self.dailyDemandM3Array[monthIndex].dailyDemandM3
            let demandString = Helper.DemandStringFrom(dailyDemandM3: demandM3, demandUnit: userDemandUnit)
            self.demandDisplayArray[monthIndex].month = monthIndex + 1
            self.demandDisplayArray[monthIndex].demand = demandString
        }
    }
}

extension DemandModel {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        do {
            try waterDemandController.performFetch()
            dailyDemandM3Array = waterDemandController.fetchedObjects ?? []
        } catch {
            print("Could not fetch daily water demand records")
        }
    }
    
    func createWaterBudgetInCoreData() {
        print("Ok will create a water budget now")

        for month in 1...12 {
            // create a record
            let monthRecord = WaterDemand(context: self.dbContext)
            
            // set month
            monthRecord.month = Int16(month)
            
            // append it to dailyDemandM3Array
            dailyDemandM3Array.append(monthRecord)
            
            // save the record
            // update the database
            do {
                try self.dbContext.save()
            } catch {
                print("Error saving record")
            }
        }
        
    }
    
    func BudgetIsSet() -> Bool {
        
        // sum up the total water demand
        let totalDailyDemand = dailyDemandM3Array.reduce(0) {
            $0 + $1.dailyDemandM3
        }
       
        if totalDailyDemand != 0.0 {
            return true
        } else {
            return false 
        }
       
    }
    
    func DailyDemandM3() -> [Double] {
        // returns daily demand in M3
        
        var demandArray:[Double] = []
        
        for mIndex in 0...11 {
            let demandM3 = self.dailyDemandM3Array[mIndex].dailyDemandM3
            demandArray.append(demandM3)
            
        }
        return demandArray 
    }
    
    func AnnualWaterDemandM3() -> Double{
        let dailyDemandArrayM3 = self.DailyDemandM3()
       
        let monthDemandArray = dailyDemandArrayM3.map{$0 * 30}
        
        return monthDemandArray.reduce(0) {$0 + $1}
    }
}
