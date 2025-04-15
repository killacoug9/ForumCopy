//
//  LocationWrapper.swift
//  Forum (iOS)
//
//  Created by Cem Beyenal on 9/23/24.
//

import Foundation
import CoreLocation // For handling location data

// Wrapper for handling locations, needed for sheets or map views
struct LocationWrapper: Identifiable {
    let id = UUID() // Unique identifier for each location
    var coordinate: CLLocationCoordinate2D? // Coordinate details
}
