//
//  DisplayRainNOAAView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 10/01/22.
//
// View to display rainfall downloaded from NOAA
import SwiftUI

struct DisplayRainNOAAView: View {
    // Rainfall download
    @AppStorage("metID") private var metID = ""
    // Base year is the year from which the monthly rainfall record starts
    @AppStorage("setBaseYear") private var setBaseYear = false
    @AppStorage("baseYear") private var baseYear = 0
    @AppStorage("numberOfYearsForSim") private var numberOfYearsForSim:Int = 5
    
    @EnvironmentObject var downloadRainModel:DownLoadRainfallNOAA
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    // for detailed view of the annual rainfall 
    @State private var selectedYear: Int = 0
    @State private var showSheet = false
    
    private var maxAnnualRain = 0.0
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack (alignment:.center) {
                
                Rectangle()
                    .fill(Color.teal)
                    .frame(height: geometry.size.height * 1.0)
                
                List {
                   
                    if self.downloadRainModel.downloading {
                        ProgressView("Please wait, downloading rainfall ...")
                    }
                    
                    ForEach(pastYears(), id: \.self) { year in
                        
                        NavigationLink(destination: MonthlyRainfallView(year: .constant(year)), label:{
                            AnnualRainRowView(year: year)
                        })
                        /*
                        HStack{
                            AnnualRainRowView(year: year)
                        }.onTapGesture {
                            self.selectedYear = year
                            self.showSheet = true
                        }
                        .listRowBackground(Color.teal) */
                       
                        
                        
                    }
                }.listStyle(PlainListStyle())
                    .sheet(isPresented: $showSheet) {
                        MonthlyRainfallView(year: $selectedYear)
                    }
                    .onAppear{
                   
                    checkForBaseYear()
                    
                }.task {
                   await fetchRainfall()
                }
                .frame(height: geometry.size.height * 0.9)
                }
            
        }
    }
}

extension DisplayRainNOAAView {
    
    func checkForBaseYear() {
        print("number of years for sim = ", numberOfYearsForSim)
        if !setBaseYear {
            // find current year
            let today = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: today)
            self.baseYear = year - numberOfYearsForSim //
            self.setBaseYear = true
        }
       
    }
    
    
    /*
    func displayRainfallForYear(year:Int) {
        
        let numberOfRecords = self.downloadRainModel.FindMonthlyRainForYear(year: year).count
        
        if numberOfRecords != 0 {
            // display
        } else {
            // download
        }
    } */
    
    func pastYears() -> [Int] {
        
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
    
    func fetchRainfall() async {
        
        // check if we have downloaded any rainfall records
        if downloadRainModel.rainArrayForViews.isEmpty {
            for year in pastYears() {
                print("Downloading for  year ", year)
                await downloadRainModel.NewDownloadMonthlyRainFor(year: year, metStationID: self.metID)
            }
        } else {
            
            print("you have downloaded rainfall data till the current year")
        }
        
        // check if we have rainfall records for all the past year
        for year in pastYears() {
            
            if downloadRainModel.FindMonthlyRainForYear(year: year).isEmpty {
                print("Downloading for  year ", year)
                await downloadRainModel.NewDownloadMonthlyRainFor(year: year, metStationID: self.metID)
            }
            
            if downloadRainModel.FindMonthlyRainForYear(year: year).count != 12 {
                
                // find the months for which don't have record
                for month in 1...12 {
                    if !downloadRainModel.RainForMonthYear(month: month, year: year) {
                        // fetch rainfall for this month
                        await downloadRainModel.UpdateMonthRainfallForYear(month: month, year: year, metStationID: metID)
                    }
                }
            }
        }
        
       
    }
}

struct DisplayRainNOAAView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        DisplayRainNOAAView()
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
    }
}
