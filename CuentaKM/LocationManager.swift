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
    /// Publishes the last speed received, measured in kilometers per hour
    @Published var speed: Double
    
    private let locationManager: CLLocationManager
    
    /// Desired accuracy of the CLLocationManager, is set on init
    var desiredAccuracy: CLLocationAccuracy { self.locationManager.desiredAccuracy }
    
    init(
        locationManager: CLLocationManager = .init(),
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        speed: Double = 0
    ) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.speed = speed
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = desiredAccuracy
        self.locationManager.startUpdatingLocation()
    }
    
    /// Calls CLLocationManager's requestAlwaysAuthorization()
    func requestAlwaysAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let metersPerSecond = locations.last?.speed ?? 0
        self.speed = metersPerSecond * 3.600
    }
}
