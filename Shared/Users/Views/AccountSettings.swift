//
//  ProfilePageView.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 2/24/25.
//
import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    let userService = UserService.shared
    let authService = AuthService.shared
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        ZStack {
            // background color
            Color("Cream")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        Text("Account Settings")
                            .bold()
                            .font(.system(size: 35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Edit button
                        Button(action: {
                            isEditing.toggle() // Toggle edit mode
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18)) // Icon size
                                    .foregroundColor(.white)
                                Text(isEditing ? "Cancel" : "Edit")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(Color("Watermelon"))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Watermelon"), lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes default button styling
                    }
                    
                    // First Name
                    Text("First Name:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    TextField("First Name", text: $firstName)
                        .padding()
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .disabled(!isEditing) // Disable when not in editing mode
                    
                    // Last Name
                    Text("Last Name:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .disabled(!isEditing) // Disable when not in editing mode
                    
                    // Email
                    Text("Email:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .disabled(true) // Make email non-editable
                    
                    // Save Changes Button (only shows in edit mode)
                    if isEditing {
                        Button(action: {
                            if let user = authService.getCurrentUser() {
                                userService.updateUserData(uid: user.uid, firstName: firstName, lastName: lastName)  // Update Firestore data
                            }
                            isEditing = false 
                        }) {
                            Text("Save Changes")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Watermelon"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 80)
                    }
                }
            .padding()
            .onAppear {
                if let user = authService.getCurrentUser() {
                    userService.fetchUserData(uid: user.uid) { fetchedFirstName, fetchedLastName, fetchedEmail in
                        self.firstName = fetchedFirstName
                        self.lastName = fetchedLastName
                        self.email = fetchedEmail
                    }
                }
            }
        }
    }
}


#Preview {
    AccountSettingsView()
}
