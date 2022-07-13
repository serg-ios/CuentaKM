//
//  LocationManager.swift
//  CuentaKM
//
//  Created by Sergio on 05/07/22.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Number of historic samples shown
    static let samplesCount = 10

    /// Publishes the location authorization status to update accordingly the views that observe this location manager
    @Published var authorizationStatus: CLAuthorizationStatus
    /// Publishes the last speed received, measured in kilometers per hour
    @Published var speed: Double
    /// Publishes the latest big change in speed registered.
    @Published var speedThreshold: Double
    /// The latests speeds, with their timestamps
    @Published var lastSpeeds: [SpeedTimestamp]
    
    private let locationManager: CLLocationManager
    
    /// Desired accuracy of the CLLocationManager, is set on init
    var desiredAccuracy: CLLocationAccuracy { self.locationManager.desiredAccuracy }
    
    init(
        locationManager: CLLocationManager = .init(),
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        speed: Double = 0,
        lastSpeeds: [SpeedTimestamp] = {
            let now = Date.now
            var samples = [SpeedTimestamp]()
            for second in 0..<LocationManager.samplesCount {
                samples.append(.init(speed: 0, timestamp: now.addingTimeInterval(-Double(second))))
            }
            return samples
        }()
    ) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.speed = max(0, speed)
        self.speedThreshold = max(0, speed)
        self.lastSpeeds = lastSpeeds
        
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
        if abs(self.speedThreshold - self.speed) >= Double(Self.samplesCount) {
            self.speedThreshold = self.speed
        }
        let samplesCount = lastSpeeds.count
        self.lastSpeeds = Array(self.lastSpeeds.dropFirst(max(0, samplesCount - Self.samplesCount - 1)))
        self.lastSpeeds.append(.init(speed: self.speed, timestamp: .now))
        self.lastSpeeds = lastSpeeds
    }
}
