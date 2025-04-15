//
//  File.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/1/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct Me: View {
    @State private var tabs: [String] = ["Posts", "Friends", "Near Me"]
    @State private var activeTab: String = "Posts"
    @State private var offset: CGFloat = .zero
    @State private var showPostView: Bool = false
    @State private var locationCategory: LocationCategory = .me
    @State private var friendsPosts: [Post] = []
    @Binding var posts: [Post]
    //@State private var userPosts: [Post] = []

    // For button transparency when scrolling
    @Binding var isButtonTransparent: Bool // Change from @State to @Binding to propogate up
    @State private var previousOffset: CGFloat = 0
    private let scrollThreshold: CGFloat = 5 // Threshold for scrolling up to regain opacity
    
    // Computed binding for filtering the user's posts
    private var filteredUserPosts: Binding<[Post]> {
        Binding(
            get: { posts.filter { $0.userId == Auth.auth().currentUser?.uid } },
            set: { newValue in
                posts = posts.filter { $0.userId != Auth.auth().currentUser?.uid } + newValue
            }
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                TitleBar(title: "Me", tabs: $tabs, activeTab: $activeTab, offset: $offset)
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
                                    case "Posts":
                                        //PostView(posts: userPosts, showCategory: true)
                                        PostView(posts: $posts, locationCategory: locationCategory, showCategory: true)
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
                                    case "Near Me":
                                        LeadersList(officeLevel: .local)
                                    case "Friends":
                                        //Rectangle().fill(.purple)
                                        FriendsPostTabView(friendsPosts: $friendsPosts)
                                    default:
                                        Rectangle().fill(.purple)
                                    }
                                }
                            }
                            .frame(width: size.width, height: size.height ) // Set the desired height (Was 0.86)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
        }
        .onAppear {
            fetchUserPosts() // Load user's posts when view appears
            fetchFriendPosts() // loads user's friends posts 
        }
        .sheet(isPresented: $showPostView) {
            PostInputView(posts: $posts, locationCategory: locationCategory)
        }
    }
    
    //Fetches only the logged-in user's posts
    private func fetchUserPosts() {
        guard let userId = AuthService.shared.getCurrentUser()?.uid else {
            print("Error: No logged-in user.")
            return
        }
        
        PostService.shared.fetchPostsForUser(userId: userId) { retrievedPosts in
            DispatchQueue.main.async {
                posts = posts.filter { $0.userId != userId } + retrievedPosts
            }
        }
    }
    
    private func fetchFriendPosts() {
        guard let userId = AuthService.shared.getCurrentUser()?.uid else {
            print("❌ Error: No logged-in user.")
            return
        }

        FriendService.shared.fetchFriendList(for: userId) { friendIds in
            if friendIds.isEmpty {
                print("ℹ️ No friends found.")
                DispatchQueue.main.async {
                    friendsPosts = []
                }
                return
            }

            PostService.shared.fetchPostsForUsers(userIds: friendIds) { retrievedPosts in
                DispatchQueue.main.async {
                    friendsPosts = retrievedPosts
                }
            }
        }
    }
}

struct FriendsPostTabView: View {
    @Binding var friendsPosts: [Post]

    var body: some View {
        PostView(posts: $friendsPosts, locationCategory: .me, showCategory: true)
            .padding(.top, 10)
    }
}
