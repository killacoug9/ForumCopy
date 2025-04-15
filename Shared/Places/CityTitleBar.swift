//
//  FeedTitleBar.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/1/24.
//

import Foundation
import SwiftUI

struct FeedTitleBar: View {
    @ObservedObject private var locationManager = LocationManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(locationManager.city ?? "Error")
                .bold()
                .padding(.top, 60)
                .padding(.leading, 25)
                .font(.system(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)  // Make Text fill the width and align it to the leading
            
            ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll view
                HStack(spacing: 20) {
                    
                    VStack(spacing: 5) {
                        Text("Home")
                        Rectangle()
                            .fill(Color("MenuSelected"))
                            .frame(height: 2)
                    }
                    VStack(spacing: 5) {
                        Text("Leaders")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 2)
                    }
                    VStack(spacing: 5) {
                        Text("Laws")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                    }
                    VStack(spacing: 5) {
                        Text("Elections")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                    }
                    VStack(spacing: 5) {
                        Text("Events")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                    }
                }
                .padding(.leading, 25)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -15)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Use maximum height and width
        .ignoresSafeArea(.all)
        .background(Color("Cream"))
    }
}
