//
//  ProfilePageView.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 3/20/25.
//

import SwiftUI

struct ProfilePageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var tabs: [String] = ["Posts", "Friends"]
    @State private var activeTab: String = "Posts"
    @State private var offset: CGFloat = .zero
    @State private var locationCategory: LocationCategory = .state
    @State private var friendsList: [UserInfo] = []

    @Binding var posts: [Post]
    @State private var userPosts: [Post] = []
    
    var userId: String
    @State private var userName: String = "Loading..."
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    
                    Color("Cream").ignoresSafeArea()
                    let postBackgroundColor = colorScheme == .dark ? Color("PostBackgroundDarkMode") : Color("BackgroundLightMode")
                    
                    VStack {
                        // back button at the Top
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss() // iOS 14
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(.gray)
                                .font(.headline)
                            }
                            .padding(.leading, 16)
                            
                            Spacer()
                            
                            // Add Friend Button
                            Button(action: {
                                addFriend()
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 20))
                            
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color("Watermelon"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.trailing, 16)
                            
                        }
                        .zIndex(2)
                        
                        TitleBar(title: userName, tabs: $tabs, activeTab: $activeTab, offset: $offset)
                            .padding(.top, -60)
                        
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
                                                PostView(posts: $userPosts, locationCategory: locationCategory, showCategory: true)
                                                    .padding(.top, 10)
                                                    .onAppear {
                                                        fetchUserPosts()
                                                    }
                                            case "Friends":
                                                //Rectangle().fill(Color("Cream"))
                                                VStack(alignment: .leading) {
                                                    ForEach(friendsList, id: \.uid) { friend in
                                                        FriendRowView(friend: friend)
                                                    }
                                                }
                                                .padding(.top, 10)
                                                .onAppear {
                                                    print("Friends tab appeared!")
                                                    fetchFriends()
                                                }
                                            default:
                                                Rectangle().fill(.purple)
                                            }
                                        }
                                    }
                                    
                                    .frame(width: size.width, height: size.height)
                                    .background(postBackgroundColor)
                                    .edgesIgnoringSafeArea(.all)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        }
                    }
                }

                .onAppear {
                    fetchUserPosts()
                    fetchUserName()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Fetches the selected user's posts
    private func fetchUserPosts() {
        PostService.shared.fetchPostsForUser(userId: userId) { retrievedPosts in
            DispatchQueue.main.async {
                userPosts = retrievedPosts
            }
        }
    }
    
    // Fetch and display the selected user’s name
    private func fetchUserName() {
        UserService.shared.fetchUserName(for: userId) { fetchedName in
            DispatchQueue.main.async {
                self.userName = fetchedName ?? "Unknown User"
            }
        }
    }
    
    private func fetchFriends() {
        FriendService.shared.fetchFriends(for: userId) { fetchedFriends in print("fetchedFriends count: \(fetchedFriends.count)")
            for friend in fetchedFriends {
                print(" \(friend.firstName) \(friend.lastName)")
            }
            self.friendsList = fetchedFriends
        }
    }
    
    
    private func addFriend() {
        // Replace with the actual current user ID if needed
        if let user = AuthService.shared.getCurrentUser() {
            FriendService.shared.addFriend(currentUserId: user.uid, friendUserId: userId) { success in
               if success {
                   print(" Successfully added \(userName) as a friend.")
               } else {
                   print(" Failed to add friend.")
               }
           }
        }
    }
}
