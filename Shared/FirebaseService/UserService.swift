//
//  UserService.swift
//  Forum
//
//  Created by Kyle Hawkins on 2/9/25.
//


import FirebaseAuth
import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    static let shared = UserService() // Singleton

    private init() {} // Prevent instantiation outside this class
    // Fetches user name with caching
    func fetchUserName(for userId: String, completion: @escaping (String?) -> Void) {
        // First, check if the user name is cached
        if let cachedName = UserCacheManager.shared.getCachedUserName(for: userId) {
            completion(cachedName)
        } else {
            // Fetch user name from Firestore if not in cache
            self.db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let data = document?.data(),
                      let firstName = data["first_name"] as? String,
                      let lastName = data["last_name"] as? String else {
                    print("No name found for user ID \(userId)")
                    completion(nil)
                    return
                }

                let fullName = "\(firstName) \(lastName)"
                // Cache the result for future use
                print("Fetched name for \(userId): \(fullName)")
                UserCacheManager.shared.cacheUserName(userId, name: fullName)
                completion(fullName)
            }
        }
    }
    
    // Store User in Firestore (using UID as document ID)
    func storeUserInFirestore(uid: String, firstName: String, lastName: String, email: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid) // Firestore document ID = UID

        var userData: [String: Any] = [
            "uid": uid,
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "date_created": FieldValue.serverTimestamp(),  // Auto-generated timestamp
            "posts": []  // Empty posts array
        ]
        
        // Handle optional profile picture (Firestore doesn't accept nil directly)
        userData["profile_picture"] = NSNull()  // Store explicitly as null

        userRef.setData(userData) { error in
            if let error = error {
                print("Error storing user: \(error.localizedDescription)")
            } else {
                print("User successfully stored in Firestore with UID as document ID!")
            }
        }
    }
    
    // ✅ Ensure fetchUserData is inside the class
    func fetchUserData(uid: String,  completion: @escaping (String, String, String) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let firstName = data?["first_name"] as? String ?? "No First Name"
                let lastName = data?["last_name"] as? String ?? "No Last Name"
                let userEmail = data?["email"] as? String ?? "No Email"
                let userPosts = data?["posts"] as? [String] ?? []
                
                DispatchQueue.main.async {
                   completion(firstName, lastName, userEmail)
                }
                print("User Info: First Name: \(firstName), Last Name: \(lastName), Email: \(userEmail), Posts: \(userPosts)")
            } else {
                print("User not found in Firestore.")
            }
        }
    }
    
    // Update User Data in Firestore
    func updateUserData(uid: String, firstName: String, lastName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        // Prepare updated data
        let updatedData: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName
        ]
        
        // Update Firestore document
        userRef.updateData(updatedData) { error in
            if let error = error {
                print("Failed to update user: \(error.localizedDescription)")
                print("Error updating user: \(error.localizedDescription)")
            } else {
                print("User data updated successfully!")
            }
        }
    }
    
    func fetchUserByUID(uid: String, completion: @escaping (UserInfo?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let firstName = data["first_name"] as? String,
               let lastName = data["last_name"] as? String,
               let email = data["email"] as? String {
                let user = UserInfo(uid: uid, firstName: firstName, lastName: lastName, email: email)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
}
