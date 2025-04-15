//
//  Post.swift
//  Forum (iOS)
//
//  Created by Cem Beyenal on 9/23/24.
//

import FirebaseFirestore
import Foundation
import CoreLocation // for location

// Represents a single Post with content, timestamp, and optional location
struct Post: Identifiable, Codable {
    var id: String // Firestore document ID
    var userId: String
    var userName: String
    var content: String
    var timestamp: Date
    var location: LocationData? // Convert CLLocationCoordinate2D manually
    var locationCategory: LocationCategory // Category like "Neighborhood"
    var locationVisible: Bool = false 

    // Convert CLLocationCoordinate2D to a Firestore-compatible format
    struct LocationData: Codable {
        var latitude: Double
        var longitude: Double

        init(from coordinate: CLLocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }

        var toCLLocationCoordinate2D: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    // Initializer for creating a post before storing it in Firestore
    init(
            id: String = UUID().uuidString,
            userId: String,
            userName: String? = nil, // ✅ Hardcoded for now
            content: String,
            timestamp: Date,
            location: CLLocationCoordinate2D?,
            locationCategory: LocationCategory,
            locationVisible: Bool = false
        ) {
            self.id = id
            self.userId = userId
            self.userName = userName ?? "def"
            self.content = content
            self.timestamp = timestamp
            self.location = location != nil ? LocationData(from: location!) : nil
            self.locationCategory = locationCategory
            self.locationVisible = locationVisible
        }
}

enum LocationCategory: String, Codable {
    case me
    case neighborhood
    case city
    case state
    case nation
    case civilization
}
