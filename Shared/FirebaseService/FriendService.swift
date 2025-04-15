//
//  FriendService.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 3/26/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FriendService {
    private let db = Firestore.firestore()
    static let shared = FriendService()
    
    // Store new user in "friends" collection when account is created
        func storeUserInFriends(uid: String) {
            
            let friendData: [String: Any] = [
                "userId": uid,
                "friends_list": [],  // Initialize empty friends list
                "time": FieldValue.serverTimestamp() // Store server time
            ]
            
            // Create a new document with the user's UID
            db.collection("friends").document(uid).setData(friendData) { error in
                if let error = error {
                    print("❌ Error storing user in friends: \(error.localizedDescription)")
                } else {
                    print("✅ User successfully added to friends collection!")
                }
            }
        }

    
    
    // Add a friend to the user's friends_list
    func addFriend(currentUserId: String, friendUserId: String, completion: @escaping (Bool) -> Void) {
        let friendsRef = db.collection("friends").document(currentUserId)
        
        // Use Firestore's arrayUnion to append the friend, setData creates document if it doesn't exist, and it appends to friends list
        friendsRef.setData([
            "friends_list": FieldValue.arrayUnion([friendUserId])
        ], merge: true) { error in
            if let error = error {
                print("❌ Error adding friend: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Friend added successfully!")
                completion(true)
            }
        }
    }
    
    func fetchFriendList(for userId: String, completion: @escaping ([String]) -> Void) {
        let docRef = Firestore.firestore().collection("friends").document(userId)
        docRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching friends list: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = document?.data(),
                  let friends = data["friends_list"] as? [String] else {
                print("⚠️ No friends found or bad data format.")
                completion([])
                return
            }

            completion(friends)
        }
    }
    
    func fetchFriends(for userId: String, completion: @escaping ([UserInfo]) -> Void) {
        db.collection("friends").document(userId).getDocument { snapshot, error in
            if let error = error {
                print(" Error fetching friends list: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = snapshot?.data(),
                  let friendUIDs = data["friends_list"] as? [String] else {
                print("No friends found.")
                completion([])
                return
            }

            var friends: [UserInfo] = []
            let group = DispatchGroup()

            for uid in friendUIDs {
                group.enter()
                UserService.shared.fetchUserByUID(uid: uid) { user in
                    if let user = user {
                        friends.append(user)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(friends)
            }
        }
    }
    
}
    
