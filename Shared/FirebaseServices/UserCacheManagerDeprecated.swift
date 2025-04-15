//
//  UserCacheManager.swift
//  Forum
//
//  Created by Cem Beyenal on 2/6/25.
//

//import FirebaseFirestore
//
//class UserCacheManager {
//    static let shared = UserCacheManager() // Singleton instance
//
//    private var userCache: [String: String] = [:] // Stores userId → name mapping
//    private let db = Firestore.firestore()
//
//    private init() {} // Prevents external initialization
//
//    // Fetches the user’s name, either from cache or Firestore
//    func fetchUserName(for userId: String, completion: @escaping (String) -> Void) {
//        if let cachedName = userCache[userId] {
//            completion(cachedName) // Return cached name
//            return
//        }
//
//        db.collection("users").document(userId).getDocument { (document, error) in
//            if let error = error {
//                print("Error fetching user: \(error.localizedDescription)")
//                completion("Unknown User")
//                return
//            }
//
//            if let document = document, let data = document.data(),
//               let firstName = data["first_name"] as? String,
//               let lastName = data["last_name"] as? String {
//                let fullName = "\(firstName) \(lastName)"
//                self.userCache[userId] = fullName // Cache result
//                completion(fullName)
//            } else {
//                completion("Unknown User")
//            }
//        }
//    }
//}
