//
//  File.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 6/14/24.
//

import Foundation
import SwiftUI

struct West: View {
    @Binding var posts: [Post]
    @State private var showPostView: Bool = false
    @State private var locationCategory: LocationCategory = .civilization

    // For button transparency when scrolling
    @Binding var isButtonTransparent: Bool
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5

    var body: some View {
        ZStack {
            VStack {
                Text("West")
                    .bold()
                    .padding(.top, 60)
                    .padding(.leading, 25)
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GeometryReader { geometry in
                    let size = geometry.size

                    ScrollView {
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                        }
                        .frame(height: 0) // Placeholder to track scroll
                        
                        //let civilizationPosts = posts.filter { $0.locationCategory == locationCategory 
                        //PostView(posts: civilizationPosts)
                        PostView(posts: $posts, locationCategory: locationCategory) // ✅ Fix binding issue
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
                    }
                    .frame(width: size.width, height: size.height) // Old height: 0.93
                    .offset(y: -25) // Adjust vertical positioning if needed
                    .gesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .local) // Custom drag gesture
                            .onChanged { gesture in
                                // Allow only vertical gestures
                                if abs(gesture.translation.height) > abs(gesture.translation.width) {
                                    // Let vertical gestures pass
                                }
                            }
                            .onEnded { _ in }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)

            // Floating AddPostButton with dynamic opacity
            AddPostButton(showPostView: $showPostView, posts: $posts, locationCategory: $locationCategory)
                .opacity(isButtonTransparent ? 0.3 : 1.0) // Change opacity only when scrolling down
                .animation(.easeInOut, value: isButtonTransparent)
        }
        .sheet(isPresented: $showPostView) {
            PostInputView(posts: $posts, locationCategory: locationCategory)
        }
    }
}

// PreferenceKey to capture scroll offset
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
