//
//  SpeedTimestamp.swift
//  CuentaKM
//
//  Created by Sergio on 08/07/22.
//

import Foundation

struct SpeedTimestamp: Identifiable {
    var id: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self.timestamp)
    }
    let speed: Double
    let timestamp: Date
}
