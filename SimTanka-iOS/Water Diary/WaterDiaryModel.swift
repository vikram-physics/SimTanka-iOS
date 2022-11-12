//
//  WaterDiaryModel.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//
// Class for storing and displaying entries of water diary

import Foundation
import CoreData

class WaterDiaryModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    private let waterDiaryController: NSFetchedResultsController<WaterDiary>
    private let dbContext: NSManagedObjectContext
    
    @Published var waterDiaryArray: [WaterDiary] = []
    
    init(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<WaterDiary> = WaterDiary.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        waterDiaryController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.dbContext = managedObjectContext
        super.init()
        
        waterDiaryController.delegate = self
        
        do {
            try waterDiaryController.performFetch()
            waterDiaryArray = waterDiaryController.fetchedObjects ?? []
        } catch {
            print("Could not fetch water diary entries")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        do {
            try waterDiaryController.performFetch()
            waterDiaryArray = waterDiaryController.fetchedObjects ?? []
        } catch {
            print("Could not fetch water diary entries")
        }
    }
    
}

extension WaterDiaryModel {
    
    func AddWaterDiaryEntry() -> Bool {
        
        // check if we have record for today
        
       
        let datePredicate =  NSPredicate(format: "date >= %@ && date <= %@", Calendar.current.startOfDay(for: Date()) as CVarArg, Calendar.current.startOfDay(for: Date() + 86400) as CVarArg)
        
        
        let filterDailyRecord = self.waterDiaryArray.filter ({ record in
            
           // compoundPredicate.evaluate(with: record)
            datePredicate.evaluate(with: record)
            
        })
        
        if filterDailyRecord.count != 0 {
            return false
        } else {
            return true 
        }
        
        
    }
    
    func SaveNewEntryToCD(waterInTankM3: Double, potability: Potable, entry: String) {
        
        // create a new entity for today
        let newEntry = WaterDiary(context: dbContext)
        
        // set the date to today
        newEntry.date = Date()
        
        // set the amount of water in M3
        newEntry.amountM3 = waterInTankM3
        
        // set raw value of Potability enum
        newEntry.potable = Int16(potability.rawValue)
        
        // set entry
        newEntry.diaryEntry = entry
        
        // add newEntry to the waterDiaryArray
        waterDiaryArray.append(newEntry)
        
        // save to the data base
        do {
            try self.dbContext.save()
        } catch {
            print("Error saving  new water diary record")
        }
        
    }
}

enum Potable:Int, CaseIterable{
    
    case Potable = 0
    case NonPotable = 1
    case Unknown = 2
    
    init (type: Int) {
        switch type {
        case 0: self = .Potable
        case 1: self = .NonPotable
        case 2: self = .Unknown

        default: self = .NonPotable
        }
    }
    
    var text: String {
        switch self {
        case .Potable : return "Potable"
        case .NonPotable : return "Non Potable"
        case .Unknown : return "Unknown"
       
        }
    }
}
