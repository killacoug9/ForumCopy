//
//  PACView.swift
//  Forum (iOS)
//
//  Created by Kyle Hawkins on 9/17/24.
//
import Foundation
import SwiftUI



struct DisResponse: Codable {
    let pagination: Pagination2
    let results: [DisbursementStruct]
}

struct Pagination2: Codable {
    let count: Int
    let isCountExact: Bool
    let pages: Int
    let perPage: Int
    let lastIndexes: LastIndexes
    
    enum CodingKeys: String, CodingKey {
        case count
        case isCountExact = "is_count_exact"
        case pages
        case perPage = "per_page"
        case lastIndexes = "last_indexes"
    }
}

// MARK: - Last Index Struct in Pagination
struct LastIndexes: Codable {
    let lastIndex: String
    let lastDisbursementDate: String
    
    enum CodingKeys: String, CodingKey {
        case lastIndex = "last_index"
        case lastDisbursementDate = "last_disbursement_date"
    }
}

// MARK: - Disbursement Structure
struct DisbursementStruct: Codable, Identifiable, Equatable {
    let id = UUID()
    let committeeId: String
    let disbursementAmount: Double
    let recipientName: String
    let disbursementDescription: String
    let disbursementDate: String
    let recipientCom: RecipientCommittee?

    
    enum CodingKeys: String, CodingKey {
        case recipientName = "recipient_name"
        case disbursementAmount = "disbursement_amount"
        case committeeId = "committee_id"
        case disbursementDescription = "disbursement_description"
        case disbursementDate = "disbursement_date"
        case recipientCom = "recipient_committee"
        
    }
    
    static func == (lhs: DisbursementStruct, rhs: DisbursementStruct) -> Bool {
        return lhs.committeeId == rhs.committeeId &&
                lhs.disbursementAmount == rhs.disbursementAmount &&
                lhs.recipientName == rhs.recipientName &&
                lhs.disbursementDescription == rhs.disbursementDescription &&
                lhs.disbursementDate == rhs.disbursementDate &&
                lhs.recipientCom == rhs.recipientCom
        
    }
}

struct RecipientCommittee: Codable, Equatable {
    let partyFull: String?
    
    enum CodingKeys: String, CodingKey {
        case partyFull = "party_full"
    }
}

struct PACEntry: View {
    var pac: PAC
    
    var formattedContribution: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: pac.totalContributions)) ?? "0"
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(pac.committeeName)
                .foregroundColor(Color("Text"))
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            Text("$\(formattedContribution)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}


struct PACView: View {
    var pac: PAC
    @State private var disbursements: [DisbursementStruct] = []
    @State private var isLoadingMore: Bool = false
    @State private var pagination: Pagination2? = nil
    @State private var errorMessage: String?
    
    var formattedCycle: String {
        let formatter = NumberFormatter()
        return formatter.string(from: NSNumber(value: pac.cycle)) ?? "no cycle stated"
    }
    
    var formattedDisbursements: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: pac.disbursements)) ?? "0"
    }
    
    var formattedNetContributions: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: pac.netContributions)) ?? "0"
    }
    
    var formattedIndividualContributions: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: pac.individualContributions)) ?? "0"
    }
    
    var formattedTreasurerName: String {
        let tName = pac.treasurerName
        let nameSeparater = tName.split(separator: ",")
        
        if nameSeparater.count == 2 {
            let lastName = nameSeparater[0].trimmingCharacters(in: .whitespaces)
            let firstName = nameSeparater[1].trimmingCharacters(in: .whitespaces)
            return "\(firstName) \(lastName)"
        }
        
        return tName
    }
    
    var formattedDisbursementAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        if let firstDisbursement = disbursements.first {
            return formatter.string(from: NSNumber(value: firstDisbursement.disbursementAmount)) ?? "0"
        }
        return "0"
    }
    
    var body: some View {
        ScrollView {
            
            Text(pac.committeeName)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 130)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 10){
                
                if !pac.netContributions.isZero {
                    Text("Net Contributions: ").fontWeight(.bold) + Text("$\(formattedNetContributions)")
                        .foregroundColor(Color("Text"))
                }
                
                Divider()
                    .padding(.leading, 20)
                
                if !pac.individualContributions.isZero {
                    Text("Individual Contributions: ").fontWeight(.bold) + Text("$\(formattedIndividualContributions)")
                        .foregroundColor(Color("Text"))
                }
                
                Divider()
                    .padding(.leading, 20)
                
                if !pac.treasurerName.isEmpty {
                    Text("Treasurer Name: ").fontWeight(.bold) + Text(formattedTreasurerName)
                        .foregroundColor(Color("Text"))
                }
                
                Divider()
                    .padding(.leading, 20)

                if !pac.disbursements.isZero {
                    Text("Total Disbursements: ").fontWeight(.bold) + Text("$\(formattedDisbursements)")
                        .foregroundColor(Color("Text"))
                }
                
                Divider()
                    .padding(.leading, 20)
                
                Text("Disbursement Details: ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                ForEach(disbursements.filter { $0.committeeId == pac.committeeId }, id: \.id) { disbursement in
                    VStack(alignment: .leading) {
                        Text("Recipient: ").fontWeight(.bold) + Text(disbursement.recipientName)
                        Text("Amount: ").fontWeight(.bold) + Text("$\(disbursement.disbursementAmount, specifier: "%.2f")")
                        Text("Description: ").fontWeight(.bold) + Text(disbursement.disbursementDescription)
                        
                        if let partyFull2 = disbursement.recipientCom?.partyFull, !partyFull2.isEmpty {
                            Text("Party: ").fontWeight(.bold) + Text(partyFull2).foregroundColor(Color("Text"))
                        }
                        
                        Text("Disbursement Date: \(disbursement.disbursementDate)")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        
                    }
                    
                    .padding()
                    .background(backgroundColorForParty(disbursement.recipientCom?.partyFull))
                    .cornerRadius(7)
                    
                    Divider()
                    
                    if disbursement == disbursements.last {
                        VStack {
                            Spacer() // Pushes the ProgressView to the center
                            ProgressView() // Optional loading spinner
                                .onAppear {
                                    if let pagination = pagination, pagination.pages > 1 {
                                        loadDisbursements(page: pagination.pages + 1)
                                    }
                                }
                            Spacer() // Pushes the ProgressView back up
                            }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
            }
            .padding()
        }
        .onAppear {
            loadDisbursements()
        }
        .background(Color("Cream"))
        .ignoresSafeArea()
    }
    
    
    func loadDisbursements(page: Int = 1) {
        
        if isLoadingMore || (pagination != nil && page > pagination!.pages) {
            return
        }
        
        getDisbursementData(page: page) { result in
            DispatchQueue.main.async {
                self.isLoadingMore = false
                
                switch result {
                case .success(let DisResponse):
                    self.disbursements.append(contentsOf: DisResponse.results)
                    self.pagination = DisResponse.pagination // Update the entire pagination struct
                case .failure(let error):
                    self.errorMessage = "Failed to fetch Disbursements: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getDisbursementData(page:Int, completion: @escaping (Result<DisResponse, Error>) -> Void) {
        let key = "lVIlJSRW5dz9ae1bNvLWYmtRHglvWkMjdNbVKARb"
        
        guard let url = URL(string: "https://api.open.fec.gov/v1/schedules/schedule_b/?committee_id=\(pac.committeeId)&per_page=50&sort=-disbursement_date&sort_hide_null=false&sort_null_only=false&api_key=\(key)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    // Parse the JSON data into a Swift object
                    let decoder = JSONDecoder()
                    print(data)
                    let responseData = try decoder.decode(DisResponse.self, from: data)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
        
        
    }
    
    func backgroundColorForParty(_ partyFull: String?) -> Color {
        guard let party = partyFull else { return Color.clear }
        
        let demColor = Color(red: 186 / 255.0, green: 225 / 255.0, blue: 255 / 255.0) // light blue
        let rebColor = Color(red: 255 / 255.0, green: 179 / 255.0, blue: 186 / 255.0) // light red

        switch party {
        case "DEMOCRATIC PARTY":
            return demColor
        case "REPUBLICAN PARTY":
            return rebColor
        default:
            return Color.clear
        }
    }
}
