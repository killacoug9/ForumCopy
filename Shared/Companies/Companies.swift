//
//  Companies.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 4/28/24.
//

// TODO: implement seeeing the year of donations on the tile.
// TODO: implement search using FTS search endpoint.
// TODO: implement pagination, needs to be integrated with search.
// TODO: clean styling? looks tacky.
// TODO: ...

import Foundation
import SwiftUI

struct PACResponse: Codable {
    let pagination: Pagination
    let results: [PAC]
}

// MARK: - Pagination Structure
struct Pagination: Codable {
    let count: Int
    let isCountExact: Bool
    let page: Int
    let pages: Int
    let perPage: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case isCountExact = "is_count_exact"
        case page
        case pages
        case perPage = "per_page"
    }
}

// MARK: - PAC Structure
struct PAC: Codable, Identifiable, Equatable{
    let id = UUID() // Unique identifier for each PAC
    let committeeId: String
    let committeeName: String
    let cashOnHandBeginningPeriod: Double
    let totalContributions: Double
    let treasurerName: String
    let individualContributions: Double
    let cycle: Int
    let receipts: Double
    let disbursements: Double
    let cashOnHandEndPeriod: Double
    let netContributions: Double
    
    enum CodingKeys: String, CodingKey {
        case committeeId = "committee_id"
        case committeeName = "committee_name"
        case cashOnHandBeginningPeriod = "cash_on_hand_beginning_period"
        case totalContributions = "contributions"
        case treasurerName = "treasurer_name"
        case individualContributions = "individual_contributions"
        case cycle
        case receipts
        case disbursements
        case cashOnHandEndPeriod = "last_cash_on_hand_end_period"
        case netContributions = "net_contributions"
    }
    
    // Implement Equatable
        static func == (lhs: PAC, rhs: PAC) -> Bool {
            return lhs.committeeName == rhs.committeeName &&
                   lhs.committeeId == rhs.committeeId &&
                   lhs.cashOnHandBeginningPeriod == rhs.cashOnHandBeginningPeriod &&
                   lhs.totalContributions == rhs.totalContributions &&
                   lhs.treasurerName == rhs.treasurerName &&
                   lhs.cycle == rhs.cycle &&
                   lhs.receipts == rhs.receipts &&
                   lhs.disbursements == rhs.disbursements &&
                   lhs.cashOnHandEndPeriod == rhs.cashOnHandEndPeriod &&
                   lhs.netContributions == rhs.netContributions
        }
}


struct Companies: View {
    @State private var companies: [PAC] = []
    //@State private var data: PACResponse
    @State private var pagination: Pagination? = nil // Stores the current pagination info
    @State private var isLoadingMore: Bool = false // TODO: idk what this does.
    @State private var errorMessage: String?
    @State private var currentCycle: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Companies")
                    .bold()
                    .padding(.top, 60)
                    .padding(.leading, 25)
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        } else {
                            ForEach(companies, id: \.id) { company in
                                
                                VStack {
                                    NavigationLink(destination: PACView(pac: company)) {
                                        PACEntry(pac: company)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Divider()
                                    // Load more data when reaching the last item
                                    if company == companies.last {
                                        ProgressView() // Optional loading spinner
                                            .onAppear {
                                                if let pagination = pagination, pagination.page < pagination.pages {
                                                    loadCompanies(page: pagination.page + 1)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
            }
            .onAppear {
                loadCompanies()
            }
            .background(Color("Cream"))
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Use maximum height and width
            
        }
        
    }
    

    func loadCompanies(page: Int = 1)
    {
        if isLoadingMore || (pagination != nil && page > pagination!.pages) {
            return
        }

        getCompanyData(page: page) { result in
            DispatchQueue.main.async {
                self.isLoadingMore = false
                
                switch result {
                case .success(let companyResponse):
                    self.companies.append(contentsOf: companyResponse.results)
                    self.pagination = companyResponse.pagination // Update the entire pagination struct
                case .failure(let error):
                    self.errorMessage = "Failed to fetch PACs: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getCompanyData(page: Int, completion: @escaping (Result<PACResponse, Error>) -> Void) {
        let key = "lVIlJSRW5dz9ae1bNvLWYmtRHglvWkMjdNbVKARb"
        // TODO: Find way to make API paramaters modifiable by the user.
        
        guard let url = URL(string: "https://api.open.fec.gov/v1/totals/pac-party/?page=\(page)&per_page=20&cycle=2024&organization_type=C&sort=-net_contributions&sort_hide_null=false&sort_null_only=false&sort_nulls_last=false&api_key=\(key)") else {
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
                    let responseData = try decoder.decode(PACResponse.self, from: data)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
    }

}


// Helper function to format numbers without trailing zeros
 func formatNumber(_ number: Double) -> String {
     let formatter = NumberFormatter()
     formatter.minimumFractionDigits = 0
     formatter.maximumFractionDigits = 2
     formatter.numberStyle = .decimal
     return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
 }
