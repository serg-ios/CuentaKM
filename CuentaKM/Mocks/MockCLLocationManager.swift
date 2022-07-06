//
//  MockCLLocationManager.swift
//  CuentaKM
//
//  Created by Sergio on 06/07/22.
//

import CoreLocation
import Foundation

final class MockCLLocationManager: CLLocationManager {
    private let authorizationStatusMock: CLAuthorizationStatus
    private let requestAlwaysAuthorizationMock: () -> Void
    private let startUpdatingLocationMock: () -> Void

    private var desiredAccuracyMock: CLLocationAccuracy
    
    init(
        authorizationStatus: CLAuthorizationStatus = .notDetermined,
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyReduced,
        requestAlwaysAuthorization: @escaping () -> Void = {},
        startUpdatingLocation: @escaping () -> Void = {}
    ) {
        self.authorizationStatusMock = authorizationStatus
        self.desiredAccuracyMock = desiredAccuracy
        self.requestAlwaysAuthorizationMock = requestAlwaysAuthorization
        self.startUpdatingLocationMock = startUpdatingLocation
    }
    
    override var authorizationStatus: CLAuthorizationStatus { self.authorizationStatusMock }
    override var desiredAccuracy: CLLocationAccuracy {
        get { self.desiredAccuracyMock }
        set { self.desiredAccuracyMock = newValue }
    }
    
    override func requestAlwaysAuthorization() { self.requestAlwaysAuthorizationMock() }
    override func startUpdatingLocation() { self.startUpdatingLocationMock() }
}
