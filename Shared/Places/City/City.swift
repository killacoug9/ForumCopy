//
//  City.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/1/24.
//

import Foundation
import SwiftUI

struct City: View {
    @State private var loadingText = "Loading"
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var tabs: [String] = ["Home", "Leaders", "Laws", "Elections", "Events"]
    @State private var activeTab: String = "Home"
    @State private var offset: CGFloat = .zero

    @Binding var posts: [Post] // Binding for posts
    @State private var showPostView: Bool = false // State to control the visibility of PostInputView
    @State private var locationCategory: LocationCategory = .city
    
    // For button transparency when scrolling
    @Binding var isButtonTransparent: Bool // Change from @State to @Binding to propogate up
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5 // Threshold for scrolling up to regain opacity

    var body: some View {
        if let city = locationManager.city {
            ZStack {
                VStack {
                    TitleBar(title: city, tabs: $tabs, activeTab: $activeTab, offset: $offset)

                    GeometryReader { geometry in
                        let size = geometry.size

                        TabView(selection: $activeTab) {
                            ForEach(tabs, id: \.self) { tab in
                                ScrollView {
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                                    }
                                    .frame(height: 0)
                                    VStack {
                                        switch tab {
                                        case "Home":
                                            //let cityPosts = posts.filter { $0.locationCategory == locationCategory }
                                            //PostView(posts: cityPosts) // Pass filtered posts here
                                            PostView(posts: $posts, locationCategory: locationCategory)
                                                .padding(.top, 10)
                                                .onPreferenceChange(ScrollOffsetKey.self) { value in
                                                    if value >= 0 { // At the top
                                                            isButtonTransparent = false
                                                        } else {
                                                            let scrollDifference = value - previousOffset
                                                            if scrollDifference < 0 { // Scrolling down
                                                                isButtonTransparent = true
                                                            } else if scrollDifference > scrollThreshold { // Scrolling up significantly
                                                                isButtonTransparent = false
                                                            }
                                                        }
                                                        previousOffset = value
                                                }
                                        case "Leaders":
                                            LeadersList(officeLevel: .county)
                                        case "Laws":
                                            LawsList()
                                        case "Elections":
                                            ElectionsList()
                                        case "Events":
                                            Rectangle().fill(.orange)
                                        default:
                                            Rectangle().fill(.red)
                                        }
                                    }
                                }
                                .frame(width: size.width, height: size.height) // Set the desired height (old: 0.86)
                                //.offset(y: -25) // Adjust this value to lift the bottom of the frame higher
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
                .ignoresSafeArea(.all)
                .frame(maxHeight: .infinity)
                
                AddPostButton(showPostView: $showPostView, posts: $posts, locationCategory: $locationCategory)
                    .opacity(isButtonTransparent ? 0.3 : 1.0) // changes opacity when scrolling down
                    .animation(.easeInOut, value: isButtonTransparent)
            }
            .sheet(isPresented: $showPostView) {
                // Present the view for creating a new post
                PostInputView(posts: $posts, locationCategory: locationCategory)
            }
            
        } else {
            Text(loadingText)
                .bold()
                .padding(.top, 60)
                .padding(.leading, 25)
                .font(.system(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
                    animateLoadingText()
                }
        }
    }
    
    func animateLoadingText() {
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            count = (count + 1) % 4
            var dots = ""
            for _ in 0..<count {
                dots += "."
            }
            self.loadingText = "Loading\(dots)"
            
            // Optional: Stop the timer if the view deinitializes or the condition changes
            if locationManager.address != nil {
                timer.invalidate()
            }
        }
    }
}
