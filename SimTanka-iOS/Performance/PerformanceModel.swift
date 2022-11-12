//
//  PerformanceModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 03/05/22.
//

import Foundation
import SwiftUI
import CoreData

class PerformanceModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    @AppStorage("baseYear") private var baseYear = 0
    
    // base year is year from which the records are kept
    // it is setup in setupLocationView - five years in past
    
    @AppStorage("runOff") var runOff = 0.0
    @AppStorage("catchAreaM2") private var catchAreaM2 = 0.0
    @AppStorage("tankSizeM3") private var tankSizeM3 = 0.0
    
    
    @Published var waterInTankAtStart = 0.0 // water in the tank at the beginning - to be obtained from performance view
    
    @Published var numberOfMonthsInFuture = 3 // estimating future performance for next numberOfMontsInFuture
    
    // rain fall data from core data
    
     private let rainfallController: NSFetchedResultsController<MonthYearRain>
     private let dailyRainController: NSFetchedResultsController<DailyRainFall>
     private let demandController: NSFetchedResultsController<WaterDemand>
     private let dbContext: NSManagedObjectContext
     
     var monthRainInMMArray: [MonthYearRain] = [] // rainfall stored in Core Data
     var dailyRainInMMarray: [DailyRainFall] = [] //
    var dailyDemandArray: [WaterDemand] = []
    
    // water budget from core data
    
     init(managedObjectContext: NSManagedObjectContext) {
         
         let fetchRequest:NSFetchRequest<MonthYearRain> = MonthYearRain.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
         rainfallController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
         
         
         let fetchDailyRainfall:NSFetchRequest<DailyRainFall> = DailyRainFall.fetchRequest()
         fetchDailyRainfall.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
         dailyRainController = NSFetchedResultsController(fetchRequest: fetchDailyRainfall, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
         
         
         
         let fetchDailyDemand:NSFetchRequest<WaterDemand> = WaterDemand.fetchRequest()
         fetchDailyDemand.sortDescriptors = [NSSortDescriptor(key: "month", ascending: true)]
         demandController = NSFetchedResultsController(fetchRequest: fetchDailyDemand, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
         
         self.dbContext = managedObjectContext
         super.init()
         
         rainfallController.delegate = self
         dailyRainController.delegate = self
         demandController.delegate = self
         
         do {
             try rainfallController.performFetch()
             monthRainInMMArray = rainfallController.fetchedObjects ?? []
         } catch {
             print("Could not fetch monthly rainfall records")
         }
         
         do {
             try dailyRainController.performFetch()
             dailyRainInMMarray = dailyRainController.fetchedObjects ?? []
         } catch {
             print("Could not fetch daily rainfall records")
         }
         
         do {
             try demandController.performFetch()
             dailyDemandArray = demandController.fetchedObjects ?? []
         } catch {
             print("Could ot fetch daily water demand")
         }
     }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        do {
            try rainfallController.performFetch()
            monthRainInMMArray = rainfallController.fetchedObjects ?? []
        } catch {
            print("Could not fetch monthly rainfall records")
        }
        
        do {
            try dailyRainController.performFetch()
            dailyRainInMMarray = dailyRainController.fetchedObjects ?? []
        } catch {
            print("Could not fetch daily rainfall records")
        }
        //print(dailyRainInMMarray.count)
    }
   
    func waterHarvestedForCurrentMonth()  async -> ProbableAmount {
        
        let today = Date()
        let startDay = Helper.DayFromDate(date: today)
        let endDay = Helper.DayFromDate(date: today.endOfMonth())
        let pastYears = Helper.PastYears(baseYear: baseYear)
        let month = Helper.MonthFromDate(date: today)
        
        
        var waterHarvestedInM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterHarvestedInM3 = 0.0
            
            for day in startDay...endDay {
                
                let waterHarvestedOnDay = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                
                waterHarvestedInM3 = waterHarvestedInM3 + waterHarvestedOnDay
                
                if waterHarvestedInM3 > tankSizeM3 {
                    waterHarvestedInM3 = tankSizeM3
                }
                
                
            }
            results.append(waterHarvestedInM3)
        
        }
        
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probability = Int(Float(pastYears.count - 1) / Float(pastYears.count) * 100)
        
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!
        
        return probableAmount
        
    }
    
    func waterInTankForCurrentMonth(initialAmount:Double) async -> ProbableAmount {
        
        let today = Date()
        let startDay = Helper.DayFromDate(date: today)
        let endDay = Helper.DayFromDate(date: today.endOfMonth())
        let pastYears = Helper.PastYears(baseYear: baseYear)
        let month = Helper.MonthFromDate(date: today)
        
        
        var waterInTankM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterInTankM3 = initialAmount
           
            
            for day in startDay...endDay {
                
                
                let waterHarvestedOnDay = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                                
                waterInTankM3 = waterInTankM3 + waterHarvestedOnDay - dailyDemandArray[month-1].dailyDemandM3
                
                if waterInTankM3 < 0 {
                    waterInTankM3 = 0.0 // tank is empty
                }
                
                if waterInTankM3 > tankSizeM3 {
                    waterInTankM3 = tankSizeM3
                }
                
                
            }
            results.append(waterInTankM3)
        }
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probability = Int((Double(pastYears.count - 1 ) / Double(pastYears.count)) * 100)
        
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!

        return probableAmount
    }
    
    func waterHarvestedForMonth(month:Int, year:Int, initialAmount: Double) -> ProbableAmount {
        
        
        let pastYears = Helper.PastYears(baseYear: baseYear)
        
        var waterHarvestedInM3 = 0.0
        var dailyWaterHarvestedInM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterHarvestedInM3 = initialAmount
            let daysInMonth = Helper.DaysIn(month: month, year: simYear)
            
            for day in 1...daysInMonth {
                
                dailyWaterHarvestedInM3 = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                
                waterHarvestedInM3 = waterHarvestedInM3 + dailyWaterHarvestedInM3
                
                if waterHarvestedInM3 > tankSizeM3 {
                    waterHarvestedInM3 = tankSizeM3
                }
                
                
            }
            results.append(waterHarvestedInM3)
        
        }
        
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probability = Int((pastYears.count - 1 / pastYears.count) * 100)
        
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!
        
        return probableAmount
        
    }
    
    func waterInTankForMonth(month:Int, year:Int, initialAmount: Double, dailyDemand: Double) -> ProbableAmount {
        
        
        let pastYears = Helper.PastYears(baseYear: baseYear)
        
        var waterInTankM3 = 0.0
        var dailyWaterHarvestedInM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterInTankM3 = initialAmount
            let daysInMonth = Helper.DaysIn(month: month, year: simYear)
            for day in 1...daysInMonth {
                
                dailyWaterHarvestedInM3 = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                
                waterInTankM3 = waterInTankM3 + dailyWaterHarvestedInM3 - dailyDemand
                
                if waterInTankM3 > tankSizeM3 {
                    waterInTankM3 = tankSizeM3
                }
                
                
            }
            results.append(waterInTankM3)
        }
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probability = Int((pastYears.count - 1 / pastYears.count) * 100)
        
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!
        
        return probableAmount
    }
    
   
}

extension PerformanceModel {
    
    func DailyWaterHarvestedM3(day:Int, month:Int, year:Int, runOff: Double, catchAreaM2: Double) -> Double {
        // month 1 = Jan
        // month 12 = Dec
        
        var waterHarvested = 0.0
        
        // get the desired daily record from core data
        let dayPredicate = NSPredicate(format: "day=%i", day)
        let monthPredicate = NSPredicate(format: "month=%i", month)
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, monthPredicate, yearPredicate])
        
        let filterDailyRecord = self.dailyRainInMMarray.filter ({ record in
            
            compoundPredicate.evaluate(with: record)
            
        })
        
        // check if there is any record
        if filterDailyRecord.count != 0 {
            
            waterHarvested = Double(filterDailyRecord[0].rainfallmm) * 0.001 * catchAreaM2 * runOff
        } else {
            
            waterHarvested = 0 // assume no rainfall for the day for which record is not there
        }
        
       // print( day, month, year, waterHarvested)
        return waterHarvested
    }
    
   /* func ReliabiltyDemandCurrentMonth(intialAmountM3: Double) async -> Int {
        
        // returns the percentage of the time the RWHS could meet the demand given by the user
        // in water budget for the current month and on the water in the tank at the start
        
        let today = Date()
        let startDay = Helper.DayFromDate(date: today)
        let endDay = Helper.DayFromDate(date: today.endOfMonth())
        
        let month = Helper.MonthFromDate(date: today)
        //let year = Helper.YearFromDate(date: today)
        
        var numberOfSimDays = 0
        var sucsessSimDays = 0
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        for simYear in PastYears() {
            
            // start with the amount of water measured by the user
            waterInTankYesterday = intialAmountM3
            
            for day in startDay...endDay {
                
        
                waterInTankToday = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                
                // water harvested cannot be greater than the tank size
                waterInTankToday = min(waterInTankToday, tankSizeM3)
                
                let dailyDemand = dailyDemandArray[month-1].dailyDemandM3
                
                if dailyDemand != 0.0 {
                    // update the counter
                    numberOfSimDays = numberOfSimDays + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0.0 {
                        sucsessSimDays = sucsessSimDays + 1
                    } else {
                        waterInTankToday = 0.0 // tank is empty
                    }
                }
               
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
            }
            
            
            
        }
        
        // calculate reliability
        return Int(Float(sucsessSimDays) / Float(numberOfSimDays) * 100)
        
    } */
    
   /*  func ReliabilityDemandMonthPlusOne(initialAmountM3Today: Double)  async -> Int {
        
        let todayPlusOneMonth = Helper.AddOrSubtractMonth(month: 1)
        let startDay = Helper.DayFromDate(date: todayPlusOneMonth.startOfMonth())
        let endDay = Helper.DayFromDate(date: todayPlusOneMonth.endOfMonth())
        let month = Helper.MonthFromDate(date: todayPlusOneMonth)
        
        
        // estimate the water in tank at the begining of the month
        let initialAmountEstimate = await self.waterInTankForCurrentMonth(initialAmount: initialAmountM3Today).waterInTankM3
        
        var numberOfSimDays = 0
        var sucsessSimDays = 0
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        for simYear in PastYears() {
            
            // start with the amount of water estimated from the last month
            waterInTankYesterday = initialAmountEstimate
            
            for day in startDay...endDay {
                
                waterInTankToday = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                
                // water harvested cannot be greater than the tank size
                waterInTankToday = min(waterInTankToday, tankSizeM3)
                
                let dailyDemand = dailyDemandArray[month-1].dailyDemandM3
                
                if dailyDemand != 0.0 {
                    // update the counter
                    numberOfSimDays = numberOfSimDays + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0.0 {
                        sucsessSimDays = sucsessSimDays + 1
                    } else {
                        waterInTankToday = 0.0 // tank is empty
                    }
                }
               
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
               
            }
            
            
            
        }
        
        // calculate reliability
        // probabilty of the initial amount at the beginning from month times the probability of meeting
        // the demand in the month.
        
        let probabilityOfInitialAmount = await Double(self.waterInTankForCurrentMonth(initialAmount: initialAmountM3Today).probability) / 100.0 // converting from percentage
        let probabilityOfSuccess = Double(sucsessSimDays) / Double(numberOfSimDays)
        let combinedProbability = probabilityOfInitialAmount * probabilityOfSuccess
        return Int((combinedProbability) * 100)
        
        
    } */
    
   /* func WaterHarvestedMonthPlusOne() async -> ProbableAmount {
        
        let todayPlusOneMonth = Helper.AddOrSubtractMonth(month: 1)
        let startDay = Helper.DayFromDate(date: todayPlusOneMonth)
        let endDay = Helper.DayFromDate(date: todayPlusOneMonth.endOfMonth())
        let pastYears = Helper.PastYears(baseYear: baseYear)
        let month = Helper.MonthFromDate(date: todayPlusOneMonth)
        
        
        var waterHarvestedInM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterHarvestedInM3 = 0.0
            
            for day in startDay...endDay {
                
                let waterHarvestedOnDay = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                
                waterHarvestedInM3 = waterHarvestedInM3 + waterHarvestedOnDay
                
                if waterHarvestedInM3 > tankSizeM3 {
                    waterHarvestedInM3 = tankSizeM3
                }
                
                
            }
            results.append(waterHarvestedInM3)
        
        }
        
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probability = Int(Float(pastYears.count - 1) / Float(pastYears.count) * 100)
        
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!
        
        return probableAmount
        
    } */
    
    func WaterInTankMonthPlus(todaysAmount: Double) async -> ProbableAmount {
        
        let todayPlusOneMonth = Helper.AddOrSubtractMonth(month: 1)
        let startDay = Helper.DayFromDate(date: todayPlusOneMonth.startOfMonth())
        let endDay = Helper.DayFromDate(date: todayPlusOneMonth.endOfMonth())
        let month = Helper.MonthFromDate(date: todayPlusOneMonth)
        let pastYears = Helper.PastYears(baseYear: baseYear)
        
        // estimate the water in tank at the begining of the month
        let initialAmountEstimate = await self.waterInTankForCurrentMonth(initialAmount: todaysAmount).waterInTankM3
        
        var waterInTankM3 = 0.0
        var results:[Double] = []
        
        for simYear in pastYears {
            
            waterInTankM3 = initialAmountEstimate
           
            
            for day in startDay...endDay {
                
                
                let waterHarvestedOnDay = DailyWaterHarvestedM3(day: day, month: month, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2)
                                
                waterInTankM3 = waterInTankM3 + waterHarvestedOnDay - dailyDemandArray[month-1].dailyDemandM3
                
                if waterInTankM3 < 0 {
                    waterInTankM3 = 0.0 // tank is empty
                }
                
                if waterInTankM3 > tankSizeM3 {
                    waterInTankM3 = tankSizeM3
                }
                
                
            }
            results.append(waterInTankM3)
        }
        // find the minimum water harvested
        let minHarvest = results.min()
        
        // find the probability
        let probabilityOfInitialAmount = await Double(self.waterInTankForCurrentMonth(initialAmount: todaysAmount).probability) / 100.0 // converting from percentage
        let probabilityOfSuccess =  (Double(pastYears.count - 1 ) / Double(pastYears.count))// find the probability
        
        let combinedProbability = probabilityOfInitialAmount * probabilityOfSuccess
        
        let probability = Int(combinedProbability * 100 )
        var probableAmount = ProbableAmount()
        probableAmount.probability = probability
        probableAmount.waterInTankM3 = minHarvest!

        return probableAmount
    }
    
    func PastYears() -> [Int] {
        
        // creates an array of years from the base year to the current year - 1 //
        
        // current year
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today) - 1
        
        // array for storing the years
        var yearsArray:[Int] = []
        
        for n in baseYear...year {
            
            // check if we have monthly rainfall for that year
            if CheckIfMonthyRainExists(year: n) {
                yearsArray.append(n)
            }
           
        }
        
        let sortedYear = yearsArray.sorted {$0 > $1}
        
        return sortedYear
    }
    
    func CheckIfMonthyRainExists (year: Int) -> Bool {
        
        let monthlyRainArray = self.monthRainInMMArray.filter{ $0.year == year}
        
        if monthlyRainArray.count == 12 {
           // print("records exist for the year = ", year)
            return true
        } else {
           // print("records does not exist for the year = ", year)
            return false
        }
        
    }
    
    func ReliabilityForFuture30Days(intialAmountM3: Double)async -> Int {
        
        // days in current month
        let today = Date()
        let startDay = Helper.DayFromDate(date: today)
        let endDayCurrentMonth = Helper.DayFromDate(date: today.endOfMonth())
        let currentMonth = Helper.MonthFromDate(date: today)
      
        // days in next month
        let daysToAdd = 30
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)!
        let startDayNextMonth = Helper.DayFromDate(date: futureDate.startOfMonth())
        let endDayNextMonth = Helper.DayFromDate(date: futureDate)
        let nextMonth = Helper.MonthFromDate(date: futureDate)
        
        //
        
        var numberOfSimDays = 0
        var sucsessSimDays = 0
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        for simYear in PastYears() {
            
            // start with the amount of water measured by the user
            waterInTankYesterday = intialAmountM3
            
            // first simulate over the current month
           
            for day in startDay...endDayCurrentMonth {
                
                waterInTankToday = DailyWaterHarvestedM3(day: day, month: currentMonth, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                
                // water harvested cannot be greater than the tank size
                waterInTankToday = min(waterInTankToday, tankSizeM3)
                
                let dailyDemand = dailyDemandArray[currentMonth-1].dailyDemandM3
                
                if dailyDemand != 0.0 {
                    // update the counter
                    numberOfSimDays = numberOfSimDays + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0.0 {
                        sucsessSimDays = sucsessSimDays + 1
                    } else {
                        waterInTankToday = 0.0 // tank is empty
                    }
                }
            
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
            }
            
            // if the final date falls in the next month then only
            if nextMonth != currentMonth {
                for day in startDayNextMonth...endDayNextMonth {
                    waterInTankToday = DailyWaterHarvestedM3(day: day, month: nextMonth, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                   
                    // water harvested cannot be greater than the tank size
                    waterInTankToday = min(waterInTankToday, tankSizeM3)
                    
                    let dailyDemand = dailyDemandArray[nextMonth-1].dailyDemandM3
                    
                    if dailyDemand != 0.0 {
                        // update the counter
                        numberOfSimDays = numberOfSimDays + 1
                        waterInTankToday = waterInTankToday - dailyDemand
                        if waterInTankToday >= 0.0 {
                            sucsessSimDays = sucsessSimDays + 1
                        } else {
                            waterInTankToday = 0.0 // tank is empty
                        }
                    }
                   
                    // prepare for tomorrow
                    waterInTankYesterday = waterInTankToday
                    
                }
            }
        }
        
        // calculate reliability
        return Int(Float(sucsessSimDays) / Float(numberOfSimDays) * 100)
    }
    
    func FuturePerformance30Days(initialAmountM3: Double) async -> DisplayPerformance {
        
        // days in current month
        let today = Date()
        let startDay = Helper.DayFromDate(date: today)
        let endDayCurrentMonth = Helper.DayFromDate(date: today.endOfMonth())
        let currentMonth = Helper.MonthFromDate(date: today)
      
        // days in next month
        let daysToAdd = 30
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)!
        let startDayNextMonth = Helper.DayFromDate(date: futureDate.startOfMonth())
        let endDayNextMonth = Helper.DayFromDate(date: futureDate)
        let nextMonth = Helper.MonthFromDate(date: futureDate)
        
        // check if the current month is december and the next month is January of the next year
        var simYears = PastYears()
       

        if currentMonth == 12 && nextMonth == 1 {
            _ = simYears.removeFirst() // we remove the most recent year for which there is no Jan rainfall
        }
        
        var numberOfSimDays = 0
        var sucsessSimDays = 0
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        var waterAtTheEndOfSimArray:[Double] = []
        
        for simYear in simYears {
            
            // start with the amount of water measured by the user
            waterInTankYesterday = initialAmountM3
            
            // first simulate over the current month
           
            for day in startDay...endDayCurrentMonth {
                
                waterInTankToday = DailyWaterHarvestedM3(day: day, month: currentMonth, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                
                // water harvested cannot be greater than the tank size
                waterInTankToday = min(waterInTankToday, tankSizeM3)
                
                let dailyDemand = dailyDemandArray[currentMonth-1].dailyDemandM3
                
                if dailyDemand != 0.0 {
                    // update the counter
                    numberOfSimDays = numberOfSimDays + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0.0 {
                        sucsessSimDays = sucsessSimDays + 1
                    } else {
                        waterInTankToday = 0.0 // tank is empty
                    }
                }
            
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
            }
            
            // if the final date falls in the next month then only
            if nextMonth != currentMonth {
                for day in startDayNextMonth...endDayNextMonth {
                    
                    // we have to check if the next month is Jan then we have to use rainfall for simYear+1
                    if currentMonth == 12 && nextMonth == 1 {
                        waterInTankToday = DailyWaterHarvestedM3(day: day, month: nextMonth, year: simYear + 1, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                    } else {
                        waterInTankToday = DailyWaterHarvestedM3(day: day, month: nextMonth, year: simYear, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                    }
                    
                    
                   
                    // water harvested cannot be greater than the tank size
                    waterInTankToday = min(waterInTankToday, tankSizeM3)
                    
                    let dailyDemand = dailyDemandArray[nextMonth-1].dailyDemandM3
                    
                    if dailyDemand != 0.0 {
                        // update the counter
                        numberOfSimDays = numberOfSimDays + 1
                        waterInTankToday = waterInTankToday - dailyDemand
                        if waterInTankToday >= 0.0 {
                            sucsessSimDays = sucsessSimDays + 1
                        } else {
                            waterInTankToday = 0.0 // tank is empty
                        }
                    }
                   
                    // prepare for tomorrow
                    waterInTankYesterday = waterInTankToday
                    
                }
            }
            
            // append the water in the tank on the last day
            
            waterAtTheEndOfSimArray.append(waterInTankToday)
        }
        
        // calculate demand reliability
        var demandReliability: Int?
        if sucsessSimDays > 0 {
            
            demandReliability = Int(Float(sucsessSimDays) / Float(numberOfSimDays) * 100)
            
        }
        
        // calculate water in the tank at the end of the month
        
        let waterInTank = waterAtTheEndOfSimArray.min()
       
        // calculate the probability
        let count = waterAtTheEndOfSimArray.count
       // let waterReliability = Int( (Double(count - 1) / Double(count)) * 100 )
        
        return DisplayPerformance(demandReliability: demandReliability,numberOfSimYears: count, waterInTankAtTheEnd: waterInTank!)
        
        
    }
}

struct ProbableAmount {
    var waterInTankM3 = 0.0
    var probability = 0
}
struct DisplayPerformance {
    var demandReliability: Int? // if there is no demand then there is no reliability
    var numberOfSimYears = 0 //
    var waterInTankAtTheEnd = 0.0 //min in last numberOfSimYears
    
}
