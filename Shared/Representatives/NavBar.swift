//
//  NavBar.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 12/30/23.
//

import Foundation
import SwiftUI

struct NavBar: View {
    @ObservedObject private var locationManager = LocationManager.shared
    @Environment(\.colorScheme) var colorScheme
    @Binding var navigationBarOffset: CGFloat
    @Binding var sidebarOffset: CGFloat
    @State private var imageOpacity: Double = 1.0
    @State private var tapped: Bool = false
    let navigationBarHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "aqi.low")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 27)
                    .clipShape(Circle())
                    .padding(.leading, 20)
                    .foregroundColor((sidebarOffset == 300 || tapped) ? Color("Cream") : Color("Text"))
                    .onTapGesture {
                        self.tapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.tapped = false
                        }
                        withAnimation {
                            sidebarOffset = 300
                        }
                    }

                Spacer()

                Image(colorScheme == .dark ? "ForumDark" : "Forum")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 27)
                
                Spacer()
                Spacer()
                    .frame(width: 27)
                    .padding(.trailing, 15)
            }
            .padding(.top, 80)
            .padding(.bottom, 20)
            
            Text(locationManager.address ?? "unknown")
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.bottom, 15)

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.black)
        }
        .frame(height: navigationBarHeight, alignment: .top)
        .background(Color("Watermelon"))
        .offset(y: navigationBarOffset)
        .edgesIgnoringSafeArea(.top)
    }
}
