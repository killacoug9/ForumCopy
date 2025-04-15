import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

// DATABASE FETCH POSTS AND SAVE POST FUNCTIONS  ARE WITHIN HERE

// Keyboard Observer to track keyboard visibility
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0

    private var keyboardWillShow: NSObjectProtocol?
    private var keyboardWillHide: NSObjectProtocol?

    init() {
        // Listen for the keyboard showing and hiding
        keyboardWillShow = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self?.keyboardHeight = keyboardFrame.height
                self?.isKeyboardVisible = true
            }
        }
        keyboardWillHide = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.isKeyboardVisible = false
            self?.keyboardHeight = 0
        }
    }

    deinit {
        if let keyboardWillShow = keyboardWillShow {
            NotificationCenter.default.removeObserver(keyboardWillShow)
        }
        if let keyboardWillHide = keyboardWillHide {
            NotificationCenter.default.removeObserver(keyboardWillHide)
        }
    }
}

// Custom Text View
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor(named: "Text") // Set text color when typing
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor(named: "LightGray") // Placeholder color
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.text = placeholder
        textView.textColor = UIColor(named: "LightGray")
        textView.backgroundColor = UIColor.clear // Make background clear
        textView.layer.borderWidth = 0 // Remove border
        textView.layer.cornerRadius = 10 // Rounded corners
        textView.layer.shadowColor = UIColor.black.cgColor // Shadow color
        textView.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset
        textView.layer.shadowOpacity = 0.1 // Shadow opacity
        textView.layer.shadowRadius = 5 // Shadow radius
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text.isEmpty ? placeholder : text
        uiView.textColor = text.isEmpty ? UIColor(named: "LightGray") : UIColor(named: "Text")
    }
}

// Post Input View
struct PostInputView: View {
//    @ObservedObject var locationManager = LocationManager.shared
    @Binding var posts: [Post]
    @State private var postContent: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var isLocationSet = false
    @State private var showCreateEvent = false
    @StateObject private var keyboardObserver = KeyboardObserver() // Observe the keyboard
    var locationCategory: LocationCategory

    var body: some View {
        let background = colorScheme == .dark ? Color("PostBackgroundDarkMode") : Color("BackgroundLightMode")
        let textColor = colorScheme == .dark ? Color("Text") : Color("Text")
        let fieldBackgroundColor = colorScheme == .dark ? Color("FieldBackgroundDarkMode") : Color("FieldBackgroundLightMode")

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(textColor)
                        .padding()
                }
                Spacer()
                Button(action: {
                    guard !postContent.isEmpty else { return } // Prevent empty posts
                    
                    PostService.shared.createPost(postContent, locationCategory: locationCategory, locationVisible: isLocationSet) { success in
                        if success {
                            PostService.shared.fetchPosts(for: locationCategory) { retrievedPosts in
                                self.posts = retrievedPosts // Sync with Firestore
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Post")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .foregroundColor(Color("ButtonColor"))
                }
                .padding(.trailing)
            }
            .padding(.top, 5)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(fieldBackgroundColor)
                    .padding(.horizontal, 0)

                VStack(spacing: 0) {
                    CustomTextView(text: $postContent, placeholder: "What's happening?")
                        .padding(.horizontal, 16)
                        .frame(maxHeight: .infinity)

                    Divider()
                        .background(Color.gray.opacity(0.5))

                    HStack(spacing: 20) {
                        Button(action: {
                            if isLocationSet {
                                isLocationSet = false
                            } else {
                                isLocationSet = true
                            }
                        }) {
                            ZStack {
                                if isLocationSet {
                                    Circle()
                                        .stroke(Color.green, lineWidth: 3)
                                        .background(Circle().fill(Color.green.opacity(0.2)))
                                        .frame(width: 40, height: 40)
                                }

                                Image(systemName: "location.fill")
                                    .foregroundColor(isLocationSet ? .green : textColor)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding()
                        .background(fieldBackgroundColor.opacity(0.5))
                        .clipShape(Circle())

                        Button(action: {
                            showCreateEvent.toggle()
                        }) {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.purple)
                        }
                        .padding()
                        .background(fieldBackgroundColor.opacity(0.5))
                        .clipShape(Circle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight + 20 : 10)
                }
            }
            .padding(.bottom, 30)

            Spacer()
        }
        .padding(.horizontal, 0)
        .padding(.top, 0)
        .background(background)
        .foregroundColor(textColor)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView(posts: $posts, locationCategory: locationCategory)
        }
    }
}
//
//// FIREBASE STORAGE FUNCTIONS AND FETCH
//func savePost(_ post: Post, completion: @escaping (Bool) -> Void) {
//    let db = Firestore.firestore()
//    guard let userId = Auth.auth().currentUser?.uid else {
//            print("Error: No logged-in user.")
//            completion(false)
//            return
//    }
//
//    guard let state = LocationManager.shared.state,
//          let city = LocationManager.shared.city,
//          let country = LocationManager.shared.country else {
//            print("Error: Location not determined.")
//            completion(false)
//            return
//    }
//    
//    // Convert post to Firestore-friendly format
//    var postData: [String: Any] = [
//        "userId": userId,
//        "content": post.content,
//        "timestamp": Timestamp(date: post.timestamp),
//        "locationCategory": post.locationCategory.rawValue,
//        "country": country,
//        "state": state,
//        "city": city
//    ]
//
//    // Convert CLLocationCoordinate2D to Firestore-compatible format
//    if let location = post.location {
//        postData["location"] = ["latitude": location.latitude, "longitude": location.longitude]
//    }
//
//    // Add document to Firestore
//    db.collection("Posts").addDocument(data: postData) { error in
//        if let error = error {
//            print("Error saving post: \(error.localizedDescription)")
//            completion(false)
//        } else {
//            print("Post successfully saved!")
//            completion(true)
//        }
//    }
//}
//
//func fetchPosts(for category: LocationCategory, completion: @escaping ([Post]) -> Void) {
//    let db = Firestore.firestore()
//
//    guard let userState = LocationManager.shared.state,
//          let userCity = LocationManager.shared.city,
//          let userCountry = LocationManager.shared.country else {
//            print("Error: Unable to determine user location.")
//            completion([])
//            return
//    }
//    
//    var query = db.collection("Posts")
//        .whereField("locationCategory", isEqualTo: category.rawValue)
//        .order(by: "timestamp", descending: true)
//    
//    if category == .nation {
//            query = query.whereField("country", isEqualTo: userCountry)
//        } else if category == .state {
//            query = query.whereField("country", isEqualTo: userCountry) // Ensure same country
//                         .whereField("state", isEqualTo: userState)
//        } else if category == .city {
//            query = query.whereField("country", isEqualTo: userCountry) // Ensure same country
//                         .whereField("state", isEqualTo: userState) // Ensure same state
//                         .whereField("city", isEqualTo: userCity) // Ensure same city
//        }
//    
//    query.getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching posts: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//        
//
//            guard let documents = snapshot?.documents else {
//                print("No posts found for \(category.rawValue)")
//                completion([])
//                return
//            }
//
//            var posts: [Post] = []
//            let group = DispatchGroup() // Ensures all user names are fetched before completion
//
//            for doc in documents {
//                let data = doc.data()
//
//                guard let userId = data["userId"] as? String,
//                      let content = data["content"] as? String,
//                      let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
//                      let locationCategoryRaw = data["locationCategory"] as? String,
//                      let locationCategory = LocationCategory(rawValue: locationCategoryRaw) else {
//                    continue
//                }
//
//                var location: CLLocationCoordinate2D? = nil
//                if let locationData = data["location"] as? [String: Double],
//                   let latitude = locationData["latitude"],
//                   let longitude = locationData["longitude"] {
//                    location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                }
//
//                var post = Post(
//                    id: doc.documentID,
//                    userId: userId,
//                    userName: nil,
//                    content: content,
//                    timestamp: timestamp,
//                    location: location,
//                    locationCategory: locationCategory
//                )
//
//                //  Fetch user name from cache or Firestore
//                group.enter() // Start waiting for Firestore response
//                UserCacheManager.shared.fetchUserName(for: userId) { userName in
//                    post.userName = userName
//                    group.leave() // Finish waiting
//                }
//
//                posts.append(post)
//            }
//
//            //  Ensure all Firestore calls are done before returning data
//            group.notify(queue: .main) {
//                print("Successfully loaded \(posts.count) posts with user names")
//                completion(posts)
//            }
//        }
//}
//
//// Fetches only the posts created by the logged-in user
//func fetchPostsForUser(userId: String, completion: @escaping ([Post]) -> Void) {
//    let db = Firestore.firestore()
//
//    db.collection("Posts")
//        .whereField("userId", isEqualTo: userId) // Only fetch posts by this user
//        .order(by: "timestamp", descending: true)
//        .getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching user posts: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//
//            guard let documents = snapshot?.documents else {
//                print("No posts found for user \(userId)")
//                completion([])
//                return
//            }
//
//            var posts: [Post] = []
//            let group = DispatchGroup() // Ensures all user names are fetched before completion
//
//            for doc in documents {
//                let data = doc.data()
//
//                guard let content = data["content"] as? String,
//                      let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
//                      let locationCategoryRaw = data["locationCategory"] as? String,
//                      let locationCategory = LocationCategory(rawValue: locationCategoryRaw) else {
//                    continue
//                }
//
//                var location: CLLocationCoordinate2D? = nil
//                if let locationData = data["location"] as? [String: Double],
//                   let latitude = locationData["latitude"],
//                   let longitude = locationData["longitude"] {
//                    location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                }
//
//                var post = Post(
//                    id: doc.documentID,
//                    userId: userId,
//                    userName: nil,
//                    content: content,
//                    timestamp: timestamp,
//                    location: location,
//                    locationCategory: locationCategory
//                )
//
//                // Fetch user name from cache or Firestore
//                group.enter() // Start waiting for Firestore response
//                UserCacheManager.shared.fetchUserName(for: userId) { userName in
//                    post.userName = userName
//                    group.leave()
//                }
//
//                posts.append(post)
//            }
//
//            // Ensure all Firestore calls are done before returning data
//            group.notify(queue: .main) {
//                print("Successfully loaded \(posts.count) user posts")
//                completion(posts)
//            }
//        }
//}
//
