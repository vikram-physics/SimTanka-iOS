//
//  SimTanka.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 02/02/22.
//
// Main model for simulating the performance of the RWHS

import Foundation
import SwiftUI
import CoreData

class SimTanka: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
   
   // let dailyDemandArrayM3 = UserDefaults.standard.array(forKey: "demandArray") as? [Double] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]  // water budget
    
   
    
    @AppStorage("baseYear") private var baseYear = 0
    
    @Published var monthSuccArray:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
    @Published var isSimulating = false
    
    @Published var displayResults:[EstimateResult] = []
    
    // rain fall data from core data
    private let rainfallController: NSFetchedResultsController<MonthYearRain>
    private let dailyRainController: NSFetchedResultsController<DailyRainFall>
    private let dbContext: NSManagedObjectContext
    
    var monthRainInMMArray: [MonthYearRain] = [] // rainfall stored in Core Data
    var dailyRainInMMarray: [DailyRainFall] = [] // rainfall stored in Core Data
    var yearsToSim:[Int] = []
   
    
    init(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest:NSFetchRequest<MonthYearRain> = MonthYearRain.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
        
        rainfallController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let fetchDailyRainfall:NSFetchRequest<DailyRainFall> = DailyRainFall.fetchRequest()
        fetchDailyRainfall.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
        
        dailyRainController = NSFetchedResultsController(fetchRequest: fetchDailyRainfall, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.dbContext = managedObjectContext
        super.init()
        
        rainfallController.delegate = self
        dailyRainController.delegate = self
        
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
       // print(dailyRainInMMarray.count)
    }
    
   /* func AnnualWaterDemandInM3(dailyDemandArrayM3:[Double]) -> Double {
        
        var annualDemandM3 = 0.0
        
        
        for month in 0...11 {
            
            if dailyDemandArrayM3[month] != 0.0 {
                
                annualDemandM3 = annualDemandM3 + 30.4 * dailyDemandArrayM3[month] // assuming average month size
                
            }
        }
        
        return annualDemandM3
    } */
    
   /* func CanSystemMeetDemand(runOff: Double, catchAreaM2: Double, dailyDemandArrayM3:[Double]) -> Bool {
        
        // total amount of water collected in an year
        let totalWaterCollectedM3 = runOff * catchAreaM2 * AverageAnnualRainInM()
        
        if totalWaterCollectedM3 < AnnualWaterDemandInM3(dailyDemandArrayM3: dailyDemandArrayM3) {
            return  false
        } else {
            return true
        }
        
    } */
    
   /* func FindOptimumTankUsingMonthRainfall(runOff: Double, catchAreaM2: Double, volumeUnit: VolumeUnit, dailyDemandArrayM3: [Double]) -> Double {
        
        // coarse graining the rainfall to find a trial tanksize
        // which will be used to optimise tank size.
        
        // start with a trial tank size
        let trialTankM3 =  TrialTankSizeM3(runOff: runOff, catchAreaM2: catchAreaM2)
        let deltaTank = trialTankM3 / 4.0  // deltatank = trialTankM3/4
        
        // we will increase tank size till number of successful months do not increase
        var initialSuccess = 0
        var finalSuccess = 0
        var deltaSuccess = 0
        
        var tankSizeM3 = trialTankM3
        
        repeat {
            
            // increase the tank size
            tankSizeM3 = tankSizeM3 + deltaTank
            
            // calculate successfull months
            finalSuccess = SuccessfullMonths(runOff: runOff, catchAreaM2: catchAreaM2, tankSize: tankSizeM3, dailyDemandArrayM3: dailyDemandArrayM3)
           
            deltaSuccess = finalSuccess - initialSuccess
            initialSuccess = finalSuccess
            print("optimizing Tank size using monthly rainfall = ", tankSizeM3, "Succesful days = ", finalSuccess, "Initial success = ", initialSuccess)
            
        } while (deltaSuccess != 0 )
        
        
        return tankSizeM3
        
    } */
    
   /* func FindOptimumTankSize(runOff: Double, catchAreaM2: Double, volumeUnit: VolumeUnit, dailyDemandArrayM3: [Double]) -> String {
        
       // print("daily damand = ", dailyDemandArrayM3)
        // returns optimum volume in user units
        // check we have at least three years of rainfall records
        guard PastYears().count > 2 else {
            return "Not sufficient rain records."
        }
        // check if the demand can be met at all
        guard CanSystemMeetDemand(runOff: runOff, catchAreaM2: catchAreaM2, dailyDemandArrayM3: dailyDemandArrayM3) else {
            
            DispatchQueue.main.async {
                self.isSimulating = false
            }
            
            return "Demand is too large for the system"
        }
        
        // start with a trial tank size using monthly rainfall
      // let trialTankM3 =  FindOptimumTankUsingMonthRainfall(runOff: runOff, catchAreaM2: catchAreaM2, volumeUnit: volumeUnit, dailyDemandArrayM3: dailyDemandArrayM3)
       let  trialTankM3 = TrialTankSizeM3(runOff: runOff , catchAreaM2:catchAreaM2)
        // print("Trial tank size using monthly rainfall = ", trialTankM3)
        let deltaTank = trialTankM3 / 4  // deltatank = trialTankM3/4
        
        // we will increase tank size till number of successful months do not increase
        var initialSuccess = 0
        var finalSuccess = 0
        var deltaSuccess = 0
        
        var tankSizeM3 = trialTankM3
        
        repeat {
            
            // increase the tank size
            tankSizeM3 = tankSizeM3 + deltaTank
            
            // calculate successfull months
            //finalSuccess = SuccessfullMonths(runOff: runOff, catchAreaM2: catchAreaM2, tankSize: tankSizeM3)
            finalSuccess = SuccessfullDays(runOff: runOff, catchAreaM2: catchAreaM2, tankSize: tankSizeM3, dailyDemandArrayM3: dailyDemandArrayM3)
            print(tankSizeM3, finalSuccess)
            deltaSuccess = finalSuccess - initialSuccess
            initialSuccess = finalSuccess
           print("Tank size = ", tankSizeM3, "Succesful days = ", finalSuccess)
            
        } while (deltaSuccess != 0 )
        
        DispatchQueue.main.async {
            self.isSimulating = false
        }
        
        return String(format:"%.1f", Helper.FromM3toUserVolumeUnit(volume: tankSizeM3, volumeUnit: volumeUnit))
    } */
    
   /* func TrialTankSizeM3(runOff: Double, catchAreaM2:Double) -> Double {
        
        // Crude initial guess for optimization assuming six wet months
        // Underestimating tank size
        
        let tankSizeInM3 = runOff * catchAreaM2 * AverageAnnualRainInM() / 12.0
        
        return tankSizeInM3
    } */
    
    func AverageAnnualRainInM() -> Double {
        
        var avgRainfall = 0.0
        let numYear = PastYears().count
        
        for year in PastYears() {
            
            avgRainfall = avgRainfall + AnnualRainfallInMM(year: year)
        }
        
        avgRainfall = avgRainfall / Double(numYear)
        
        // convert avgRainfall from mm -> M
        
        return avgRainfall * 0.001
        
    }
    
    func AnnualRainfallInMM(year: Int) -> Double {
        
        var monthlyArray = FindMonthlyRainInMMforYear(year: year)
        
        // remove all months with rain = -1 (months for which rainfall was not downloaded)
        monthlyArray = monthlyArray.filter({$0.rainMM != -1.0})
        
        // add up monthly rainfall in mm
        let annualRain = monthlyArray.reduce(0) {$0 + $1.rainMM}
        
        return annualRain
        
    }
    
    func FindMonthlyRainInMMforYear(year: Int) -> [MonthYearRain] {
        print("Monthly rainfall records", monthRainInMMArray.count)
        var monthlyRainArray:[MonthYearRain] = []
        
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        // filter for the given year from coredata stored array
        monthlyRainArray = self.monthRainInMMArray.filter({ rain in
            
            yearPredicate.evaluate(with: rain)
            
        })
        
        // sort the array ascending month wise
        monthlyRainArray.sort{$0.month < $1.month}
        return monthlyRainArray
        
    }
    
    func MonthlyRainForYearExist(year: Int) -> Bool {
        print("checking number of years record before filter  = ", monthRainInMMArray.count)
        var monthlyRainArray:[MonthYearRain] = []
        
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        // filter for the given year from coredata stored array
        monthlyRainArray = self.monthRainInMMArray.filter({ rain in
            
            yearPredicate.evaluate(with: rain)
            
        })
        
        if monthlyRainArray.count == 12 {
            
            return true
        } else {
            return false
        }
        
       
        
        
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
    func WaterHarvestedM3In(runoff:Double, catchAreaM2:Double, month:Int, year:Int) -> Double {
        
        // month 1 = Jan
        // month 12 = Dec
        
        // get the desired months rainfall record from core data
        let monthPredicate = NSPredicate(format: "month=%i", month)
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
       
        var filterRecord = self.monthRainInMMArray.filter ({ record in
            
            compoundPredicate.evaluate(with: record)
        })
        // convert months with -1 (month not downloaded from NOAA)  rainfall to zero
       
        
        filterRecord = filterRecord.map { month in
            
            if month.rainMM == -1 {
                month.rainMM = 0
            }
            return month
        }
        // get the month's rain
        
        let waterHarvestedM3 = filterRecord[0].rainMM * 0.001 * catchAreaM2 * runoff
        
        return waterHarvestedM3
    }
    
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
    
    func SuccessfullMonths(runOff:Double, catchAreaM2: Double, tankSize: Double, dailyDemandArrayM3: [Double]) -> Int {
        
        // to see if for a given RWHS how successful is the system
        // in meeting daily demands
        
        var waterInTank:[Double] = [] // Array to store the volume of water at the end of the simulation mounth
        waterInTank.append(0.0) // Initialy the tank is empty
        
        var simMonth = 0 // number of months simulated
        // simulation starts from Jan !
        
        var netWaterInTank = 0.0 // for water balance
        
        //var numSuccesMonth = 0 // counter
        var avaialableWater = 0.0
       // var successDays = 0.0
        var successCounter = 0
        
        
        for year in PastYears() {
            
            for month in 1...12 {
                
                waterInTank.append(0.0)
                simMonth = simMonth + 1
                
                let waterHarvested = WaterHarvestedM3In(runoff:runOff , catchAreaM2: catchAreaM2, month: month, year: year)
                
                let waterDemandM3 = dailyDemandArrayM3[month - 1]
                avaialableWater = waterInTank[simMonth - 1] + waterHarvested
                
                // check if there is water demand
                /* guard waterDemandM3 != 0.0 else {
                    
                    waterInTank[simMonth] = avaialableWater
                    
                    break
                    
                } */
            
                netWaterInTank = avaialableWater - (waterDemandM3  * 30) // approx month by 30 day
                
                
                if netWaterInTank > 0 {
                    
                    // check that water stored is not greater than the tank size
                    
                    if netWaterInTank > tankSize {
                        
                        waterInTank[simMonth] = tankSize
                        
                        
                    } else {
                        
                        waterInTank[simMonth] = netWaterInTank
                    }
                   
                    
                } else {
                    
                    // tank is empty by the end of the month
                    
                    waterInTank[simMonth] = 0.0
                    
                }
                
                // calculate successful days if there is demand in the month
                
                if waterDemandM3 != 0 {
                    if netWaterInTank > 0 {
                        // we could meet demand for all the thirty days
                        successCounter = successCounter + 30
                    } else {
                        successCounter = Int(avaialableWater/waterDemandM3)
                    }
                }
                
            }
        }
       print("Success days = ", successCounter)
        return successCounter
    }
    
    func SuccessfullDays(runOff:Double, catchAreaM2: Double, tankSize: Double, dailyDemandArrayM3: [Double]) -> Int {
        
        var waterHarvestedInMonth = 0.0
        
        var waterInTank:[Double] = [] // Array to store the volume of water at the end                            // of the simulation mounth
        
        // Initially tank is empty - for optimising tank size
        waterInTank.append(0.0)
        
        // simulation counters
        var simMonth = 0 // number of months simulated
        var succCount = 0 // number of days when demand was met
        
       
        for year in PastYears() {
           
            for month in 1...12 {
               
                waterInTank.append(0.0)
                simMonth = simMonth + 1
                
                //check did it rain in that month
                waterHarvestedInMonth = WaterHarvestedM3In(runoff: runOff, catchAreaM2: catchAreaM2, month: month, year: year)
               
                if waterHarvestedInMonth > 0  {
                    
                    // use dailyrainfall to update the budget
                   
                    let dailyBasedResult =  DailyWaterBalance(month: month, year: year, runOff: runOff, catchAreaM2: catchAreaM2, tankSizeM3: tankSize, waterAtStartOfMonthM3: waterInTank[simMonth - 1], dailyDemandArrayM3: dailyDemandArrayM3)
                    
                    waterInTank[simMonth] = dailyBasedResult.0
                    succCount = succCount + dailyBasedResult.1
                    
                 //   print(month, year, "Usinng daily records", dailyBasedResult)
                   
                } else {
                    
                    // use dry month update
                    let dryMonthResult = DryMonthWaterBalance(month: month, year: year, waterAtStartOfMonthM3: waterInTank[simMonth - 1], dailyDemandArrayM3: dailyDemandArrayM3)
                    
                    waterInTank[simMonth] = dryMonthResult.0
                    succCount = succCount + dryMonthResult.1
                  //  print( month, year, "Using Month records ", dryMonthResult)
                    
                }
                
            }
        }
        
        return succCount
    }
    
    func DailyWaterBalance(month:Int, year:Int, runOff:Double, catchAreaM2: Double, tankSizeM3: Double, waterAtStartOfMonthM3: Double, dailyDemandArrayM3: [Double]) -> (Double, Int){
        
        // Does daily waterupdate based on inital water in the tank, daily demand,
        // daily rainfall and tank size.
        // returns the amount of water in the tank at the end of the month
        // and number of successful days in the month
        
        var WaterInTank:[Double] = []
        WaterInTank.append(waterAtStartOfMonthM3) //  we start with the amount from the previous month
        
        var waterBalanceResult = 0.0 //
        var iDay = 0 // counts simulation day
        var successCount = 0
        
        for day in 1...31 {
            
            let date = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "GMT"), year: year, month: month, day: day)
            
            if date.isValidDate {
                
                iDay = iDay + 1
                WaterInTank.append(0.0)
                
                let dailyDemand = dailyDemandArrayM3[month - 1] // demand array start with 0 = jan
                let waterHarvested = DailyWaterHarvestedM3(day: day, month: month, year: year, runOff: runOff, catchAreaM2: catchAreaM2)
                waterBalanceResult = WaterInTank[iDay - 1] + waterHarvested - dailyDemand
               
              /*  guard waterBalanceResult > 0 else {
                    return (0.0, 0)
                } */
                
                if waterBalanceResult < 0 { WaterInTank[iDay] = 0.0} else {
                    
                    // if RWHS used then
                    if dailyDemand > 0 {
                        successCount = successCount + 1
                    }
                    
                    // check that water in the tank is not greater than tank size
                    if waterBalanceResult > tankSizeM3 {
                        waterBalanceResult = tankSizeM3
                    }
                    
                    // update the water balance
                    WaterInTank[iDay] = waterBalanceResult // amount of water at the end of the day
                   
                }
            }
        }
        return (WaterInTank[iDay], successCount)
        
    }
    
    func DryMonthWaterBalance(month:Int, year:Int, waterAtStartOfMonthM3: Double, dailyDemandArrayM3: [Double]) -> (Double, Int) {
        
        var waterAtEndOfMonth = 0.0
        var succDays = 0
        
        
        // to be used only for months that have no rainfall
        if waterAtStartOfMonthM3 < 0 {
            print("warning water at the start of month is wrong ",  waterAtStartOfMonthM3)
        }
        
        let numDays = Helper.DaysIn(month: month, year: year)
        let dailyDemand = dailyDemandArrayM3[month - 1]
        let monthWaterDemandM3 = dailyDemand * Double(numDays)
        
        guard monthWaterDemandM3 > 0 else {
            
            return (waterAtStartOfMonthM3, 0) // RWHS not used
        }
        
        guard waterAtStartOfMonthM3 > 0 else {
            
            return(waterAtStartOfMonthM3, 0) // empty tank - failed
        }
        
        // calculate the water balance
        
        waterAtEndOfMonth = waterAtStartOfMonthM3 - monthWaterDemandM3
        
        guard waterAtEndOfMonth > 0 else {
            
            succDays = Int(waterAtStartOfMonthM3/dailyDemand)
            return (0.0, succDays) // could not fullfil deman for whole month
        }
        succDays = numDays
        
        return (waterAtEndOfMonth, succDays)
        
    }
    
    func EstimatePerformanceForYear(runOff:Double, catchAreaM2: Double, tankSizeM3:Double, dailyDemandArrayM3: [Double]) async -> EstimateResult {
        
        // Estimates the chance of meeting monthly water demands
        
        // counters
        var waterInMonth:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
        var waterFromPreviousMonth = 0.0
        var waterInTank = 0.0
        
        // initialize the array for success to 0
        DispatchQueue.main.async {
            self.monthSuccArray = self.monthSuccArray.map {$0 * 0}
        }
        
        waterInMonth = waterInMonth.map {$0 * 0 }
        
        for year in PastYears() {
            
            for month in 1...12 {
                
                 
                // Find water from the previous month
                if month == 1 { // jan
                    waterFromPreviousMonth = waterInMonth[11] // previous month is dec
                } else {
                    waterFromPreviousMonth = waterInMonth[month-2]
                }
                
                // find water harvested
                waterInTank = WaterHarvestedM3In(runoff:runOff , catchAreaM2: catchAreaM2, month: month, year: year) + waterFromPreviousMonth
                
                // check the water in tank does not exceed tank size
                if waterInTank > tankSizeM3 {
                    waterInTank = tankSizeM3
                }
                
                // calculate water balance
                waterInTank = waterInTank - dailyDemandArrayM3[month - 1] * 30
               
                if waterInTank < 0 {
                    waterInTank = 0 // tank has run dry
                }
                
                waterInMonth[month - 1] = waterInTank
                
                if dailyDemandArrayM3[month - 1] != 0.0 && waterInTank > 0
                {
                    monthSuccArray[month - 1] = monthSuccArray[month - 1] + 1
                }
                
                
            }
            
            
        }
       // calculate results
        DispatchQueue.main.async {
            self.monthSuccArray = self.monthSuccArray.map {  Double($0)/Double(self.PastYears().count) }
        }
       
        
        let reliability = MonthlySuccessToAnnualSucess(monthSuccsArray: monthSuccArray, demandArrayM3: dailyDemandArrayM3)
       // let annualDemand = dailyDemandArrayM3.reduce(0) {$0 + $1} * 365
       
        
        let result = EstimateResult(tanksizeM3: tankSizeM3, annualSuccess: reliability)
        
        return result
    }
    
    func EstimateTanksPerformance(myTanka:SimInput) async -> Bool {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let tankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        // Estimates the chance of meeting monthly water demands
        
        // counters
        var waterInMonth:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
        var waterFromPreviousMonth = 0.0
        var waterInTank = 0.0
        
        // initialize the array for success to 0
        monthSuccArray = monthSuccArray.map {$0 * 0}
        waterInMonth = waterInMonth.map {$0 * 0 }
        
        for year in PastYears() {
            
            for month in 1...12 {
                
                 
                // Find water from the previous month
                if month == 1 { // jan
                    waterFromPreviousMonth = waterInMonth[11] // previous month is dec
                } else {
                    waterFromPreviousMonth = waterInMonth[month-2]
                }
                
                // find water harvested
                waterInTank = WaterHarvestedM3In(runoff:runOff , catchAreaM2: catchAreaM2, month: month, year: year) + waterFromPreviousMonth
                
                // calculate water balance
                waterInTank = waterInTank - dailyDemandArrayM3[month - 1] * 30
                
                if waterInTank <= 0 {
                    waterInMonth[month - 1] = 0.0 // tank is dry at the end of the month
                } else {
                    
                    if waterInTank > tankSizeM3 { waterInMonth[month - 1] = tankSizeM3} else {
                        waterInMonth[month - 1] = waterInTank
                    }
                    
                    if dailyDemandArrayM3[month - 1] != 0.0
                    {
                        monthSuccArray[month - 1] = monthSuccArray[month - 1] + 1
                    }
                    
                }
            }
            
            
        }
      
        monthSuccArray = monthSuccArray.map {  Double($0)/Double(PastYears().count) }
        print(monthSuccArray)
        return true // to inform the task is done
    }
    
    func DisplayPerformance(myTanka: SimInput) async {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        let deltaTank = userTankSizeM3 * 0.25
        
        DispatchQueue.main.async {
            self.displayResults = []
        }
        
        
        for tankStep in 0...4 {
            
            let tankSizeM3 = userTankSizeM3 + Double(tankStep) * deltaTank
            let result = await EstimatePerformanceForYear(runOff: runOff, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemandArrayM3: dailyDemandArrayM3)
            DispatchQueue.main.async {
                self.displayResults.append(result)
            }
            
            
        }
       
    }
    
    func MonthlySuccessToAnnualSucess(monthSuccsArray:[Double], demandArrayM3:[Double]) -> Int {
        
        // go through all months index
        var cumProb = 0.0
        var demandMonths = 0
        
        for mIndex in 0...11 {
            //check if there is water demand for this month
            if demandArrayM3[mIndex] != 0 {
                
                cumProb = cumProb + monthSuccsArray[mIndex]
                demandMonths = demandMonths + 1
                
            }
        }
        
        let succMeasure = (cumProb / Double(demandMonths)) * 100
        
        return Int(succMeasure)
    }
}

extension SimTanka {
    
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
    
    /// Monte Carlo Based Simulations
    
    func SimSuccDaysUsingDailyRainfall(myTanka: SimInput) -> Double {
        
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        var daysUsed = 0 // number of days tanka is used
        var succDays = 0 // number of successful days
        
        // find the past years
       // var yearArray = PastYears()
       // print("Years to sim = ",yearsToSim)
        let nConf = 1 //yearArray.count // number of simulated past records
        
        for _ in  1...nConf {
            
        
            //randomize the year to create new configuration of rainfall
            
           // yearArray.shuffle()
           // print(PastYears())
           // print(yearArray)
            
            // empty the tank
             waterInTankToday = 0.0
             waterInTankYesterday = 0.0
            
            for year in yearsToSim {
                //print("simulating ", year)
                // temp for testing
                // waterInTankToday = 0.0
                // waterInTankYesterday = 0.0
                
                for month in 1...12 {
                    
                    for day in 1...Helper.DaysIn(month: month, year: year) {
                        
                        // water harvested on the day
                        waterInTankToday = DailyWaterHarvestedM3(day: day, month: month, year: year, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                        
                        // water harvested cannot be larger than the tank size
                        waterInTankToday = min(waterInTankToday, userTankSizeM3)
                        
                        let dailyDemand = dailyDemandArrayM3[month - 1]
                        
                        if dailyDemand != 0.0 {
                            daysUsed = daysUsed + 1
                            waterInTankToday = waterInTankToday - dailyDemand
                            if waterInTankToday >= 0 {
                                succDays = succDays + 1
                            } else {
                                waterInTankToday = 0 // tank is empty
                            }
                        }
                        
                        // prepare for tomorrow
                        waterInTankYesterday = waterInTankToday
                        
                        
                    }
                    
                } // month loop
                
            }
        } // end of sum over conf loop
        
        // probability of success
        
        let probSucc = Double(succDays) / Double(daysUsed)
        
        return probSucc
       
    }
    
    func DisplayPeformanceUsingDailyRainfall(myTanka: SimInput) {
        // used for research only
        
        let userTankSizeM3 = myTanka.tankSizeM3
        let deltaTank = userTankSizeM3 * 0.25
        var trialTanka = myTanka
        
        DispatchQueue.main.async {
            self.displayResults = []
        }
        
        yearsToSim = PastYears()
       print(yearsToSim)
       print("Tank Size          Success","    "," Actual")
        
        for tankStep in 0...100 {
            
            let tankSizeM3 = userTankSizeM3 + Double(tankStep) * deltaTank
            trialTanka.tankSizeM3 = tankSizeM3
            
            let success = SimSuccDaysUsingDailyRainfall(myTanka: trialTanka)
            let performance = PerformanceUsingRainForYear(year: 2021, myTanka: trialTanka)
           
           
            let tankMsg = String(format: "%.2f", tankSizeM3)
            let msgDaily = String(format: "%.2f", success)
            let performMsg = String(format: "%.2f", performance)
            
            print(tankMsg,"            ", msgDaily, "          ", "         ", performMsg)
            
        }
        
    }
    
    func EstimatePerformanceUsingDailyRainfall(myTanka: SimInput) async {
        
        let userTankSizeM3 = myTanka.tankSizeM3
        let deltaTank = userTankSizeM3 * 0.25
        var trialTanka = myTanka
        
        DispatchQueue.main.async {
            self.displayResults = []
        }
        yearsToSim = PastYears()
        for tankStep in 0...4 {
            
            let tankSizeM3 = userTankSizeM3 + Double(tankStep) * deltaTank
            trialTanka.tankSizeM3 = tankSizeM3
            let success = SimSuccDaysUsingDailyRainfall(myTanka: trialTanka)
           
           let estimateSucc = EstimateResult(tanksizeM3: tankSizeM3, annualSuccess: Int(success * 100))
            DispatchQueue.main.async {
               // print( "Tank Size = ", tankSizeM3, "    Succ = ", success)
                self.displayResults.append(estimateSucc)
            }
        }
    }
    
    func DailyWaterHarvestedUsingAvgDailyRainfall(month: Int, year: Int, catchAreaM2: Double, runOff: Double) -> Double {
        
        // get months rainfall
        // month 1 = Jan
        // month 12 = Dec
        
        // get the desired months rainfall record from core data
        let monthPredicate = NSPredicate(format: "month=%i", month)
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
       
        var filterRecord = self.monthRainInMMArray.filter ({ record in
            
            compoundPredicate.evaluate(with: record)
        })
        // convert months with -1 (month not downloaded from NOAA)  rainfall to zero
       
        
        filterRecord = filterRecord.map { month in
            
            if month.rainMM == -1 {
                month.rainMM = 0
            }
            return month
        }
        
        // get the month's rain
        let monthlyRainMM = filterRecord[0].rainMM
        
        // number of days in month
        let numDays = Helper.DaysIn(month: month, year: year)
        
        // calculate average daily rainfall in mm
        let avgDailyRainMM = monthlyRainMM / Double(numDays)
        
        // daily water harvested
        
        return avgDailyRainMM * 0.001 * catchAreaM2 * runOff
        
        
    }
    
    func SimSuccDaysUsingAvgDailyRainfall(myTanka: SimInput) -> Double {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        var daysUsed = 0 // number of days tanka is used
        var succDays = 0 // number of successful days
        
        // find the past years
        //var yearArray = PastYears()
        
        let nConf = 1 // yearArray.count // number of simulated past records
        
        for _ in  1...nConf {
            
        
            //randomize the year to create new configuration of rainfall
            
           // yearArray.shuffle()
            
            // empty the tank
            waterInTankToday = 0.0
            waterInTankYesterday = 0.0
            
            for year in yearsToSim {
                
                //waterInTankToday = 0.0 // tmp
                //waterInTankYesterday = 0.0 // tmp
                
                for month in 1...12 {
                    
                    for _ in 1...Helper.DaysIn(month: month, year: year) {
                        
                        // water harvested on the day using avearge daily rainfall for the month
                        
                        waterInTankToday = DailyWaterHarvestedUsingAvgDailyRainfall(month: month, year: year, catchAreaM2: catchAreaM2, runOff: runOff) + waterInTankYesterday
                        // water harvested cannot be larger than the tank size
                        waterInTankToday = min(waterInTankToday, userTankSizeM3)
                        
                        let dailyDemand = dailyDemandArrayM3[month - 1]
                        
                        if dailyDemand != 0.0 {
                            daysUsed = daysUsed + 1
                            waterInTankToday = waterInTankToday - dailyDemand
                            if waterInTankToday >= 0 {
                                succDays = succDays + 1
                            } else {
                                waterInTankToday = 0 // tank is empty
                            }
                        }
                        
                        // prepare for tomorrow
                        waterInTankYesterday = waterInTankToday
                        
                        
                    }
                    
                }
                
            }
        } // end of sum over conf loop
        
        // probability of success
        
        let probSucc = Double(succDays) / Double(daysUsed)
        
        return probSucc
        
    }
    
    func PerformanceUsingRainForYear(year:Int, myTanka: SimInput) -> Double {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        var waterInTankToday = 0.0 //min(DailyWaterHarvestedUsingAvgDailyRainfall(month: 12, year: 2019, catchAreaM2: catchAreaM2, runOff: runOff) * 31, userTankSizeM3)
        var waterInTankYesterday = 0.0
        
        var daysUsed = 0 // number of days tanka is used
        var succDays = 0 // number of successful days
        
        for month in 1...12 {
            
            for day in 1...Helper.DaysIn(month: month, year: year) {
                
                // water harvested on the day
                waterInTankToday = DailyWaterHarvestedM3(day: day, month: month, year: year, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                
                // water harvested cannot be larger than the tank size
                waterInTankToday = min(waterInTankToday, userTankSizeM3)
                
                let dailyDemand = dailyDemandArrayM3[month - 1]
                
                if dailyDemand != 0.0 {
                    daysUsed = daysUsed + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0 {
                        succDays = succDays + 1
                    } else {
                        waterInTankToday = 0 // tank is empty
                    }
                }
                
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
                
            }
            
        }
       
        // probability of success
        
        let probSucc = Double(succDays) / Double(daysUsed)
        
        return probSucc
    }
    
    func AverageMonthRainfallFromPastYearsInMM() -> [Double]{
        
        // calculates the average monthly rainfall records
        // for the years given by PastYears()
        
         var avgMonthRainInMMarray = Array(repeating: 0.0, count: 12)
       
       
        let yearArray = PastYears()
        var yearsWithRecord = 0
        
        for year in yearArray {
            
            // check monthly rainfall exists for this year
            
            if MonthlyRainForYearExist(year: year) {
                
                yearsWithRecord = yearsWithRecord + 1
                
                monthRainInMMArray = FindMonthlyRainInMMforYear(year: year)
                
                for month in 1...12 {
                    
                    avgMonthRainInMMarray[month - 1] = avgMonthRainInMMarray[month - 1] + monthRainInMMArray[month-1].rainMM
                }
                
            }
            
        } // end of year loop
        
        // calculate average
        if yearsWithRecord != 0 {
            avgMonthRainInMMarray = avgMonthRainInMMarray.map( {
                $0 / Double(yearsWithRecord)
            } )
        }
        
        return avgMonthRainInMMarray
       
    }
    
    func DailyWaterHarvestedUsingPastMonthlyAvg(month:Int, year:Int, catchAreaM2:Double, runOff:Double) -> Double {
        
        let avgMonthRainMM = AverageMonthRainfallFromPastYearsInMM()
        
        // number of days in month
        let numDays = Helper.DaysIn(month: month, year: year)
        
        let avgDailyRainMM = avgMonthRainMM[month-1] / Double(numDays)
        
        return avgDailyRainMM * 0.001 * catchAreaM2 * runOff
    }
    
    func SimSuccDayUsingPastAvgMonthRain(year: Int, myTanka: SimInput) -> Double {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        var daysUsed = 0 // number of days tanka is used
        var succDays = 0 // number of successful days
        
        for month in 1...12 {
            
            for _ in 1...Helper.DaysIn(month: month, year: year) {
                
                // water harvested on the day
                waterInTankToday = DailyWaterHarvestedUsingPastMonthlyAvg(month: month, year: year, catchAreaM2: catchAreaM2, runOff: runOff) + waterInTankYesterday
                
                // water harvested cannot be larger than the tank size
                waterInTankToday = min(waterInTankToday, userTankSizeM3)
                
                let dailyDemand = dailyDemandArrayM3[month - 1]
                
                if dailyDemand != 0.0 {
                    daysUsed = daysUsed + 1
                    waterInTankToday = waterInTankToday - dailyDemand
                    if waterInTankToday >= 0 {
                        succDays = succDays + 1
                    } else {
                        waterInTankToday = 0 // tank is empty
                    }
                }
                
                // prepare for tomorrow
                waterInTankYesterday = waterInTankToday
                
                
            }
            
        }
       
        // probability of success
        
        let probSucc = Double(succDays) / Double(daysUsed)
        
        return probSucc
    }
    
}

struct EstimateResult: Hashable {
    var tanksizeM3: Double
    var annualSuccess: Int
   // var annualDemandM3: Double
}
