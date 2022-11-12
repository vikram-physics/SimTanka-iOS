//
//  RWHSView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 07/02/22.
//
// View for entering runoff, catch area and tank size
// Also display optimum tank size and performance


import SwiftUI

struct RWHSView: View {
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var simTanka: SimTanka
    @EnvironmentObject var demandModel:DemandModel
    
    // RWHS from app storage
    @AppStorage("runOff") var runOff = 0.0
    
    @AppStorage("catchAreaM2") private var catchAreaM2 = 0.0
    @AppStorage("tankSizeM3") private var tankSizeM3 = 0.0
    @AppStorage("setUpRWHSMsg") private var setUpRWHSMsg = ""
    @AppStorage("catchAreaSet") private var catchAreaSet = false
    @AppStorage("tankSizeSet") private var tankSizeSet = false
    
    @State private var userRunOff = RunOff.Roof
    @State private var areaString = "5000"
    @State private var tankString = " "
    
    @State private var showResult = false
    @State private var isSimulating = false
    // results
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment:.center) {
                Rectangle()
                    .fill(Color.teal)
                    .frame(height: geometry.size.height * 1.0)
                List {
                   // Spacer()
                    HStack {
                        VStack{
                            Text("Catchment:")
                            Text(userRunOff.text)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color.white)
                        }
                        
                        Spacer()
                        Text("Runoff Coeff is " + String(userRunOff.rawValue))
                            .foregroundColor(Color.white)
                    }.font(.title3)
                        .foregroundColor(.black)
                        .listRowBackground(Color.gray)
                        
                    Picker("Runoff", selection: $userRunOff){
                        ForEach(RunOff.allCases, id:\.self){
                            Text($0.text)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .listRowBackground(Color.blue)
                    .font(.title3)
                    // catchment area
                    HStack{
                        Text("Catchement Area")
                            .foregroundColor(.black)
                        Spacer()
                        TextField("Area", text: $areaString)
                            .keyboardType(.numberPad)
                            .frame(width: 100 )
                            .multilineTextAlignment(.trailing)
                            .background(Color.green)
                        Text(myTankaUnits.areaUnit.text)
                    }.listRowBackground(Color.gray)
                        .onTapGesture {
                                  self.hideKeyboard()
                                }
                        .font(.title3)
                    
                    // tank size
                    VStack{
                        HStack{
                            Text("Storage Size")
                            Spacer()
                            TextField("Volume", text: $tankString)
                                .multilineTextAlignment(.trailing)
                                .background(Color.green)
                                .keyboardType(.numberPad)
                            Text(myTankaUnits.volumeUnit.text)
                        }.onTapGesture {
                            self.hideKeyboard()
                          }
                        .font(.title3)
                    }.listRowBackground(Color.gray)
                    
                    // estimate performance
                  //  if self.estimateSetup() {
                        VStack{
                            HStack {
                                Button (action: {
                                    Task{
                                        self.isSimulating = true
                                        self.showResult = false
                                        let finished = await self.estimatePerformance()
                                        self.isSimulating = !finished
                                        self.showResult = finished
                                        // self.forResearch()
                                    }
                                     }, label: {
                                         HStack{
                                             Text(!isSimulating ? "Estimate and Optmize": "Please wait, working hard on it ...")
                                                 .font(.title3)
                                                 .frame(height:15)
                                                 .padding()
                                                 .background(Color.gray)
                                                 .foregroundColor(Color.white)
                                                 .clipShape(Capsule())
                                             Spacer()
                                             if self.isSimulating{
                                                 HStack{
                                                     ProgressView()
                                                         .frame(width: 100, height: 30)
                                                         .background(Color.green)
                                                         .cornerRadius(10)
                                                     
                                                 }
                                                
                                             }
                                         }
                                         
                                        
                                        
                                         
                                })
                            }
                        }.listRowBackground(Color.blue)
                       
                   // }
                    
                    // save
                   /* HStack{
                        Spacer()
                        Button(action: {self.setUpMessage()}, label: {
                            Label("Save", systemImage: "square.and.arrow.down.fill")
                                .font(.title3)
                                .frame(width: 200, height:15)
                                .padding()
                                .background(Color.teal)
                                .foregroundColor(Color.white)
                                .clipShape(Capsule())
                        })
                        Spacer()
                    }.listRowBackground(Color.blue) */
                    
                }.onAppear {
                    if runOff != 0 {
                        userRunOff = RunOff(rawValue: runOff ) ?? RunOff.Roof
                    }
                    
                    readCatchArea()
                    readVolume()
                }
                .onDisappear {
                    runOff = userRunOff.rawValue
                    saveCatchArea()
                    saveVolume()
                    self.setUpMessage()
                }
                .sheet(isPresented: $showResult) {
                    RwhsPerformanceView()
                        
                }
                .navigationTitle(Text("Harvesting System"))
                .listStyle(PlainListStyle())
                .frame(height: geometry.size.height * 0.7)
            }
            
        }
        
    }
}


extension RWHSView {
    
    func saveRunOff() {
        runOff = userRunOff.rawValue
    }
    
    func saveCatchArea() {
        catchAreaM2 = Helper.CatchAreaInM2From(areaString: self.areaString, areaUnit: self.myTankaUnits.areaUnit)
    }
    
    func readCatchArea () {
        areaString = Helper.AreaStringFrom(catchAreaM2: self.catchAreaM2, areaUnit: myTankaUnits.areaUnit)
    }
    
    func saveVolume() {
        tankSizeM3 = Helper.VolumeInM3From(volumeString: self.tankString, volumeUnit: myTankaUnits.volumeUnit)
    }
    
    func catchAreaEntered() -> Bool {
        
        if areaString != "" {
            return true
        } else {
            return false
        }
    }
    
    func tankSizeEntered() -> Bool {
        
        if tankString != ""{
            return true
        } else {
            return false
        }
    }
    
    func rainRecordsExist() -> Bool {
        if simTanka.PastYears().count > 2 {
            return true
        } else {
            return false
        }
    }
    
    func simSetup() -> Bool {
        
        // check if we have catch area
        guard areaString != ""  else {
            //self.catchAreaMissing = true
            return false
        }
        
        // guard if we have waterbudget
        guard demandModel.BudgetIsSet() else {
            //self.waterBudgetMissing = true
            return false
        }
        
        // rainfall records
        guard simTanka.PastYears().count > 2 else {
           // rainRecordMissing = true
            return false
        }

        return true
    }
    
    func estimateSetup() -> Bool {
        
        if simSetup() && tankString != "" {
            return true
        } else {
            return false
        }
    }
    
    func readVolume() {
        tankString = Helper.VolumeStringFrom(volumeM3: self.tankSizeM3, volumeUnit: myTankaUnits.volumeUnit)
    }
    
    
    func estimatePerformance() async -> Bool {
        // save changes
        self.saveVolume()
        self.saveCatchArea()
        
        let myTanka = SimInput(runOff: userRunOff.rawValue, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemands: demandModel.DailyDemandM3())
        
        //await self.simTanka.DisplayPerformance(myTanka: myTanka)
        await self.simTanka.EstimatePerformanceUsingDailyRainfall(myTanka: myTanka)
       
        
        return true

    }
    
    func forResearch() {
        self.saveVolume()
        self.saveCatchArea()
        
        let myTanka = SimInput(runOff: userRunOff.rawValue, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemands: demandModel.DailyDemandM3())
        
        self.simTanka.DisplayPeformanceUsingDailyRainfall(myTanka: myTanka)
        
    }
    
    func setUpMessage() {
        
        catchAreaSet = self.catchAreaEntered()
        tankSizeSet = self.tankSizeEntered()
        
        // if catch area is not set and tank size is not set
        if !catchAreaSet && !tankSizeSet {
            setUpRWHSMsg = "Please enter the catchment area and the tank size."
        }
        // if tank size is not set
        if catchAreaSet && !tankSizeSet {
            setUpRWHSMsg = "Please enter the tank size."
        }
        
        // if catch area is not set
        if !catchAreaSet && tankSizeSet {
            setUpRWHSMsg = "Please enter the catchment area."
        }
        
        // if both are set
        if catchAreaSet && tankSizeSet {
            setUpRWHSMsg = "RWHS is set."
        }
        

    }
}

struct RWHSView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    static var previews: some View {
        RWHSView()
            .environmentObject(TankaUnits())
            .environmentObject(SimTanka(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}

struct SimInput {
    var runOff: Double
    var catchAreaM2: Double
    var tankSizeM3: Double
    var dailyDemands: [Double]
}
