//
//  PerformanceView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 13/03/22.
//

import SwiftUI

struct PerformanceView: View {
    
    // colors
    var myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    var myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 1))
    var myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 1))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var demandModel:DemandModel
    @EnvironmentObject var performancdModel:PerformanceModel

    @AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    
    @State private var today = Date()
    @State private var endOfMonth = Date().endOfMonth()
    
    var futureDate = Helper.DateInFuture(daysToAdd: 30)

    
    @State private var waterInTankAtStart:Double = 0.0001 //
    @State private var tanksStep:Double = 0.1
    @State private var sliderActive: Bool = false
    
    let todayPlusOne = Helper.AddOrSubtractMonth(month: 1)
    
    // simulation display
    @State private var isSim = false
    
    // results
    @State private var displayCurrentReliability = "?" // displays reliability in meeting daily demand
    @State private var simReliabilityDone = false // simulation has ended or not
    
    @State private var displayWaterInTankOnDay30 = "?" // displays the most likely amount of water in the tank at the end of simulation period.
    
    @State private var displayWaterInTankReliability = "?"
    
    
    
    var body: some View {
        
            List{
                
             
                HStack{
                    Text("Please select the amount of water in the storage tank on \(Helper.DateInDayMonthStrYearFormat(date: today)) ").foregroundColor(.black)
                   
                }.listRowBackground(myColorTwo)
                
                HStack{
                    
                    Slider(value: $waterInTankAtStart, in: 0...tankSizeM3, onEditingChanged: {self.sliderActive = $0
                        self.resetDisplayStrings()
                        
                    }).padding(0)
                    Text(Helper.VolumeStringFrom(volumeM3: waterInTankAtStart, volumeUnit: myTankaUnits.volumeUnit))
                    Text(myTankaUnits.volumeUnit.text)
                }.listRowBackground(myColorThree)
                
                
                // displays demand and reliability of meeting the demand
                
                
                if !sliderActive {
                 
                    VStack {
                        VStack {
                            HStack{
                                Text("Daily water demand")
                                    .font(.title3)
                                    .padding()
                                    .foregroundColor(.black)
                            }
                            HStack{
                              // Spacer()
                                // display water demand of the current month
                               Text("\(Helper.monthOfTheRecord(date: today))  = \(displayDemand()) \(myTankaUnits.demandUnit.text)")
                                    .font(.system(size: 18))
                                
                                Spacer()
                                
                                
                            }
                            HStack {
                                // if next month is different from the current month
                                if Helper.monthOfTheRecord(date: today) != Helper.monthOfTheRecord(date: futureDate) {
                                    
                                    //Spacer()
                                    Text("\(Helper.monthOfTheRecord(date: futureDate))  = \(displayDemandPlusOne()) \(myTankaUnits.demandUnit.text)")
                                        .font(.system(size: 18))
                                    Spacer()
                            
                                    
                                }
                            }
                            if (self.demandForCurrentMonth() != 0.0 ) || (self.demandForMonthPlusOne() != 0.0){
                                
                                HStack{
                                    if simReliabilityDone {
                                        HStack{
                                            Text("Likely hood of meeting water demand from \(Helper.DateInDayMonthStrYearFormat(date: today)) to \(Helper.DateInDayMonthStrYearFormat(date: futureDate))")
                                        }.font(.system(size: 16))
                                        Text("\(displayCurrentReliability)")
                                            .font(.title3)
                                            .padding()
                                            .background(Rectangle().fill(Color.red).shadow(radius: 3))
                                    }
                                    
                                }
                            }
                            
                        }
                        
                       
                    }.foregroundColor(.white)
                        .font(.caption)
                        .listRowBackground(myColorTwo)
                    
                }
                
                // displays likely amount of water at the end of simulation
                if !sliderActive {
                    
                    if simReliabilityDone {
                        VStack{
                            HStack{
                                Text("Water in the tank on  \(Helper.DateInDayMonthStrYearFormat(date: futureDate))").font(.title3).foregroundColor(.black)
                                    
                            }
                            HStack{
                                Text("Minimun amount of water in the tank based on last \(displayWaterInTankReliability) years rainfall records")
                                Text("\(displayWaterInTankOnDay30)")
                                    .font(.title3)
                                    .padding()
                                    .background(Rectangle().fill(Color.red).shadow(radius: 3))
                            }
                           
                        }.listRowBackground(myColorTwo).foregroundColor(.white)
                    }
                }
                
                // button for estimating performance
                if !sliderActive {
                    HStack{
                        Button(action: {
                            Task {
                                isSim = true
                                simReliabilityDone = false
                               /* if(self.demandForCurrentMonth() != 0.0 ) || (self.demandForMonthPlusOne() != 0.0) {
                                    simReliabilityDone =  await self.meetingDemandReliability()
                                } */
                                simReliabilityDone = await self.performance30DaysInFuture()
                                self.setSimOffWithDelay()
                               
                                
                            }
                        }, label: {
                            VStack {
                                HStack{
                                    Spacer()
                                    Text("Estimate Performance")
                                        .font(.body).bold()
                                        .frame(height:8)
                                        .padding()
                                        .background(Color.purple)
                                        .foregroundColor(Color.black)
                                        .clipShape(Capsule())
                                    Spacer()
                                }
                                if isSim {
                                    HStack{
                                        Text("Estimating ...")
                                        Spacer()
                                        ProgressView()
                                            .frame(width: 100, height: 30)
                                            .background(Color.teal)
                                            .cornerRadius(10)
                                    }
                                }
                               
                            }
                           
                        })
                    }.listRowBackground(Color.teal)
                }
               
            }
            .navigationTitle(Text("Performance"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.tanksStep = self.tankSizeM3/10.0
            }
        
    }
    
   
}
    
extension PerformanceView {
    
    
    func demandForCurrentMonth() -> Double {
        
        let monthIndex = Helper.MonthFromDate(date: today) - 1
        return self.performancdModel.dailyDemandArray[monthIndex].dailyDemandM3
        
    }
    
    func demandForMonthPlusOne() -> Double {
        let monthIndex = Helper.MonthFromDate(date: todayPlusOne) - 1
        return self.performancdModel.dailyDemandArray[monthIndex].dailyDemandM3
    }
    
    func displayDemand() -> String {
        
        let monthIndex = Helper.MonthFromDate(date: today) - 1
        let dailyDemandM3 = self.performancdModel.dailyDemandArray[monthIndex].dailyDemandM3
        return Helper.DemandStringFrom(dailyDemandM3: dailyDemandM3, demandUnit: myTankaUnits.demandUnit)
        
    }
    
    func displayDemandPlusOne() -> String {
        let monthIndex = Helper.MonthFromDate(date: todayPlusOne) - 1
        let dailyDemandM3 = self.performancdModel.dailyDemandArray[monthIndex].dailyDemandM3
        return Helper.DemandStringFrom(dailyDemandM3: dailyDemandM3, demandUnit: myTankaUnits.demandUnit)
    }
    
    func meetingDemandReliability() async -> Bool {
        
       
        let reliability =  await self.performancdModel.ReliabilityForFuture30Days(intialAmountM3: waterInTankAtStart)
        
        self.displayCurrentReliability = Helper.LikelyHoodProbFrom(reliability: reliability)

        return true
        
    }
    
    func performance30DaysInFuture() async -> Bool {
        
        let result = await self.performancdModel.FuturePerformance30Days(initialAmountM3: waterInTankAtStart)
        
        // demand reliability
        if let demandReliability = result.demandReliability {
            self.displayCurrentReliability = Helper.LikelyHoodProbFrom(reliability: demandReliability)
        }
        
        // likely amount of water
        let waterInTank = result.waterInTankAtTheEnd
        self.displayWaterInTankOnDay30 = Helper.VolumeStringFrom(volumeM3: waterInTank, volumeUnit: myTankaUnits.volumeUnit) + " " + myTankaUnits.volumeUnit.text
        
        // reliability of water in tank based on number of past years used in simulation
        let waterReliabilty = result.numberOfSimYears
        self.displayWaterInTankReliability = String(waterReliabilty)
        
        return true
    }
    
 
  
    
    
    
    func resetDisplayStrings() {
        self.simReliabilityDone = false
        self.displayCurrentReliability = "?"
        self.displayWaterInTankOnDay30 = "?"
        self.displayWaterInTankReliability = "?"
       
    }
    
    func setSimOffWithDelay() {
        let delayTime = DispatchTime.now() + 0.5
    
       DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
           self.isSim = false
       })
    }
}

struct PerformanceView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    //@AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    static var previews: some View {
        PerformanceView()
            .environmentObject(TankaUnits())
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(PerformanceModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
