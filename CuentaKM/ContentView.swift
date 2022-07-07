//
//  ContentView.swift
//  CuentaKM
//
//  Created by Sergio on 05/07/22.
//

import SwiftUI

struct ContentView: View {
    /// Updates the view with CLLocationManagerDelegate events
    @StateObject var locationManager: LocationManager
    
    init(locationManager: LocationManager = .init()) {
        self._locationManager = StateObject(wrappedValue: locationManager)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
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
                    .frame(minHeight: geometry.size.height)
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
                    Text(NSLocalizedString("auth_status", comment: "") + "\(self.locationManager.authorizationStatus.rawValue)")
                        .accessibilityLabel(NSLocalizedString("auth_status", comment: ""))
                        .accessibilityValue("\(self.locationManager.authorizationStatus.rawValue)")
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .foregroundColor(.white)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(locationManager: .init(
            locationManager: MockCLLocationManager(authorizationStatus: .authorizedAlways),
            speed: 100000000
        ))
    }
}
