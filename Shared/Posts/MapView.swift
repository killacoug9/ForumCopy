//
//  MapView.swift
//  Forum
//
//  Created by Cem Beyenal on 10/2/24.
//


import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode // Dismissal environment variable
    var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        ZStack(alignment: .topLeading) { // Stack to overlay the button on the map
                    // Create a Map using the coordinate
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )), showsUserLocation: true)
                        .edgesIgnoringSafeArea(.all)

                    // Back button positioned at the top left
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Text("Back")
                            .padding(10) // Less padding
                            .background(Color.blue.opacity(0.7)) // Slightly transparent for visibility
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding() // Adjust padding to keep it at the top left
                }
            }
}
