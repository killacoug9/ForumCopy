//
//  PostService.swift
//  Forum
//
//  Created by Kyle Hawkins on 2/9/25.
//


import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class PostService {
    private let db = Firestore.firestore()
    static let shared = PostService() // Singleton
    
    private init() {} // Prevent instantiation outside this class
    
    func createPost(_ postContent: String, locationCategory: LocationCategory, locationVisible: Bool, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No logged-in user.")
            completion(false)
            return
        }

        guard let state = LocationManager.shared.state,
              let city = LocationManager.shared.city,
              let country = LocationManager.shared.country else {
            print("Error: Location not determined.")
            completion(false)
            return
        }

        // Create a new post object
        let newPost = Post(
            userId: userId,
            content: postContent,
            timestamp: Date(),
            location: LocationManager.shared.location?.coordinate,
            locationCategory: locationCategory,
            locationVisible: locationVisible
        )
        print("🟢 Creating post at: \(newPost.location?.latitude ?? 0), \(newPost.location?.longitude ?? 0)")

        do {
            var postData = try Firestore.Encoder().encode(newPost)

            // Remove unnecessary fields
            postData.removeValue(forKey: "userName")  // Avoid encoding userName if not needed
            
            // Add location fields
            postData["country"] = country
            postData["state"] = state
            postData["city"] = city

            if let location = newPost.location {
                postData["location"] = GeoPoint(latitude: location.latitude, longitude: location.longitude)
            }

            // Save to Firestore
            Firestore.firestore().collection("Posts").addDocument(data: postData) { error in
                if let error = error {
                    print("Error saving post: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Post successfully saved!")
                    completion(true)
                }
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    func savePost(_ post: Post, completion: @escaping (Bool) -> Void) {

        guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: No logged-in user.")
                completion(false)
                return
        }
    
        guard let state = LocationManager.shared.state,
              let city = LocationManager.shared.city,
              let country = LocationManager.shared.country else {
                print("Error: Location not determined.")
                completion(false)
                return
        }
    
        // Convert post to Firestore-friendly format
        var postData: [String: Any] = [
            "userId": userId,
            "content": post.content,
            "timestamp": Timestamp(date: post.timestamp),
            "locationCategory": post.locationCategory.rawValue,
            "country": country,
            "state": state,
            "city": city
        ]
    
        // Convert CLLocationCoordinate2D to Firestore-compatible format
        if let location = post.location {
            postData["location"] = ["latitude": location.latitude, "longitude": location.longitude]
        }
    
        // Add document to Firestore
        db.collection("Posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Post successfully saved!")
                completion(true)
            }
        }
    }
    
    func fetchPosts(for category: LocationCategory, completion: @escaping ([Post]) -> Void) {
        let db = Firestore.firestore()

        guard let userState = LocationManager.shared.state,
              let userCity = LocationManager.shared.city,
              let userCountry = LocationManager.shared.country else {
                print("Error: Unable to determine user location.")
                completion([])
                return
        }

        var query = db.collection("Posts")
            .whereField("locationCategory", isEqualTo: category.rawValue)
            .order(by: "timestamp", descending: true)

        if category == .nation {
                query = query.whereField("country", isEqualTo: userCountry)
            } else if category == .state {
                query = query.whereField("country", isEqualTo: userCountry) // Ensure same country
                             .whereField("state", isEqualTo: userState)
            } else if category == .city {
                query = query.whereField("country", isEqualTo: userCountry) // Ensure same country
                             .whereField("state", isEqualTo: userState) // Ensure same state
                             .whereField("city", isEqualTo: userCity) // Ensure same city
            }//else if category == .neighborhood {
//                let userCoord = LocationManager.shared.location?.coordinate ?? CLLocationCoordinate2D()
//                //let delta = 0.072 // ~5 miles approximation
//                let delta = 1.0 // debug range
//
//                print("🔍 User simulated location: \(userCoord.latitude), \(userCoord.longitude)")
//
//                query = query
//                    .whereField("location.latitude", isGreaterThan: userCoord.latitude - delta)
//                    .whereField("location.latitude", isLessThan: userCoord.latitude + delta)
//                    .whereField("location.longitude", isGreaterThan: userCoord.longitude - delta)
//                    .whereField("location.longitude", isLessThan: userCoord.longitude + delta)
//            }
                
                else if category == .neighborhood {
                    // TEMP FIX: Only use locationCategory filtering
                    query = query.whereField("locationCategory", isEqualTo: "neighborhood")
                }
                
        query.getDocuments { (snapshot, error) in
            print("✅ Firestore returned \(snapshot?.documents.count ?? 0) raw documents")
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion([])
                    return
                }


                guard let documents = snapshot?.documents else {
                    print("No posts found for \(category.rawValue)")
                    completion([])
                    return
                }

                var posts: [Post] = []
                let group = DispatchGroup() // Ensures all user names are fetched before completion

                for doc in documents {
                    let data = doc.data()

                    guard let userId = data["userId"] as? String,
                          let content = data["content"] as? String,
                          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                          let locationCategoryRaw = data["locationCategory"] as? String,
                          let locationCategory = LocationCategory(rawValue: locationCategoryRaw) else {
                        continue
                    }

                    var location: CLLocationCoordinate2D? = nil
                    if let geoPoint = data["location"] as? GeoPoint {
                        location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    } else if let locationData = data["location"] as? [String: Double],
                              let latitude = locationData["latitude"],
                              let longitude = locationData["longitude"] {
                        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                    
                    if let loc = location {
                        print("🔵 Post document \(doc.documentID) at location: \(loc.latitude), \(loc.longitude)")
                    }

                    let locationVisible = data["locationVisible"] as? Bool ?? false

                    //  Fetch user name from cache or Firestore
                    group.enter()
                    UserService.shared.fetchUserName(for: userId) { userName in
                        let post = Post(
                            id: doc.documentID,
                            userId: userId,
                            userName: userName ?? "Unknown User",
                            content: content,
                            timestamp: timestamp,
                            location: location,
                            locationCategory: locationCategory,
                            locationVisible: locationVisible
                        )
                        
                        posts.append(post) // Only append AFTER username is set
                        print("Appending post for \(userId) with username: \(post.userName)")

                        group.leave()
                    }
//                    group.enter() // Start waiting for Firestore response
//                    UserService.shared.fetchUserName(for: userId) { userName in
//                        post.userName = userName ?? "Loading..."
//                        print("Fetched username \(post.userName) now")
//                        group.leave() // Finish waiting
//                    }
//
//                    group.leave()
                }

                //  Ensure all Firestore calls are done before returning data
                group.notify(queue: .main) {
                    print("Successfully loaded \(posts.count) posts with user names")
                    let userCoord = LocationManager.shared.location?.coordinate ?? CLLocationCoordinate2D()
                    print("🟡 User current location when filtering: \(userCoord.latitude), \(userCoord.longitude)")
                    let maxDistanceMiles: Double = 5.0

                    
                    if category == .neighborhood {
                        print("Before filtering, posts count: \(posts.count)")
                        posts = posts.filter { post in
                            guard let coord = post.location else {
                                print("Post \(post.id ?? "") has no location, filtering out")
                                return false
                            }
                            let postCoord = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
                            let distance = self.haversineDistance(from: userCoord, to: postCoord)
                            let passes = distance <= maxDistanceMiles
                            print("📍 Post \(post.id ?? "") at (\(postCoord.latitude), \(postCoord.longitude)) is \(distance) miles away; passes filter: \(passes)")
                            return passes
                        }
                        print("✅ Filtered down to \(posts.count) neighborhood posts within \(maxDistanceMiles) miles")
                    }
                    completion(posts)
                }
            }
    }
    
    // Fetches only posts from one user -- This is used for fetching posts created by the user
        func fetchPostsForUser(userId: String, completion: @escaping ([Post]) -> Void) {
    
            db.collection("Posts")
                .whereField("userId", isEqualTo: userId) // Only fetch posts by this user
                .order(by: "timestamp", descending: true)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching user posts: \(error.localizedDescription)")
                        completion([])
                        return
                    }
    
                    guard let documents = snapshot?.documents else {
                        print("No posts found for user \(userId)")
                        completion([])
                        return
                    }
    
                    var posts: [Post] = []
                    let group = DispatchGroup() // Ensures all user names are fetched before completion
    
                    for doc in documents {
                        let data = doc.data()
    
                        guard let content = data["content"] as? String,
                              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                              let locationCategoryRaw = data["locationCategory"] as? String,
                              let locationCategory = LocationCategory(rawValue: locationCategoryRaw) else {
                            continue
                        }
    
                        var location: CLLocationCoordinate2D? = nil
                        if let geoPoint = data["location"] as? GeoPoint {
                            location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        } else if let locationData = data["location"] as? [String: Double],
                                  let latitude = locationData["latitude"],
                                  let longitude = locationData["longitude"] {
                            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        }
    
                        let locationVisible = data["locationVisible"] as? Bool ?? false
                        
                        var post = Post(
                            id: doc.documentID,
                            userId: userId,
                            userName: nil,
                            content: content,
                            timestamp: timestamp,
                            location: location,
                            locationCategory: locationCategory,
                            locationVisible: locationVisible
                        )
    
                        //Fetch user name from cache or Firestore
                        group.enter() // Start waiting for Firestore response
                        UserService.shared.fetchUserName(for: userId) { userName in
                            post.userName = userName ?? "Unknown User"
                            print("Fetched username \(post.userName) now")
                            print("Appending username \(post.userName) now")
                            posts.append(post)
                            group.leave()
                        }
                        
//                        print("Appending username \(post.userName) now")
//                        posts.append(post)
                    }
    
                    // Ensure all Firestore calls are done before returning data
                    group.notify(queue: .main) {
                        print("Successfully loaded \(posts.count) user posts")
                        completion(posts)
                    }
                    
                }
        }
    
    
    func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No logged-in user.")
            completion(false)
            return
        }
    
        let postRef = db.collection("Posts").document(postId)
    
        postRef.getDocument { document, error in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                completion(false)
                return
            }
    
            guard let document = document, document.exists, let postOwner = document.get("userId") as? String else {
                print("Post does not exist or userId not found.")
                completion(false)
                return
            }
    
            if postOwner == userId {
                postRef.delete { error in
                    if let error = error {
                        print("Error deleting post: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Post successfully deleted!")
                        completion(true)
                    }
                }
            } else {
                print("Unauthorized: User does not own this post.")
                completion(false)
            }
        }
    }
    
    private func haversineDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let R = 3958.8 // Earth radius in miles
        let lat1 = coord1.latitude * .pi / 180
        let lon1 = coord1.longitude * .pi / 180
        let lat2 = coord2.latitude * .pi / 180
        let lon2 = coord2.longitude * .pi / 180

        let dlat = lat2 - lat1
        let dlon = lon2 - lon1
        let a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    func fetchPostsForUsers(userIds: [String], completion: @escaping ([Post]) -> Void) {
        let db = Firestore.firestore()

        guard !userIds.isEmpty else {
            completion([])
            return
        }

        let group = DispatchGroup()
        var allPosts: [Post] = []

        for userId in userIds {
            group.enter()
            fetchPostsForUser(userId: userId) { posts in
                allPosts.append(contentsOf: posts)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let sortedPosts = allPosts.sorted(by: { $0.timestamp > $1.timestamp })
            completion(sortedPosts)
        }
    }
    
}


