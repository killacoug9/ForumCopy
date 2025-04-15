//
//  Feed.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 4/28/24.
//

import Foundation
import SwiftUI

struct Places: View {
    @Environment(\.colorScheme) var colorScheme
    @State var selectedLevel: Int = 3
    
    // Passed from parent to each view to determine if bottom bar should be transparent or not when scrolling
    @Binding var isButtonTransparent: Bool // New Binding
    
    // added 9/23
    @Binding var posts: [Post]

    var body: some View {
        VStack(alignment: .leading) {
            switch(selectedLevel) {
                case 1: 
                Me(posts: $posts, isButtonTransparent: $isButtonTransparent)
                case 2:
                Neighborhood(posts: $posts, isButtonTransparent: $isButtonTransparent)
                case 3:
                City(posts: $posts, isButtonTransparent: $isButtonTransparent)
                case 4:
                StateView(posts: $posts, isButtonTransparent: $isButtonTransparent)
                case 5:
                Nation(posts: $posts, isButtonTransparent: $isButtonTransparent)
                case 6:
                West(posts: $posts, isButtonTransparent: $isButtonTransparent)
                default:
                    Rectangle()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(colorScheme == .dark ? Color("PostBackgroundDarkMode") : Color("BackgroundLightMode"))  // Set background based on color scheme

        // When Places appears or selectedLevel changes, fetch relevant posts
        .onAppear { fetchPostsForSelectedLevel() }
        .onChange(of: selectedLevel) { _ in fetchPostsForSelectedLevel() }
        
        NavButton(selectedLevel: $selectedLevel)
    }
    
    /// Fetch posts based on selected locality
    private func fetchPostsForSelectedLevel() {
        let category = categoryForSelectedLevel(selectedLevel) // Convert level to category
        PostService.shared.fetchPosts(for: category) { retrievedPosts in
            self.posts = retrievedPosts
        }
    }
    
    /// Map selectedLevel to LocationCategory
    private func categoryForSelectedLevel(_ level: Int) -> LocationCategory {
        switch level {
            case 1: return .me
            case 2: return .neighborhood
            case 3: return .city
            case 4: return .state
            case 5: return .nation
            case 6: return .civilization
            default: return .city // Default to City if invalid
        }
    }
}
