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
    
    /// Tests that the location starts updating in the location manager init
    func testLocationManager_whenInit_startsUpdatingLocation() {
        let startUpdatingLocationExpectation = expectation(
            description: "startUpdatingLocation() called"
        )
        let mockLocationManager = MockCLLocationManager(startUpdatingLocation: {
            startUpdatingLocationExpectation.fulfill()
        })
        let _ = LocationManager(locationManager: mockLocationManager)
        wait(for: [startUpdatingLocationExpectation], timeout: 1)
    }
    
    /// Tests the original speed gets updated (in km per hour) when location is updated
    func testLocationManagerSpeed_whenLocationUpdated_isPublished() {
        var cancellables = Set<AnyCancellable>()
        var speeds: [Double] = []
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager(locationManager: mockLocationManager, speed: 5)
        locationManager.$speed.sink {
            speeds.append($0)
        }.store(in: &cancellables)
        XCTAssertEqual(speeds, [5])
        mockLocationManager.delegate?.locationManager?(mockLocationManager, didUpdateLocations: [.init(
            coordinate: .init(), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 1, timestamp: .now
        )])
        XCTAssertEqual(speeds, [5, 3.6])
    }
    
    func testLocationManagerSpeedThreshold_whenSpeedChangesEnough_isUpdated() {
        var cancellables = Set<AnyCancellable>()
        var speedThresholds: [Double] = []
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager(locationManager: mockLocationManager, speed: 0)
        locationManager.$speedThreshold.dropFirst().sink {
            speedThresholds.append($0)
        }.store(in: &cancellables)
        mockLocationManager.delegate?.locationManager?(mockLocationManager, didUpdateLocations: [.init(
            coordinate: .init(), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 1, timestamp: .now
        )])
        XCTAssertEqual(speedThresholds, [])
        mockLocationManager.delegate?.locationManager?(mockLocationManager, didUpdateLocations: [.init(
            coordinate: .init(), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 15, timestamp: .now
        )])
        XCTAssertEqual(speedThresholds, [54])
        mockLocationManager.delegate?.locationManager?(mockLocationManager, didUpdateLocations: [.init(
            coordinate: .init(), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 5, timestamp: .now
        )])
        XCTAssertEqual(speedThresholds, [54, 18])
    }
}
