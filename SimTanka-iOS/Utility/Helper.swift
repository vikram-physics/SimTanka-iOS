//
//  Helper.swift
//  SimTankaPE
//
//  Created by Vikram Vyas on 03/07/21.
//
// helper utility class

import Foundation
import CoreLocation

class Helper {
    
   static func yearOfTheRecord(date: Date) -> String {
    
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year
        
        return String(year!)
        
    }
    
    static func yearInIntForDate(date: Date) -> Int{
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year
        
        return year!
        
    }
    
   static func monthOfTheRecord(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        return monthString
    }
    
    static func monthInIntForDate(date: Date) -> Int{
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    static func rainStringInUnitsfromMM(rain: Double, userRainUnits: RainfallUnit) -> String {
        
        var rainString = 0.0
        if userRainUnits.text == "mm" {
            rainString = rain
        }
        
        if userRainUnits.text == "inches" {
            // convert from mm to inches
            rainString = rain * 0.0393700787402
        }
        
        return String(format: "%.0f", rainString)
    }
    
    static func rainInMMfromUserInputString(userRainString: String, userRainUnits: RainfallUnit) -> Double {
        
        var rainInMM = 0.0
        
        if userRainUnits.text == "mm" {
            rainInMM = Double(userRainString)!
        }
        
        if userRainUnits.text == "inches" {
            // convert inches to mm
            rainInMM = Double(userRainString)! * 25.4
            
        }
        
        return rainInMM
    }
    
    static func intMonthToShortString(monthInt: Int) -> String {
        
        switch monthInt {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default: return "Invalid Month"
        }
            
        
    }
    
    static func pastFiveYears() -> [Int] {
        
        // returns past five years from the current year
        
        var yearsArray:[Int] = []
        
        // Find the start and end year
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let startYear = year - 5
        let endYear = year - 1
        
        for n in startYear...endYear{
            yearsArray.append(n)
        }
        return yearsArray
        
    }
    
    static func CurrentYear() -> Int {
        
        // returns the current year
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        
        return year
    }
    
    static func PastFiveYearsFromBaseYear(baseYear: Int) -> [Int] {
        
        // returns past five years from the base year
        
        var yearsArray:[Int] = []
        
        let startYear = baseYear - 5
        let endYear = baseYear - 1
        
        for n in startYear...endYear{
            yearsArray.append(n)
        }
        return yearsArray
    }
    
    static func FromM3toUserVolumeUnit(volume: Double, volumeUnit: VolumeUnit) -> Double {
        
        var converFactor = 0.0
        
        switch volumeUnit.rawValue {
            
            case 0:  converFactor = 1000.0  // m3 -> Liter
            case 1: converFactor = 1.0 // m3 -> m3
            case 2: converFactor = 264.172052 // m3 -> gallons (USA)
        default: converFactor = 1.0
        }
        
        return converFactor * volume 
    }
    
    static func M3toDemandUnit(demandM3: Double, demandUnit: DemandUnit) -> Double {
        
        var converFactor = 0.0
        
        switch demandUnit.rawValue {
            
            case 0:  converFactor = 1000.0  // m3 -> Liter
            case 1: converFactor = 1.0 // m3 -> m3
            case 2: converFactor = 264.172052 // m3 -> gallons (USA)
        default: converFactor = 1.0
        }
        
        return converFactor * demandM3 
    }
    
    static func CatchAreaInM2From(areaString:String, areaUnit: AreaUnit) -> Double {
        
        // convert area in string to double
        let catchArea = Double(areaString) ?? 0.0
        
        var convertFactor = 0.0
        
        switch areaUnit.rawValue {
            case 0: convertFactor = 0.09290304 // sq feet -> m2
            case 1: convertFactor = 1 // m2 -> m2
            default: convertFactor = 1.0
            
        }
        
        return catchArea * convertFactor
    }
    
    static func AreaStringFrom (catchAreaM2: Double, areaUnit: AreaUnit) -> String {
        
        guard catchAreaM2 != 0.0 else {
            return ""
        }
        
        // convert from m2 to user unit
        
        var convertFactor = 0.0
        
        switch areaUnit.rawValue {
            
            case 0:  convertFactor = 10.7639104 // m2 -> sq feet
            case 1: convertFactor = 1.0 // m2 -> m2
            default: convertFactor = 1.0
        }
        
        let area = catchAreaM2 * convertFactor
        
        // convert to string
        
        return String(format:"%.1f", area)
        
    }
    
    static func VolumeInM3From(volumeString: String, volumeUnit: VolumeUnit) -> Double {
        
        // convert volume in string to double
       
        let volume = Double(volumeString) ?? 0.0
     
        // convert volume to user unit
        
        var convertFactor = 0.0
        
        switch volumeUnit.rawValue {
            case 0: convertFactor = 0.001 // liter -> m3
            case 1: convertFactor = 1 // m3 -> m3
            case 2: convertFactor = 0.003785411784 // gallon -> m3
            default: convertFactor = 1
        }

        return volume * convertFactor
    }
    
    static func DemandInM3From(demandString: String, demandUnit: DemandUnit) -> Double {
        
        // convert demand in string to double
        
        let demand = Double(demandString) ?? 0.0
        
        // convert demand to M3
        
        var convertFactor = 0.0
        
        switch demandUnit.rawValue {
            case 0: convertFactor = 0.001 // liter -> m3
            case 1: convertFactor = 1 // m3 -> m3
            case 2: convertFactor = 0.003785411784 // gallon -> m3
            default: convertFactor = 1
        }

        return demand * convertFactor
    }
    
    static func VolumeStringFrom(volumeM3: Double, volumeUnit:VolumeUnit) -> String {
        
        guard volumeM3 != 0.0 else  {
            
            return "0"
            
        }
        // convert from m3 to user unit
        
        var convertFactor = 0.0
        
        switch volumeUnit.rawValue {
            case 0: convertFactor = 1000.0 // m3 -> liter
            case 1: convertFactor = 1.0 // m3 -> m3
            case 2: convertFactor = 264.172052 // m3 -> gallons
            default: convertFactor = 1.0
        }
        
        let volume = volumeM3 * convertFactor
        
        return String(format:"%.1f", volume)
        
    }
    
    static func DemandStringFrom(dailyDemandM3: Double, demandUnit:DemandUnit) -> String {
        
        guard dailyDemandM3 != 0.0 else  {
            
            return "0"
            
        }
        // convert from m3 to user unit
        
        var convertFactor = 0.0
        
        switch demandUnit.rawValue {
            case 0: convertFactor = 1000.0 // m3 -> liter
            case 1: convertFactor = 1.0 // m3 -> m3
            case 2: convertFactor = 264.172052 // m3 -> gallons
            default: convertFactor = 1.0
        }
        
        let volume = dailyDemandM3 * convertFactor
        
        // convert to string
       /* if volume != 0 {
            return String(format:"%.1f", volume)
        } else {
            return " "
        } */
        
        return String(format:"%.1f", volume)
        
    }
    
    static func DaysIn(month:Int, year:Int) -> Int {
        
        let dateComponents = DateComponents(year: year , month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
       
        return range.count
    }
    
    static func PastYears(baseYear:Int) -> [Int] {
        
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
    
    static func DayFromDate(date: Date) -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    static func MonthFromDate(date: Date) -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    static func YearFromDate(date: Date) -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return components.year!
    }
    
    static func AddOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }
    
    static func DateFromDayMonthYear(day: Int, month: Int, year: Int) -> Date {
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
       // dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
       // dateComponents.hour = 8
       // dateComponents.minute = 34

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)!
    }
    
    static func LikelyHoodProbFrom(reliability: Int) -> String {
        // converts reliability in percentage to heuristic likely hood
        
        
        if reliability <= 50 {
            return "Unlikely " + String(reliability) + "%"
        } else if (reliability > 50 && reliability <= 59 ){
            return "Occassionaly " + String(reliability) + "%"
            
        } else if (reliability >= 60 && reliability <= 75) {
            return "Fair " +  String(reliability) + "%"
        } else if (reliability > 75 && reliability <= 90) {
            return "Good " +  String(reliability) + "%"
        } else {
            return "Very Good " +  String(reliability) + "%"
        }
        
      
    }
    
    static func MonthIntFromMMMstring(monthStr:String) -> Int {
        
        if monthStr == "Jan" {
            return 1
        }
        else if monthStr == "Feb" {
            return 2
        }
        else if monthStr == "Mar" {
            return 3
        }
        else if monthStr == "Apr" {
            return 4
        }
        else if monthStr == "May" {
            return 5
        }
        else if monthStr == "Jun" {
            return 6
        }
        else if monthStr == "Jul" {
            return 7
        }
        else if monthStr == "Aug" {
            return 8
        }
        else if monthStr == "Sep" {
            return 9
        }
        else if monthStr == "Oct" {
            return 10
        }
        else if monthStr == "Nov" {
            return 11
        }
        else {
            return 12
        }
       
    }
    static func DateInFuture(daysToAdd:Int) -> Date {
        let today = Date()
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)!
        
        return futureDate
    }
    
    static func DateInDayMonthStrYearFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()

                dateFormatter.dateFormat = "d MMM yyyy"

                return dateFormatter.string(from: date)
    }
    
    static func MaxDistanceToSearchForMetStation() -> CLLocationDistance {
        
        return 50 * 1000 // 50km
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

