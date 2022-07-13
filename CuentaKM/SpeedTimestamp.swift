//
//  SpeedTimestamp.swift
//  CuentaKM
//
//  Created by Sergio on 08/07/22.
//

import Foundation

struct SpeedTimestamp: Identifiable, Equatable {
    var id: Date { self.timestamp }
    let speed: Double
    let timestamp: Date
    
    /// Timestamp expressed in HH:mm:ss format.
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self.timestamp)
    }

    internal init(speed: Double = 0, timestamp: Date = .now) {
        self.speed = speed
        self.timestamp = timestamp
    }
}
