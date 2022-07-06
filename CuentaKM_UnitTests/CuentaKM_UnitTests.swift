//
//  CuentaKM_UnitTests.swift
//  CuentaKM_UnitTests
//
//  Created by Sergio on 05/07/22.
//

import Combine
import CoreLocation
import XCTest

@testable import CuentaKM

final class CuentaKM_UnitTests: XCTestCase {
    /// Tests that CLLocationManager's authorization is requested
    func testLocationManager_whenRequestAlwaysAuthorization_callsCLLocationManager() {
        let requestAlwaysAuthorizationExpectation = expectation(
            description: "CLLocationManager requestAlwaysAuthorization() called"
        )
        let mockCLLocationManager = MockCLLocationManager(requestAlwaysAuthorization: {
            requestAlwaysAuthorizationExpectation.fulfill()
        })
        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.requestAlwaysAuthorization()
        wait(for: [requestAlwaysAuthorizationExpectation], timeout: 1)
    }
    
    /// Tests that the location manager is CLLocationManagerDelegate and authorization changes are published
    func testLocationManagerDelegate_whenAuthorizationChanges_updatesThePublishedAuthorizationStatus() {
        var cancellables = Set<AnyCancellable>()
        var authorizationStatus: [CLAuthorizationStatus] = []
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager(locationManager: mockLocationManager)
        locationManager.$authorizationStatus.sink {
            authorizationStatus.append($0)
        }.store(in: &cancellables)
        let authorizedMockLocationManager = MockCLLocationManager(authorizationStatus: .authorizedAlways)
        XCTAssertEqual(authorizationStatus, [.notDetermined])
        mockLocationManager.delegate?.locationManagerDidChangeAuthorization?(authorizedMockLocationManager)
        XCTAssertEqual(authorizationStatus, [.notDetermined, .authorizedAlways])
    }
    
    /// Tests that the location manager's init changes the desired accuracy to "best" by default
    func testLocationManager_whenDefaultInit_setsBestDesiredAccuracy() {
        let mockLocationManager = MockCLLocationManager(desiredAccuracy: kCLLocationAccuracyReduced)
        let locationManager = LocationManager(locationManager: mockLocationManager)
        XCTAssertEqual(locationManager.desiredAccuracy, kCLLocationAccuracyBest)
    }
}
