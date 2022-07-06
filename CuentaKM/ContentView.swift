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
        VStack {
            switch self.locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                Text("Authorized")
            case .denied:
                Text("Denied")
            case .notDetermined:
                Text("Not determined")
            case .restricted:
                Text("Restricted")
            @unknown default:
                Text("Unexpected authorization status: \(self.locationManager.authorizationStatus.rawValue)")
            }
        }
        .onAppear { self.locationManager.requestAlwaysAuthorization() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
