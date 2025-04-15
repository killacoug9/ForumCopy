//
//  UserService.swift
//  Forum (iOS)
//
//  Created by Kyle Hawkins on 2/9/25.
//

//import FirebaseAuth
//import FirebaseFirestore

//class UserService {
//    private let db = Firestore.firestore()
//    static let shared = UserService() // Singleton
//
//    private init() {} // Prevent instantiation outside this class

    // Fetches user name with caching
//    func fetchUserName(for userId: String, completion: @escaping (String?) -> Void) {
//        if let cachedName = UserCacheManager.shared.getCachedUserName(for: userId) {
//            completion(cachedName)
//            return
//        }
//
//        db.collection("users").document(userId).getDocument { snapshot, error in
//            if let error = error {
//                print("Error fetching user: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            guard let data = snapshot?.data(), let name = data["name"] as? String else {
//                completion(nil)
//                return
//            }
//
//            // Cache the result
//            UserCacheManager.shared.cacheUserName(name, for: userId)
//            completion(name)
//        }
    //}
//}
