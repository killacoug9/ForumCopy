import SwiftUI
import CoreLocation
import FirebaseAuth

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var posts: [Post]

    @State private var eventName: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var moreDetails: String = ""
    @State private var locationSet = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showError = false
    @State private var errorMessage: String = ""

    var locationCategory: LocationCategory

    var body: some View {
        let background = colorScheme == .dark ? Color("BackgroundDarkMode") : Color("BackgroundLightMode")
        let textColor = colorScheme == .dark ? Color("Text") : Color("Text")
        let fieldBackgroundColor = colorScheme == .dark ? Color("FieldBackgroundDarkMode") : Color("FieldBackgroundLightMode")
        let buttonColor = Color("ButtonColor")

        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(textColor)
                }
                .padding(.leading)

                Spacer()

                Button(action: postEvent) {
                    Text("Post")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(Color.clear)
                        .foregroundColor(buttonColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(buttonColor, lineWidth: 2)
                        )
                }
                .padding(.trailing)
            }
            .padding(.top, 20)

            TextField("Event Name", text: $eventName)
                .padding()
                .background(fieldBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(textColor)

            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .padding()
                .background(fieldBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(textColor)

            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .padding()
                .background(fieldBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(textColor)

            Button(action: toggleLocationSetting) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(textColor)
                    Text(locationSet ? "Location: Set" : "Location: Not set")
                        .foregroundColor(textColor)
                }
                .padding()
                .background(fieldBackgroundColor)
                .cornerRadius(10)
            }
            .padding(.top, 20)

            TextField("Additional Details", text: $moreDetails)
                .padding()
                .background(fieldBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(textColor)

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .background(background.edgesIgnoringSafeArea(.all))
        .foregroundColor(textColor)
    }

    private func toggleLocationSetting() {
        if locationSet {
            selectedLocation = nil
            locationSet = false
        } else {
            if let currentLocation = LocationManager.shared.location {
                selectedLocation = currentLocation.coordinate
                locationSet = true
            }
        }
    }

    private func postEvent() {
        guard !eventName.isEmpty, !moreDetails.isEmpty else {
            errorMessage = "Please fill in all required fields."
            showError = true
            return
        }
        
        guard let userId = AuthService.shared.getCurrentUser()?.uid else {
            print("❌ Error: No logged-in user.")
            return
        }
        
        // Create and append the new event to the list
        let newEvent = Post(
            //id: UUID().uuidString,
            userId: userId,
            content: eventName,
            timestamp: Date(),
            location: selectedLocation,
            locationCategory: locationCategory
        )

        posts.append(newEvent)
        presentationMode.wrappedValue.dismiss() // Dismiss to go back to main posts view
    }
}
