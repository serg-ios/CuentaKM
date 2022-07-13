//
//  ContentView.swift
//  CuentaKM
//
//  Created by Sergio on 05/07/22.
//

import Charts
import SwiftUI

struct ContentView: View {
    /// Updates the view with dark/light mode changes
    @Environment(\.colorScheme) var colorScheme
    /// Updates the view with CLLocationManagerDelegate events
    @StateObject var locationManager: LocationManager
    
    init(locationManager: LocationManager = .init()) {
        self._locationManager = StateObject(wrappedValue: locationManager)
    }
    
    var body: some View {
        VStack {
            switch self.locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                VStack {
                    Text("\(self.locationManager.speed, specifier: "%.1f")")
                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 150)))
                        .fontWeight(.heavy)
                    Text("km/h")
                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 50)))
                        .fontWeight(.bold)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("speed", comment: ""))
                .accessibilityValue(String(format: NSLocalizedString("kmh", comment: ""), self.locationManager.speed))
                Chart(self.locationManager.lastSpeeds) { element in
                    BarMark(
                        x: .value("id", element.id),
                        y: .value("speed", element.speed)
                    )
                    .cornerRadius(.infinity)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
            case .denied:
                Text("auth_status_denied")
                    .accessibilityLabel(NSLocalizedString("auth_status", comment: ""))
                    .accessibilityValue("auth_status_denied")
            case .notDetermined:
                Text("auth_status_not_determined")
                    .accessibilityLabel(NSLocalizedString("auth_status", comment: ""))
                    .accessibilityValue("auth_status_not_determined")
            case .restricted:
                Text("auth_status_restricted")
                    .accessibilityLabel(NSLocalizedString("auth_status", comment: ""))
                    .accessibilityValue("auth_status_restricted")
            @unknown default:
                let authStatusCode = "\(self.locationManager.authorizationStatus.rawValue)"
                Text(NSLocalizedString("auth_status", comment: "") + authStatusCode)
                    .accessibilityLabel(NSLocalizedString("auth_status", comment: ""))
                    .accessibilityValue("\(self.locationManager.authorizationStatus.rawValue)")
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
        .padding(.horizontal)
        .background(self.colorScheme == .dark ? .black : .white)
        .foregroundColor(self.colorScheme == .dark ? .white : .black)
        .multilineTextAlignment(.center)
        .onAppear { self.locationManager.requestAlwaysAuthorization() }
        .onChange(of: self.locationManager.speedThreshold, perform: { _ in
            UIAccessibility.post(
                notification: .announcement,
                argument: String(format: NSLocalizedString("kmh", comment: ""), self.locationManager.speed)
            )
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(locationManager: .init(
            locationManager: MockCLLocationManager(authorizationStatus: .authorizedAlways),
            speed: 10,
            lastSpeeds: {
                let now = Date.now
                return Array(repeating: 1, count: LocationManager.samplesCount).enumerated().map {
                    let speed = Double.random(in: 0...30)
                    let timestamp = now.addingTimeInterval(TimeInterval($0.offset))
                    return SpeedTimestamp(speed: speed, timestamp: timestamp)
                }
            }()
        ))
    }
}
