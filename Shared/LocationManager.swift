//
//  LocationManager.swift
//  Forum
//
//  Created by Sam Russell on 12/15/23.
//

import Foundation
import CoreLocation

struct USStateMapping
{
    static let stateAbbreviationToFullName: [String: String] = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    @Published var address: String? = nil
    @Published var city: String? = nil
    @Published var state: String? = nil
    @Published var country: String? = nil
    @Published var civicInfo: CivicInfo? = nil
    private var lastUpdateTime: Date?
    
    var onLocationUpdate: ((CLLocation) -> Void)?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let now = Date()
        if lastUpdateTime == nil || now.timeIntervalSince(lastUpdateTime!) >= 300 {
            print("did update locations")
            self.location = location
            getAddress(for: location)
            lastUpdateTime = now
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func office(for official: Official) -> Office? {
        guard let civicInfo = civicInfo else { return nil }

        return civicInfo.offices.first(where: { office in
            office.officialIndices.contains(where: { $0 == civicInfo.officials.firstIndex(of: official) })
        })
    }
    
    func categorizeOfficials() -> [OfficeLevel: [Official]] {
        guard let civicInfo = civicInfo else { return [:] }

        var categorizedOfficials: [OfficeLevel: [Official]] = [:]

        for office in civicInfo.offices {
            guard let levelStr = office.levels?.first, // Assuming single level per office for simplicity
                  let level = OfficeLevel(rawValue: levelStr) else { continue }

            let officialsForOffice = office.officialIndices.compactMap { index -> Official? in
                guard index < civicInfo.officials.count else { return nil }
                return civicInfo.officials[index]
            }

            categorizedOfficials[level, default: []].append(contentsOf: officialsForOffice)
        }

        return categorizedOfficials
    }
    
    private func getAddress(for location: CLLocation) {
        print("about to get address")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    self?.address = self?.formatAddressFromPlacemark(placemark) ?? "Address not found"
                    fetchRepresentatives(for: self!.address!) { result in
                        switch result {
                        case .success(let civicInfo):
                            // Use civicInfo here
                            // If you have a state variable for CivicInfo, update it here
                             self!.civicInfo = civicInfo

                        case .failure(let error):
                            // Handle the error here
                            print("Error fetching representatives: \(error.localizedDescription)")
                            // Update your state to reflect the error if necessary
                        }
                    }
                } else if let error = error {
                    print("Geocoding failed: \(error.localizedDescription)")
                    self?.address = "Geocoding failed"
                } else {
                    self?.address = "Address not found"
                }
            }
        }
    }

    private func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var addressString = ""
        if let address = placemark.name { addressString += address }
        if let locality = placemark.locality { addressString += ", \(locality)"; self.city = locality }
        if let administrativeArea = placemark.administrativeArea { addressString += ", \(administrativeArea)"; self.state = USStateMapping.stateAbbreviationToFullName[administrativeArea] ?? administrativeArea }
        if let country = placemark.country {
            addressString += ", \(country)"
            self.country = country }
        if let postalCode = placemark.postalCode { addressString += ", \(postalCode)" }
        return addressString
    }
}
