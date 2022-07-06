//
//  LocationManager.swift
//  CuentaKM
//
//  Created by Sergio on 05/07/22.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Publishes the location authorization status to update accordingly the views that observe this location manager
    @Published var authorizationStatus: CLAuthorizationStatus
    
    private let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Calls CLLocationManager's requestAlwaysAuthorization()
    func requestAlwaysAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
}
