//
//  SignUpView.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 1/29/25.
//

import SwiftUI

struct SignUpView: View {
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    let authService = AuthService.shared
    
    @State private var emailErrorMessage: String? = nil
    @State var showPassword: Bool = false
    
    // Environment variable to dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // background color
                Color("Cream")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // Email Field
                    VStack(alignment: .leading) {
                        
                        // login
                        Text("Sign Up Here: ")
                            .bold()
                            .padding(.top, 20)
                            .font(.system(size: 35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 50)
                        
                        // first name info
                        Text("First Name:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        TextField("", text: $firstName)
                            .padding()
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        
                        // last name info
                        Text("Last Name:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        TextField("", text: $lastName)
                            .padding()
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        
                        Text("Email:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        TextField("", text: $email, onEditingChanged: { _ in
                            validateEmail() // Validate email when the user edits
                        })
                            .textContentType(.emailAddress)
                            .padding()
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        // shows error if the email is not validated
                        if let emailError = emailErrorMessage {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        Text("Password:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        HStack {
                            ZStack(alignment: .trailing) {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                        .padding()
                                } else {
                                    SecureField("", text: $password)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                        .padding()
                                }
                                
                                // show password button
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 10)
                            }
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        }
                        
                        // checks password passes requirements
                        PasswordRequirementsView(password: $password)
                                .padding(.top, 10)
                        
                    }
                    .padding(.horizontal, 20)
                    
                    
                    // Login Button
                    Button(action: {
                        // Simulate account creation
                        authService.signUp( email: email, password: password, firstName: firstName, lastName: lastName) { success, errorMessage in
                            if success {
                                print("Successfully signed up!")
                            } else {
                                print("Sign up failed: \(errorMessage ?? "Unknown error")")
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Watermelon"))
                            .cornerRadius(10)
                            
                    }
                    .padding(.horizontal, 80)
                    
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Dismiss SignUpView
                        }) {
                            Text("Login here")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                               
                        }
                    }
                    
                }
            }
        }
    }
    
    // checks that email is a valid email using regex
    func validateEmail() {
            let emailPattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let regex = try! NSRegularExpression(pattern: emailPattern, options: [])
            let range = NSRange(location: 0, length: email.utf16.count)
            if regex.firstMatch(in: email, options: [], range: range) == nil {
                emailErrorMessage = "Please enter a valid email address"
            } else {
                emailErrorMessage = nil
            }
        }
}


// password checking
struct PasswordRequirementsView: View {
    @Binding var password: String
    
    // Check the password requirements
    private var isLongEnough: Bool {
        return password.count >= 8
    }
    
    private var hasNumber: Bool {
        return password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    private var hasSpecialCharacter: Bool {
        let specialCharacterPattern = "[^A-Za-z0-9]"
        let regex = try! NSRegularExpression(pattern: specialCharacterPattern, options: [])
        return regex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.count)) != nil
    }
    
    private var hasUppercase: Bool {
            return password.rangeOfCharacter(from: .uppercaseLetters) != nil
        }
        
    private var hasLowercase: Bool {
        return password.rangeOfCharacter(from: .lowercaseLetters) != nil
    }

    var body: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                requirementText("At least 8 characters", isMet: isLongEnough)
                requirementText("Include a number", isMet: hasNumber)
                requirementText("Include a special character", isMet: hasSpecialCharacter)
            }
            
            VStack(alignment: .leading) {
                requirementText("Include an uppercase letter", isMet: hasUppercase)
                requirementText("Include a lowercase letter", isMet: hasLowercase)
            }
        }
    }
    
    // Helper method to display the text with or without a line-through
    private func requirementText(_ requirement: String, isMet: Bool) -> some View {
        Text(requirement)
            .font(.caption)
            .foregroundColor(.gray)
            .strikethrough(isMet, color: .green) // Cross off if requirement is met
            .padding(.top, 2)
            .padding(.leading, 10)
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
    
}
