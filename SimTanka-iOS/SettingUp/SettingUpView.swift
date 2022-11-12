//
//  SettingUpView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 16/12/21.
//

import SwiftUI

struct SettingUpView: View {
    
    @AppStorage("setLocation") private var setLocation = false
    
    
    var body: some View {
        
        NavigationView{
            List {
                NavigationLink(destination: PrefernceView(), label: {
                    Text("Units")})
                NavigationLink(destination: SetUpLocationView(), label: {
                    Text("Rainfall Data")})
                NavigationLink(destination: DailyBudgetView(), label: {
                    Text("Water Budget")})
                NavigationLink(destination: RWHSView(), label: {
                    Text("RWHS")})
                NavigationLink(destination: PerformanceView(), label: {
                    Text("Performance")})
                NavigationLink(destination: WaterDiaryListView(), label: {
                    Text("Water Diary")
                })
                
            }
        }
        
       
    }
}

struct SettingUpView_Previews: PreviewProvider {
    static var previews: some View {
        SettingUpView()
    }
}
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
