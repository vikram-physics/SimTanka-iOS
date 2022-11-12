//
//  LocationManager.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 31/10/22.
//  based on
//https://www.createwithswift.com/using-the-locationbutton-in-swiftui-for-one-time-location-access/

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
       locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.location = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Handle any errors here...
        print (error)
    }
}


