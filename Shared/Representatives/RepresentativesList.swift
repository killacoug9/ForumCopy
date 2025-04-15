//
//  List.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 4/17/24.
//

import Foundation
import SwiftUI

struct RepresentativesList: View {
    @ObservedObject private var locationManager = LocationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            //                Text("Location: \(locationManager.location?.description ?? "unknown")")
            //                    .font(.headline)
            //                    .padding(.top, 12)
            
            let categorizedOfficials = locationManager.categorizeOfficials()
            if !categorizedOfficials.isEmpty {
                ForEach(OfficeLevel.allCases.reversed(), id: \.self) { level in
                    if let officials = categorizedOfficials[level], !officials.isEmpty {
                        Section(header: Text("\(renameOffice(level.rawValue))")
                            .font(.title2)
                            .padding(.vertical, 5)) {
                                ForEach(officials, id: \.name) { official in
                                    NavigationLink(destination: RepresentativeView(official: official)) {
                                        RepresentativeEntry(official: official, officeName: locationManager.office(for: official)?.name ?? "")
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Divider()
                                }
                            }
                    }
                }
            } else {
                Text("No civic info available")
                    .foregroundColor(.secondary)
            }
        }//VStack
        .padding(.horizontal)
        .accentColor(.black) // Set the accent color for all links in this VStack
        .padding(.top, 100)
    }
}
