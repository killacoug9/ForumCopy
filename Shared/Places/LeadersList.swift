//
//  LeadersList.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/31/24.
//

import Foundation
import SwiftUI

struct LeadersList: View {
    @ObservedObject private var locationManager = LocationManager.shared
    var officeLevel: OfficeLevel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 30)
                
                let categorizedOfficials = locationManager.categorizeOfficials()
                if !categorizedOfficials.isEmpty {
                    ForEach(OfficeLevel.allCases.reversed(), id: \.self) { level in

                        if let officials = categorizedOfficials[level], !officials.isEmpty, level == officeLevel {
                            Section() {
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
        }
    }
}
