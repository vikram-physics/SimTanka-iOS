//
//  DownLoadRainfall.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 13/12/21.
//

import Foundation
import CoreData
import SwiftUI
// Main class for downloading monthly rainfall from NOAA
// Uses async/await
// Saves to Core Data

class DownLoadRainfallNOAA: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @AppStorage("baseYear") private var baseYear = 0
    // for core data
    private let rainfallController: NSFetchedResultsController<MonthYearRain>
    private let dailyRainController: NSFetchedResultsController<DailyRainFall>
    private let dbContext: NSManagedObjectContext
    
    @Published var rainArrayForViews: [MonthYearRain] = []
    
    var dailyRainInMMarray: [DailyRainFall] = [] // Rainfall stored in Core Data
    
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
        
        do {
            try rainfallController.performFetch()
            rainArrayForViews = rainfallController.fetchedObjects ?? []
        } catch {
            print("Could not fetch monthly rainfall records")
        }
        
        do {
            try dailyRainController.performFetch()
            dailyRainInMMarray = dailyRainController.fetchedObjects ?? []
        } catch {
            print("Could not fetch daily rainfall records")
        }
    }
    
    @Published var downloading = false
    @Published var downloadMsg = " "
    
    func CreateURLRequestFor(_ month:Int, _ year: Int, _ metStationID: String) -> URLRequest{
        
        // create start date
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let startDate = calendar.date(from: dateComponents)!
        
        // convert start date into string
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        let startString = startDateFormatter.string(from: startDate)
        
        // find the number of days
        let interval = calendar.dateInterval(of: .month, for: startDate)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end)
        
        // create end date
        let endDateComponents = DateComponents(year: year, month: month, day: days.day)
        let endDate = calendar.date(from: endDateComponents)!
        
        // convert end date into string
        let endString = startDateFormatter.string(from: endDate)
        
        // creating NOAA query
        //base URL
        // let baseURL = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?")!
        let baseURL = URL(string: "https://www.ncei.noaa.gov/access/services/data/v1?")!
        // create a query
        let query: [String:String] = [
            "datasetid": "daily-summaries", // GHCND was for ncdc
            "datatypeid": "PRCP",
            "limit":"365",
            "stationid": metStationID,
            "startdate": startString,
            "enddate": endString
        ]
        
        let url = baseURL.withQueries(query)!

        // url request
        var request = URLRequest(url: url)
        let token = ""
               
        request.addValue(token, forHTTPHeaderField: "token")
        
        return request
        
    }
    
   
    
    func NewFetchMonthlyRainInMM(month:Int, year:Int, metStationID: String)  async throws -> [DailyRainfallNOAA]{
        
        // downloads the daily rainfall data for a given month
        //
        let request = CreateURLRequestFor(month, year, metStationID)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      DispatchQueue.main.async {
                          print("no data")
                          self.downloading = false
                      }
                throw DownloadError.invalidServerResponse
            }
        print(data)
        let deCoder = JSONDecoder()
        let decodedMonthRain = try deCoder.decode(RainfallForMonth.self, from: data)
        
        let downloadedNOAARain = decodedMonthRain.results // array of DailyNOAARainfall
        
        print(downloadedNOAARain)
        return downloadedNOAARain
    }
    
    func NewDownloadMonthlyRainFor(year:Int, metStationID:String) async {
        
        DispatchQueue.main.async {
            self.downloading = true
            self.downloadMsg = "Downloading rainfall for the year: " + String(year)
        }
        
        for month in 1...12 {
            
            var rainArrayForMonth:[DailyRainfallNOAA] = []
            var monthlyRainfallExist = true
            
            do {
                rainArrayForMonth = try await NewFetchMonthlyRainInMM(month: month, year: year, metStationID: metStationID)
            } catch {
                monthlyRainfallExist = false
                print("Could not down load rainfall data for \(month) \(year) ")
            }
            
            // save the monthly rainfall
            self.SaveRainData(month: month, year:year , rainDataExists: monthlyRainfallExist, dailyRecords: rainArrayForMonth)
        }
        
        DispatchQueue.main.async {
            self.downloading = false
            self.downloadMsg = "Rainfall downloaded for the year: " + String(year)
        }
    }
    
    func SaveRainData(month: Int, year:Int, rainDataExists: Bool, dailyRecords: [DailyRainfallNOAA] ) {
        
        // save in the main queue
        DispatchQueue.main.async {
            
            // check that rainfall exists for this month
            guard rainDataExists else {
                // save monthly rainfall with rain = 0
                self.SaveRainfalData(month: month, year: year, rainInMM: 0.0)
                return
            }
            
            // calculate monthly rainfall in mm
            let monthlyRain = dailyRecords.reduce(0) {
                $0 + $1.rainfall
            }
            let monthlyRainMM = Double(monthlyRain) / 10.0 // from 1/10 mm -> mm
            
            self.SaveRainfalData(month: month, year: year, rainInMM: monthlyRainMM)
            
            // save the daily records only if the month was not dry
            
            guard monthlyRain != 0 else {
                return
            }
            
            for rainRecord in dailyRecords {
                
                // create new record
                let newRecord = DailyRainFall(context: self.dbContext)
                
                // store
                newRecord.day = Int32(rainRecord.day)!
                newRecord.month = Int32(rainRecord.month)!
                newRecord.year = Int32(rainRecord.year)!
                // store rainfall in mm
                newRecord.rainfallmm = Int32(Double(rainRecord.rainfall) / 10.0 )
               // print(rainRecord)
                
                // try and save the record
               do {
                    try self.dbContext.save()
                } catch {
                    print("Daily rainfall record could not be saved")
                    print(rainRecord)
                   
                }
                
            }
        }
    }
    
  
    
    func UpdateMonthRainfallForYear(month:Int, year:Int, metStationID:String) async {
        
        DispatchQueue.main.async {
            self.downloading = true
            self.downloadMsg = "Downloading rainfall for the year: " + String(year) + String(month)
        }
        
        var rainArrayForMonth:[DailyRainfallNOAA] = []
        var monthlyRainfallExist = true
        
        do {
            rainArrayForMonth = try await NewFetchMonthlyRainInMM(month: month, year: year, metStationID: metStationID)
        } catch {
            monthlyRainfallExist = false
            print("Could not down load rainfall data for \(month) \(year) ")
        }
        
        // save the monthly rainfall
        self.SaveRainData(month: month, year:year , rainDataExists: monthlyRainfallExist, dailyRecords: rainArrayForMonth)
        
        DispatchQueue.main.async {
            
            self.downloading = false
            self.downloadMsg = "Finished downloading"
        }
        
    }
    
    func SaveRainfalData(month:Int, year:Int, rainInMM: Double) {
        
       
        
        // create new record
        let newRecord = MonthYearRain(context: self.dbContext)
        
        // store month
        newRecord.month = Int64(month)
        
        // store year
        newRecord.year = Int64(year)
        
        // store rainfall in mm
        newRecord.rainMM = rainInMM
        
        // try and save the record
        do {
            try self.dbContext.save()
        } catch {
            print("Monthly rainfall record could not be saved")
        }
        
    }
    
    func FindMonthlyRainForYear(year: Int) -> [MonthYearRain] {
        
        var monthlyRainArray:[MonthYearRain] = []
        
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        // filter for the given year from coredata stored array
        monthlyRainArray = self.rainArrayForViews.filter({ rain in
            
            yearPredicate.evaluate(with: rain)
            
        })
        
        // sort the array ascending month wise
        monthlyRainArray.sort{$0.month < $1.month}
        
        return monthlyRainArray
        
    }
    
    func RainForView(year:Int, rainUnit: RainfallUnit) -> [RainModelView] {
        
        // return an array for displaying rainfall in users unit
        
        
        // get the rainfall from coredata
        let downloadedRain = FindMonthlyRainForYear(year: year)
        // get the max rainfall in mm
        let maxMonthRainMM = MaxMonthRain(year: year)
        // array to be returned
        var viewArray:[RainModelView] = []
        var viewRecord = RainModelView(year: "", month: "", rainInUserUnit: "", normRainMM: 1.0)
        
        for record in downloadedRain {
            viewRecord.year = String(record.year)
            viewRecord.month = String(Helper.intMonthToShortString(monthInt: Int(record.month)))
            if record.rainMM == -1 {
                // month for which rainfall was not downloaded from NOAA
                viewRecord.rainInUserUnit = ""
                viewRecord.normRainMM = 0
            } else {
                viewRecord.rainInUserUnit = Helper.rainStringInUnitsfromMM(rain: record.rainMM , userRainUnits: rainUnit)
                if maxMonthRainMM != 0.0 {
                    viewRecord.normRainMM = record.rainMM / maxMonthRainMM
                } else {
                    viewRecord.normRainMM = record.rainMM
                }
            }
            
            
          
            viewArray.append(viewRecord)

            
        }
        
        return viewArray
        
    }
    
    func AnnualRainYear(year:Int, rainUnit: RainfallUnit) -> String {
        
        // returns the annual rainfall in users unit for the view
        
        var rainInUnit = ""
        
        var monthlyArray = FindMonthlyRainForYear(year: year)
        
        // remove all months with rain = -1 (months for which rainfall was not downloaded)
        monthlyArray = monthlyArray.filter({$0.rainMM != -1.0})
        
        // add up monthly rainfall in mm
        let annualRain = monthlyArray.reduce(0) {$0 + $1.rainMM}
        
        rainInUnit = Helper.rainStringInUnitsfromMM(rain: annualRain, userRainUnits: rainUnit)
        
        return rainInUnit
    }
    
    func AnnualRainInMM(year:Int) -> Double {
        
        var monthlyArray = FindMonthlyRainForYear(year: year)
        
        // remove all months with rain = -1 (months for which rainfall was not downloaded)
        monthlyArray = monthlyArray.filter({$0.rainMM != -1.0})
        
        // add up monthly rainfall in mm
        let annualRain = monthlyArray.reduce(0) {$0 + $1.rainMM}
        
        return annualRain
    }
    
    func MaxAnnualRain() -> Double {
        
        // for plotting annual rainfall
        var annualRainArray:[Double] = []
        var annualRain:Double = 0.0
        
        for year in PastYears(){
            
            annualRain = self.AnnualRainInMM(year: year)
            annualRainArray.append(annualRain)
            
        }
        
        // find the maximum annual rainfall
        return  annualRainArray.map {$0}.max() ?? 0.0
        
    }
    
    func NormAnnualRain(year:Int) -> Double {
        
        // returns normalize annualrain in mm - normalized with respect to the max past annual rainfall
        let maxAnnualRain = MaxAnnualRain()
        guard maxAnnualRain != 0.0 else {
            return AnnualRainInMM(year: year)
        }
        
        return AnnualRainInMM(year: year) / maxAnnualRain
    }
    
    func PastYears() -> [Int] {
        
        // creates an array of years from the base year to the current year - 1
        
        // current year
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today) - 1
        
        // array for storing the years
        var yearsArray:[Int] = []
        
        for n in baseYear...year {
            yearsArray.append(n)
        }
        
        let sortedYear = yearsArray.sorted {$0 > $1}
        
        return sortedYear
    }
    
    func RainForMonthYear(month:Int, year:Int) -> Bool {
        
        // checks if monthy record exists
        // if the record exists then returns true
        var rainArray:[MonthYearRain] = []
        
        let monthPredicate = NSPredicate(format: "month=%i", month)
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
        
        rainArray = self.rainArrayForViews.filter ({ record in
            
            compoundPredicate.evaluate(with: record)
        })
        
        if rainArray.count != 0 {
            return true 
        }
        return false
    }
    
    func MaxMonthRain(year:Int) -> Double {
        
        //obtain the rainfall for the year
        let monthlyRain = self.FindMonthlyRainForYear(year: year)
        
        // find the max rainfall
        return monthlyRain.map {$0.rainMM}.max() ?? 0.0
    }
    
    func FindRainInMMfor(day:Int, month: Int, year: Int) -> Double {
        
        // month 1 = Jan
        // month 12 = Dec
        
        var dailyRainMM = 0.0
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
            
            dailyRainMM = Double(filterDailyRecord[0].rainfallmm)
        } else {
            
            dailyRainMM = 0 // assume no rainfall for the day for which record is not there
        }
        
        return dailyRainMM
    }
    
    func DailyRainInMmForMonthArray(year:Int, month: Int) -> [Double]{
        
        // returns an array of daily rainfall for a given month in a given year
        
        var dailyRainMMarray:[Double] = []
        
        
        for day in 1...Helper.DaysIn(month: month, year: year) {
            
            let daiyRainMM = FindRainInMMfor(day: day, month: month , year: year)
            dailyRainMMarray.append(daiyRainMM)
            //print("year = ", year, "month = ", month, "rain = ", daiyRainMM)
        }
        
        return dailyRainMMarray
        
    }
    
    func DailyRainForView(year: Int, month: Int, rainUnit: RainfallUnit) -> [DailyRainViewModel] {
        
        let dailyRainfallArray = DailyRainInMmForMonthArray(year: year, month: month)
        
        // find maximum daily rainfall
        
        let maxDailyRain = dailyRainfallArray.max() ?? 0.0
        
        // Array to be returned
        var dailyViewArray: [DailyRainViewModel] = []
        
        var dayString = ""
        var dailyRainMM = 0.0
        var normDailyRain = 0.0
        var dailyRainInUserunit = ""
        
        for day in 1...Helper.DaysIn(month: month, year: year) {
            
            dayString = String(day)
            dailyRainMM = dailyRainfallArray[day-1]
            if maxDailyRain != 0.0 {
                 normDailyRain = dailyRainMM/maxDailyRain
            } else {
                normDailyRain = 0.0
            }
            dailyRainInUserunit = Helper.rainStringInUnitsfromMM(rain: dailyRainMM, userRainUnits: rainUnit)
            let newViewRecord = DailyRainViewModel(dayStr: dayString, normDailyRain: normDailyRain, dailyRainUserUnitStr: dailyRainInUserunit)
            dailyViewArray.append(newViewRecord)
        }
        
        return dailyViewArray
        
    }
    enum DownloadError: Error {
        
        case invalidServerResponse
        case noResult
        
    }
    
}

extension DownLoadRainfallNOAA {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard let fetchedRainfall = controller.fetchedObjects as? [MonthYearRain] else {
            return
        }
        rainArrayForViews = fetchedRainfall
    }
}

struct RainMonthYearInMM {
    var month: Int
    var year: Int
    var rainInMM: Double?
}

struct RainModelView: Hashable {
    
    var year: String
    var month: String
    var rainInUserUnit: String
    var normRainMM: Double // for plotting
}

struct DailyRainViewModel: Hashable {
    var dayStr: String
    var normDailyRain: Double
    var dailyRainUserUnitStr: String
}




extension URL {
    func withQueries(_ queries: [String:String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1)}
        return components?.url
    }
}
