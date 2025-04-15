//
//  PostView.swift
//  Forum (iOS)
//
//  Created by Cem Beyenal on 9/23/24.
//  Updated on 10/18/24 to fix alignment issues with single posts and ensure line visibility.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


// Define a struct that conforms to the View protocol to display posts.
struct PostView: View {
    // Holds an array of Post objects that this view will display.
    @Binding var posts: [Post]
    var locationCategory: LocationCategory
    var showCategory: Bool = false
    
    // Access the device's color scheme setting to adapt the UI appropriately.
    @Environment(\.colorScheme) var colorScheme
    
    // State for managing location selection to pass to a map view.
    @State private var selectedLocation: LocationWrapper?
    
    @State private var selectedUserId: String?
    @State private var showProfilePage = false
    //@State private var selectedPage: String?
    
    
    var body: some View {
            
            let filteredPosts = posts.filter { $0.locationCategory == locationCategory } // filter posts here
            // Determine the background color based on the color scheme.
            let postBackgroundColor = colorScheme == .dark ? Color("PostBackgroundDarkMode") : Color("PostBackgroundLightMode")
            
            // GeometryReader is used to manage layout sizes dynamically.
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0) // Placeholder for layout tracking without actual visibility.
            
            // Loop over each post using its index to maintain uniqueness.
            ForEach(posts, id: \.id) { post in
                VStack(alignment: .leading) {
                    // A divider line between posts for better visual separation.
                    Divider()
                        .padding(.horizontal)
                    
                    // Horizontal stack containing the avatar and post details.
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                        
                        // Vertical stack for text content and metadata.
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(post.userName ?? "Loading...") //Show name
                                    .font(.headline)
                                    .foregroundColor(Color("Text"))
                                
                                Spacer()
                                
                                Menu {
                                    Button("Go to Profile", systemImage: "person") {
                                        goToUserProfile(post.userId) // TODO:implement
                                    }
                                    if post.userId == Auth.auth().currentUser?.uid {
                                        if #available(iOS 15.0, *) {
                                            Button("Delete Post", systemImage: "trash", role: .destructive){
                                                deletePost(post)
                                            }
                                        } else {
                                            Button(action: {
                                                deletePost(post)
                                            }) {
                                                HStack {
                                                    Image(systemName: "trash")
                                                    Text("Delete Post")
                                                }
                                                .foregroundColor(.red) // Manually apply a destructive color for iOS 14 and below
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 5)
                                }
                            }
                            
                            if showCategory { //Show category only if `showCategory` is true
                                Text("\(post.locationCategory.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(post.content) // Use `post`, not `posts`
                                .font(.body)
                                .foregroundColor(Color("Text"))
                            
                            Text("\(formattedDate(post.timestamp))") // Use `post.timestamp`
                                .font(.subheadline)
                                .foregroundColor(Color("Text"))
                            
                            

                            // Optionally display location if it exists.
                            if post.locationVisible, let location = post.location { // Use `post.location`
                                Text("(\(location.latitude), \(location.longitude))")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .opacity(0.8)
                                    .onTapGesture {
                                        selectedLocation = LocationWrapper(coordinate: location.toCLLocationCoordinate2D)
                                    }
                                    .onAppear {
                                                print("DEBUG: Post \(post.id) has location \(location.latitude), \(location.longitude)")
                                            }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 10)
                .background(postBackgroundColor) // Set background color based on color scheme
            }
            .background(postBackgroundColor.edgesIgnoringSafeArea(.all)) // Set overall background for the view
            
            // Display the map view as a sheet when a location is selected.
            .sheet(item: $selectedLocation) { locationWrapper in
                if let coordinate = locationWrapper.coordinate {
                    MapView(coordinate: coordinate)
                }
            }
        
            .onChange(of: selectedUserId) { newValue in
                if newValue != nil {
                    showProfilePage = true
                }
            }
            
            // shows profile page
            .fullScreenCover(isPresented: $showProfilePage, onDismiss: {
                // Reset selectedUserId when the view is dismissed
                selectedUserId = nil
            }) {
                if let userId = selectedUserId {
                    ProfilePageView(posts: $posts, userId: userId)
                }
            }
        
        
        }
    
    private func deletePost(_ post: Post) {
        let db = Firestore.firestore()
        
        db.collection("Posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post succesfully deleted!")
                // Directly update the posts array after deletion
                DispatchQueue.main.async {
                    withAnimation {
                        posts.removeAll { $0.id == post.id }
                    }
                }
            }
        }
    }
    
    private func goToUserProfile(_ userId: String) {
        DispatchQueue.main.async {
            self.selectedUserId = userId
        }
    }
    
}

// A helper function to format dates in a readable format.
private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
