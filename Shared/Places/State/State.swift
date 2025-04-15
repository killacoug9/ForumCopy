//
//  State.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 6/14/24.
//

import Foundation
import SwiftUI

struct StateView: View {
    @ObservedObject private var locationManager = LocationManager.shared // Use shared instance
    @State private var tabs: [String] = ["Home", "Leaders", "Laws", "Elections", "Events"]
    @State private var activeTab: String = "Home"
    @State private var offset: CGFloat = .zero
    @Binding var posts: [Post] // Binding for posts
    @State private var showPostView: Bool = false // State to control the visibility of PostInputView
    @State private var locationCategory: LocationCategory = .state

    // For button transparency when scrolling
    @Binding var isButtonTransparent: Bool // Change from @State to @Binding to propogate up
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5 // Threshold for scrolling up to regain opacity
    
    
    var body: some View {
        if let state = locationManager.state { 
            ZStack {
                VStack {
                    TitleBar(title: state, tabs: $tabs, activeTab: $activeTab, offset: $offset)

                    GeometryReader { geometry in
                        let size = geometry.size

                        TabView(selection: $activeTab) {
                            ForEach(tabs, id: \.self) { tab in
                                ScrollView {
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                                    }
                                    .frame(height: 0) // Placeholder to track scroll
                                    
                                    VStack {
                                        switch tab {
                                        case "Home":
                                            // Filter posts for "state" location category
                                            //let statePosts = posts.filter { $0.locationCategory == locationCategory }
                                            //PostView(posts: statePosts)
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
                                            LeadersList(officeLevel: .state)
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
                                .frame(width: size.width, height: size.height) // Set the desired height (old:0.86)
                                //.offset(y: -25) // Adjust this value to lift the bottom of the frame higher
                            }
                            .overlay(GeometryReader { geo in
                                Color.clear.preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minX)
                            })
                            .frame(width: size.width, height: size.height)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
                .ignoresSafeArea(.all)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea(.all)
                
                // Add the Post button outside of the TabView
                AddPostButton(showPostView: $showPostView, posts: $posts, locationCategory: $locationCategory)
                    .opacity(isButtonTransparent ? 0.3 : 1.0) // Change opacity only when scrolling down
                    .animation(.easeInOut, value: isButtonTransparent)
            }
            .sheet(isPresented: $showPostView) {
                // Present the view for creating a new post
                PostInputView(posts: $posts, locationCategory: locationCategory)
            }
        } else {
            Text("Loading State")
                .bold()
                .padding(.top, 60)
                .padding(.leading, 25)
                .font(.system(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
