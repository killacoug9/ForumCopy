import SwiftUI
import Foundation

struct RepresentativeView: View {
    let official: Official

    var body: some View {
        ScrollView {
            
            Text(official.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 130)
            if let party = official.party {
                Text(party)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
            
            VStack(spacing: 20) {  // Spacing between sections

                if let addresses = official.address, !addresses.isEmpty {
                        addressSection(addresses)
                }
                
                Divider()
                    .padding(.leading, 20)

                if let phones = official.phones, !phones.isEmpty {
                        phoneSection(phones)
                }
                
                Divider()
                    .padding(.leading, 20)

                if let urls = official.urls, !urls.isEmpty {
                        websiteSection(urls)
                }
                
                Divider()
                    .padding(.leading, 20)


                if let channels = official.channels, !channels.isEmpty {
                        socialMediaSection(channels)
                }
            }
            .padding()  // Padding around all sections
        }
        .navigationBarTitle("", displayMode: .inline)
        .background(Color("Cream"))
        .edgesIgnoringSafeArea(.all)
    }

    func addressSection(_ addresses: [Address]) -> some View {
        SectionView {
            ForEach(addresses, id: \.self) { address in
                Button(action: {
                    openAddressInMaps(address)
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text(address.formatted())
                        Spacer()
                    }
                }
                .font(.system(size: 17))
            }
        }
    }
    private func openAddressInMaps(_ address: Address) {
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(address.formattedForURL())"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func phoneSection(_ phones: [String]) -> some View {
        SectionView {
            ForEach(phones, id: \.self) { phone in
                Button(action: {
                    callNumber(phoneNumber: phone)
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text(phone)
                        Spacer()
                    }
                }
                .font(.system(size: 17))
            }
        }
    }
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber.filter { "0123456789".contains($0) })"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }

    func websiteSection(_ urls: [String]) -> some View {
        SectionView {
            ForEach(urls, id: \.self) { url in
                Link(destination: URL(string: url)!) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Website")
                        Spacer()
                    }
                    .font(.system(size: 17))
                }
                .padding(.bottom, 8)
                .padding(.top, 8)
            }
        }
    }

    func socialMediaSection(_ channels: [Channel]) -> some View {
        struct SocialMediaInfo: Hashable {
            let platformName: String
            let urlString: String
        }
        
        let socialMediaInfo = channels.compactMap { channel -> SocialMediaInfo? in
            switch channel.type.lowercased() {
            case "facebook":
                return SocialMediaInfo(platformName: "Facebook", urlString: "https://www.facebook.com/\(channel.id)")
            case "twitter":
                return SocialMediaInfo(platformName: "Twitter", urlString: "https://twitter.com/\(channel.id)")
            default:
                return nil
            }
        }
        
        return SectionView {
            ForEach(socialMediaInfo, id: \.self) { info in
                if let url = URL(string: info.urlString) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                            Text(info.platformName) // Display the platform name
                            Spacer()
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                }
            }
        }
    }
}

extension Address {
    func formattedForURL() -> String {
        // Format the address in a way suitable for URL encoding
        // For example, replacing spaces with "+"
        // Implement the logic based on your address formatting
        return self.formatted().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

struct SectionView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            content
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.95)  // Set width to 90% of screen width
//        .background(RoundedRectangle(cornerRadius: 8)
//            .stroke(Color("Text"), lineWidth: 0.75)
        //)
    }
}
