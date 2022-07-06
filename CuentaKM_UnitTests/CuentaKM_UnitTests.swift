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
        let mockCLLocationManager = MockCLLocationManager(requestAlwaysAuthorizationMock: {
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
        let authorizedMockLocationManager = MockCLLocationManager(authorizationStatusMock: .authorizedAlways)
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

// MARK: - Mocks

fileprivate final class MockCLLocationManager: CLLocationManager {
    private let authorizationStatusMock: CLAuthorizationStatus
    private let requestAlwaysAuthorizationMock: () -> Void

    private var desiredAccuracyMock: CLLocationAccuracy
    
    init(
        authorizationStatusMock: CLAuthorizationStatus = .notDetermined,
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyReduced,
        requestAlwaysAuthorizationMock: @escaping () -> Void = {}
    ) {
        self.authorizationStatusMock = authorizationStatusMock
        self.desiredAccuracyMock = desiredAccuracy
        self.requestAlwaysAuthorizationMock = requestAlwaysAuthorizationMock
    }
    
    override var authorizationStatus: CLAuthorizationStatus { self.authorizationStatusMock }
    override var desiredAccuracy: CLLocationAccuracy {
        get { self.desiredAccuracyMock }
        set { self.desiredAccuracyMock = newValue }
    }
    
    override func requestAlwaysAuthorization() { self.requestAlwaysAuthorizationMock() }
}
