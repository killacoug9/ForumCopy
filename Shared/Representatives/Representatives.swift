//
//  Representatives.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 12/30/23.
//

import Foundation
import SwiftUI

private let navigationBarHeight: CGFloat = 160
private let fullyOutOffset: CGFloat = -30

struct RepresentativesView: View {
    @State private var navigationBarOffset: CGFloat = fullyOutOffset
    @State private var lastScrollOffset: CGFloat = 0
    @State private var barFullyOut: Bool = true;
    @Binding var sidebarOffset: CGFloat
    @Binding var sidebarActive: Bool
    @Binding var url: String
    
    // For button transparency when scrolling
    @Binding var isButtonTransparent: Bool // Change from @State to @Binding to propogate up
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5 // Threshold for scrolling up to regain opacity
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                
                NavBar(navigationBarOffset: $navigationBarOffset,
                       sidebarOffset: $sidebarOffset,
                       navigationBarHeight: navigationBarHeight)
                .zIndex(1)
                .onAppear {
                    self.sidebarActive = true
                }
                .onDisappear {
                    if(self.url == "Representatives") {
                        self.sidebarActive = false
                    }
                }
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear
                            .frame(width: 0, height: 1)
                            .onChange(of: geometry.frame(in: .global).minY) { newValue in
                                if(newValue > 0) { // Rubberbanding - when the scroll is artifically past the top of the screen
                                    navigationBarOffset = fullyOutOffset
                                    barFullyOut = true;
                                    return;
                                }
                                let delta = newValue - lastScrollOffset
                                lastScrollOffset = newValue
                                if(delta > 0) { // Swipe Down, Appear
                                    if(navigationBarOffset + delta < fullyOutOffset) {
                                        navigationBarOffset = navigationBarOffset + delta
                                    } else if(!barFullyOut) {
                                        navigationBarOffset = fullyOutOffset
                                        barFullyOut = true;
                                    }
                                } else { // Swipe Up, Hide
                                    let fullyRetracted = -navigationBarHeight - 5
                                    let newPosition = navigationBarOffset - abs(delta)
                                    if (fullyRetracted < newPosition) {
                                        navigationBarOffset = navigationBarOffset - abs(delta)
                                        barFullyOut = false;
                                    } else {
                                        navigationBarOffset = fullyRetracted
                                    }
                                }
                                // Update isButtonTransparent based on scroll direction
                                if newValue >= 0 { // At the top
                                    isButtonTransparent = false
                                } else {
                                    let scrollDifference = newValue - previousOffset
                                    if scrollDifference < 0 { // Scrolling down
                                        isButtonTransparent = true
                                    } else if scrollDifference > scrollThreshold { // Scrolling up significantly
                                        isButtonTransparent = false
                                    }
                                }
                                previousOffset = newValue
                            }
                    }
                    
                    RepresentativesList()
                        .background(Color("Cream"))
                }
                .background(Color("Cream"))
            }
        }
    }
}

struct RepresentativeEntry: View {
    var official: Official // Your data model
    var officeName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(official.name)
                .foregroundColor(Color("Text"))
                .fontWeight(.bold)
            Text(officeName)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

func renameOffice(_ officeName: String) -> String {
    switch officeName {
    case "country":
        return "United States of America"
    case "administrativeArea1":
        return "State"
    case "administrativeArea2":
        return "County"
    case "locality":
        return "Town"
    default:
        return officeName // Return the original name if no renaming is needed
    }
}
