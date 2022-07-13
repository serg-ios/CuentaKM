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
    /// Publishes the latest big change in speed registered.
    @Published var speedThreshold: Double
    /// The latests speeds, with their timestamps
    @Published var lastSpeeds: [SpeedTimestamp]
    
    private let locationManager: CLLocationManager
    private let samplesCount: Int
    
    /// Desired accuracy of the CLLocationManager, is set on init
    var desiredAccuracy: CLLocationAccuracy { self.locationManager.desiredAccuracy }
    
    /// For testing purposes, a closure returns the current time. So dates can be injected.
    var now: () -> Date
    
    init(
        locationManager: CLLocationManager = .init(),
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        speed: Double = 0,
        now: @escaping () -> Date = { .now },
        samplesCount: Int = 10,
        lastSpeeds: [SpeedTimestamp]? = nil
    ) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.speed = max(0, speed)
        self.speedThreshold = max(0, speed)
        self.now = now
        self.samplesCount = lastSpeeds?.count ?? samplesCount
        self.lastSpeeds = lastSpeeds ?? (0..<samplesCount).map {
            .init(timestamp: now().addingTimeInterval(Double($0 - samplesCount)))
        }
        
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
        let metersPerSecond = max(0, locations.last?.speed ?? 0)
        self.speed = metersPerSecond * 3.600
        // If there is a speed change of 10 kmh, we update the threshold:
        if abs(self.speedThreshold - self.speed) >= Double(self.samplesCount) { self.speedThreshold = self.speed }
        // The array should always have `self.samplesCount` samples, dropping the eldest.
        self.lastSpeeds = self.lastSpeeds.dropFirst() + [.init(speed: self.speed, timestamp: self.now())]
    }
}
