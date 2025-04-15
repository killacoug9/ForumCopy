//
//  Neighborhood.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 6/14/24.
//

import SwiftUI
import CoreLocation

struct Neighborhood: View {
    @ObservedObject private var locationManager = LocationManager.shared
    
    // Bindings so parent can supply posts and transparency status
    @Binding var posts: [Post]
    @Binding var isButtonTransparent: Bool

    @State private var tabs: [String] = ["Home", "Leaders", "Laws", "Elections", "Events"]
    @State private var activeTab: String = "Home"
    @State private var offset: CGFloat = .zero
    @State private var showPostView: Bool = false
    @State private var locationCategory: LocationCategory = .neighborhood
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5
    @State private var filteredPosts: [Post] = []

    /// Extracts the Home tab content into its own function to help the compiler.
    private func homeTabContent() -> some View {
        //return PostView(posts: $posts, locationCategory: .neighborhood)
        return PostView(posts: .constant(filteredPosts), locationCategory: .neighborhood)
            .padding(.top, 10)
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                updateButtonTransparency(value: value)
            }
    }
    
    /// Updates the button transparency based on the scroll offset.
    private func updateButtonTransparency(value: CGFloat) {
        if value >= 0 {
            isButtonTransparent = false
        } else {
            let scrollDifference = value - previousOffset
            if scrollDifference < 0 {
                isButtonTransparent = true
            } else if scrollDifference > scrollThreshold {
                isButtonTransparent = false
            }
        }
        previousOffset = value
    }
    
    var body: some View {
        if locationManager.city != nil {
            ZStack {
                VStack {
                    TitleBar(
                        title: "Neighborhood",
                        tabs: $tabs,
                        activeTab: $activeTab,
                        offset: $offset
                    )
                    
                    GeometryReader { geometry in
                        let size = geometry.size
                        
                        TabView(selection: $activeTab) {
                            ForEach(tabs, id: \.self) { tab in
                                ScrollView {
                                    // Track scrolling offset to show/hide the button
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetKey.self,
                                                        value: geo.frame(in: .global).minY)
                                    }
                                    .frame(height: 0)
                                    
                                    VStack {
                                        switch tab {
                                        case "Home":
                                            homeTabContent()
                                        case "Leaders":
                                            LeadersList(officeLevel: .local)
                                        case "Laws":
                                            LawsList()
                                        case "Elections":
                                            ElectionsList()
                                        case "Events":
                                            Rectangle().fill(Color.orange)
                                        default:
                                            Rectangle().fill(Color.red)
                                        }
                                    }
                                }
                                .frame(width: size.width, height: size.height)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
                
                AddPostButton(
                    showPostView: $showPostView,
                    posts: $posts,
                    locationCategory: $locationCategory
                )
                .opacity(isButtonTransparent ? 0.3 : 1.0)
                .animation(.easeInOut, value: isButtonTransparent)
            }
            .sheet(isPresented: $showPostView) {
                PostInputView(posts: $posts, locationCategory: locationCategory)
            }
            .onAppear {
                // Fetch neighborhood posts using the existing API call.
                PostService.shared.fetchPosts(for: .neighborhood) { fetched in
                    let userCoord = locationManager.location?.coordinate ?? CLLocationCoordinate2D()
                    let nearby = fetched.filter { post in
                        guard let loc = post.location else { return false }
                        let postCoord = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                        let dist = haversineDistance(from: userCoord, to: postCoord)
                        print("🧭 Comparing user at (\(userCoord.latitude), \(userCoord.longitude)) with post at (\(postCoord.latitude), \(postCoord.longitude)) - distance: \(dist) miles")
                        return dist <= 5
                    }
                    self.posts = fetched
                    self.filteredPosts = nearby
                    print("✅ Filtered posts count: \(nearby.count)")
                }
            }
        } else {
            Text("Loading Neighborhood")
                .bold()
                .padding(.top, 60)
                .padding(.leading, 25)
                .font(.system(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    /// A local Haversine distance function (in miles).
    private func haversineDistance(from coord1: CLLocationCoordinate2D,
                                   to coord2: CLLocationCoordinate2D) -> Double {
        let R = 3958.8 // Earth's radius in miles
        let lat1 = coord1.latitude * .pi / 180
        let lon1 = coord1.longitude * .pi / 180
        let lat2 = coord2.latitude * .pi / 180
        let lon2 = coord2.longitude * .pi / 180
        
        let dlat = lat2 - lat1
        let dlon = lon2 - lon1
        
        let a = sin(dlat / 2) * sin(dlat / 2) +
                cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c  // Distance in miles
    }
}
