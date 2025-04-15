//
//  AuthService.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 1/29/25.
//
//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//import SwiftUI
//
//class AuthViewModel: ObservableObject {
//    
//    @Published var isAuthenticated = false
//    @Published var errorMessage: String?
//    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
//
//    func signUp(email: String, password: String, firstName: String, lastName: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//                print("Firebase Sign-Up Error: \(error.localizedDescription)") // Debugging
//            } else if let user = result?.user {
//                self.isAuthenticated = true
//                self.isLoggedIn = true
//                print("User created successfully: \(result?.user.uid ?? "No UID")") // Debugging
//                
//                // Store user in Firestore with first and last name
//                self.storeUserInFirestore(uid: user.uid, firstName: firstName, lastName: lastName, email: email)
//            }
//        }
//    }
//    
//
//    func loginUser(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error as NSError? {
//                switch error.code {
//                    case AuthErrorCode.userNotFound.rawValue:
//                        self.errorMessage = "No account found with this email."
//                    case AuthErrorCode.wrongPassword.rawValue:
//                        self.errorMessage = "Incorrect password. Please try again."
//                    default:
//                        print("Firebase Login Error: \(error.localizedDescription)")
//                }
//            } else if let user = result?.user {
//                self.isAuthenticated = true
//                self.isLoggedIn = true
//                print("User successfully logged in: \(result?.user.uid ?? "No UID")")
//                
//                // Fetch user data after login
//                self.fetchUserData(uid: user.uid)
//            }
//        }
//    }
//
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//            self.isAuthenticated = false
//            self.isLoggedIn = false
//        } catch {
//            self.errorMessage = error.localizedDescription
//            print("Firebase Logout Error: \(error.localizedDescription)")
//        }
//    }
//    
//    // Store User in Firestore (using UID as document ID)
//    func storeUserInFirestore(uid: String, firstName: String, lastName: String, email: String) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(uid) // Firestore document ID = UID
//
//        var userData: [String: Any] = [
//            "uid": uid,
//            "first_name": firstName,
//            "last_name": lastName,
//            "email": email,
//            "date_created": FieldValue.serverTimestamp(),  // Auto-generated timestamp
//            "posts": []  // Empty posts array
//        ]
//        
//        // Handle optional profile picture (Firestore doesn't accept nil directly)
//        userData["profile_picture"] = NSNull()  // Store explicitly as null
//
//        userRef.setData(userData) { error in
//            if let error = error {
//                print("Error storing user: \(error.localizedDescription)")
//            } else {
//                print("User successfully stored in Firestore with UID as document ID!")
//            }
//        }
//    }
//    
//    // ✅ Ensure fetchUserData is inside the class
//    func fetchUserData(uid: String) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(uid)
//
//        userRef.getDocument { document, error in
//            if let document = document, document.exists {
//                let data = document.data()
//                let firstName = data?["first_name"] as? String ?? "No First Name"
//                let lastName = data?["last_name"] as? String ?? "No Last Name"
//                let userEmail = data?["email"] as? String ?? "No Email"
//                let userPosts = data?["posts"] as? [String] ?? []
//
//                print("User Info: First Name: \(firstName), Last Name: \(lastName), Email: \(userEmail), Posts: \(userPosts)")
//            } else {
//                print("User not found in Firestore.")
//            }
//        }
//    }
//}
