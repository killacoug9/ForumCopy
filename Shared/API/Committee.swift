//
//  Committee.swift
//  Forum
//
//  Created by Sam Russell on 6/26/23.
//

import Foundation

struct CommitteeResponse: Codable {
    let committees: [Committee]
}

struct Committee: Codable {
    let chamber: String
    let committeeTypeCode: String
    let name: String
    let parent: Parent?
    let subcommittees: [Subcommittee]?
    let systemCode: String
    let url: String
}

struct Subcommittee: Codable {
    let name: String
    let systemCode: String
    let url: String
}

struct Parent: Codable {
    let name: String
}

enum Chamber {
    case house
    case senate
    case none
}

func getCommitteeData(chamber: Chamber = .none, callback: @escaping (Result<CommitteeResponse, Error>) -> Void) {
    let key = "bdJO4SE8CAvYw46VXOvkayhbupxuVZrfv8nEF6mJ"
    var chamberArg : String
    switch chamber {
        case .house:
            chamberArg = "/house"
        case .senate:
            chamberArg = "/senate"
        case .none:
            chamberArg = ""
    }
    guard let url = URL(string: "https://api.congress.gov/v3/committee\(chamberArg)?api_key=\(key)") else {
        callback(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            callback(.failure(error))
            return
        }
        
        if let data = data {
            do {
                // Parse the JSON data into a Swift object
                let decoder = JSONDecoder()
                print("data: ", data)
                let responseData = try decoder.decode(CommitteeResponse.self, from: data)
                callback(.success(responseData))
            } catch {
                callback(.failure(error))
            }
        }
    }
    
    task.resume()
}
