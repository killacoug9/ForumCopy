//
//  NavButton.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/1/24.
//

import Foundation
import SwiftUI

var numButtons = 6
let iconNames = ["civilizationIcon","americanFlagIcon", "stateIcon", "cityIcon", "neighborhoodIcon", "meIcon"]

// state icons for sidebar
private let stateIcons: [String: String] = [
    "Alabama": "AlabamaIcon",
    "Alaska": "AlaskaIcon",
    "Arizona": "ArizonaIcon",
    "Arkansas": "ArkansasIcon",
    "California": "CaliforniaIcon",
    "Colorado": "ColoradoIcon",
    "Connecticut": "ConnecticutIcon",
    "Delaware": "DelawareIcon",
    "Florida": "FloridaIcon",
    "Georgia": "GeorgiaIcon",
    "Hawaii": "HawaiiIcon",
    "Idaho": "IdahoIcon",
    "Illinois": "IllinoisIcon",
    "Indiana": "IndianaIcon",
    "Iowa": "IowaIcon",
    "Kansas": "KansasIcon",
    "Kentucky": "KentuckyIcon",
    "Louisiana": "LouisianaIcon",
    "Maine": "MaineIcon",
    "Maryland": "MarylandIcon",
    "Massachusetts": "MassachusettsIcon",
    "Michigan": "MichiganIcon",
    "Minnesota": "MinnesotaIcon",
    "Mississippi": "MississippiIcon",
    "Missouri": "MissouriIcon",
    "Montana": "MontanaIcon",
    "Nebraska": "NebraskaIcon",
    "Nevada": "NevadaIcon",
    "New Hampshire": "NewHampshireIcon",
    "New Jersey": "NewJerseyIcon",
    "New Mexico": "NewMexicoIcon",
    "New York": "NewYorkIcon",
    "North Carolina": "NorthCarolinaIcon",
    "North Dakota": "NorthDakotaIcon",
    "Ohio": "OhioIcon",
    "Oklahoma": "OklahomaIcon",
    "Oregon": "OregonIcon",
    "Pennsylvania": "PennsylvaniaIcon",
    "Rhode Island": "RhodeIslandIcon",
    "South Carolina": "SouthCarolinaIcon",
    "South Dakota": "SouthDakotaIcon",
    "Tennessee": "TennesseeIcon",
    "Texas": "TexasIcon",
    "Utah": "UtahIcon",
    "Vermont": "VermontIcon",
    "Virginia": "VirginiaIcon",
    "Washington": "WashingtonIcon",
    "West Virginia": "WestVirginiaIcon",
    "Wisconsin": "WisconsinIcon",
    "Wyoming": "WyomingIcon"
]


struct NavButton: View {
    @State private var height: CGFloat = 100
    @State private var xOffset: CGFloat = 20
    @State private var yOffset: CGFloat = 0
    @State private var activeCircleIndex: Int? = -1
    @State private var hasChanged: Bool = false
    @Binding var selectedLevel: Int
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var isHoveredIndex: Int? = nil
    
   // @Binding var currentLocationCategory: LocationCategory
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 35)  // 35 is half of the initial width to ensure rounded ends
                .fill(Color.black)
                .frame(width: 60, height: height)
            
            VStack(spacing: height == 100 ? 0 : 28) {
                
                ForEach(0..<numButtons, id: \.self) { index in
                    ZStack(alignment: .center) {
                         // Hover rectangle
                         if activeCircleIndex == index {
                             ZStack {
                                 RoundedRectangle(cornerRadius: 35)
                                     .fill(Color.black)
                                     .frame(width: 180, height: 40)
                                     .offset(x: -80)
                                     .animation(.easeInOut, value: isHoveredIndex)
                                 
                                 // name display
                                 Text(getName(for: index))
                                     .foregroundColor(Color("Cream"))
                                     .font(.system(size: 17, weight: .bold))
                                     .offset(x: -100) // Adjust the position as needed
                             }
                         }
                         
                         // Icons
                        if iconNames[index] == "civilizationIcon" {
                            
                            Image("peopleIcon")
                                .renderingMode(.template) // Enables tinting
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream")) // Changes color based on hover state
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                    isHoveredIndex = hovering ? index : nil // Updates hover state
                                }
                        } else if iconNames[index] == "americanFlagIcon" {
                            
                            Image("redUSA_1")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream"))
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                   isHoveredIndex = hovering ? index : nil
                               }
                            
                        } else if iconNames[index] == "stateIcon" {
                            Image(getDynamicStateIcon()) // gets the state icon name
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream"))
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                    isHoveredIndex = hovering ? index : nil
                                }
                        } else if iconNames[index] == "cityIcon" {
                            
                            Image("cityIcon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream"))
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                   isHoveredIndex = hovering ? index : nil
                               }
                            
                        } else if iconNames[index] == "neighborhoodIcon" {
                            
                            Image("neighborhoodIcon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream"))
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                   isHoveredIndex = hovering ? index : nil
                               }
                            
                        } else if iconNames[index] == "meIcon" {
                            
                            Image("personIcon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(activeCircleIndex == index ? .red : Color("Cream"))
                                .frame(width: 25, height: 25)
                                .onHover { hovering in
                                   isHoveredIndex = hovering ? index : nil
                               }
                            
                        }
                        
                    }
                }
            }
        }

        .position(x: UIScreen.main.bounds.width + xOffset, y: (UIScreen.main.bounds.height / 4 * 3) + yOffset)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { change in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        height = CGFloat(numButtons) * 57.0
                        xOffset = -40
                        yOffset = -(26 * CGFloat(numButtons))
                    }
                    let circleHeight = height / CGFloat(numButtons)
                    let localY = change.location.y - (UIScreen.main.bounds.height / 4 * 3) - yOffset + (height / 2)
                    let activeIndex = Int(localY / circleHeight)
                    if activeIndex >= 0 && activeIndex < numButtons {
                        if activeIndex != activeCircleIndex {
                            print("active index: ", activeCircleIndex)
//                            if(activeCircleIndex != -1) {
//                                hasChanged = true
//                            }
                            activeCircleIndex = activeIndex
                            triggerHapticFeedback()
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        height = 100
                        xOffset = 20
                        yOffset = 0
//                        if(hasChanged) {
                            selectedLevel = (numButtons - 1) - (activeCircleIndex ?? 4) + 1
//                        }
//                        hasChanged = false
                        
                        // Update the current location category based on the selected level
//                                switch selectedLevel {
//                                    case 1:
//                                        currentLocationCategory = .me
//                                    case 2:
//                                        currentLocationCategory = .neighborhood
//                                    case 3:
//                                        currentLocationCategory = .city
//                                    case 4:
//                                        currentLocationCategory = .state
//                                    case 5:
//                                        currentLocationCategory = .nation
//                                    case 6:
//                                        currentLocationCategory = .west
//                                    default:
//                                        currentLocationCategory = .city // Default value
//                                }
                        
                        activeCircleIndex = -1
                    }
                }
        )
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func getName(for index: Int) -> String {
        let names = [
            "Civilization",
            "United States",
            locationManager.state ?? "State",
            locationManager.city ?? "City",
            "Neighborhood",
            "Me"
        ]
        return names[index]
    }
    
    private func getDynamicStateIcon() -> String {

        guard let locationState = locationManager.state else {
            return "mapIcon" // Default icon if state is not available
        }
        return stateIcons[locationState] ?? "mapIcon" // Return the correct icon or default if not found
    }
}
