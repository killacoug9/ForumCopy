//
//  Representatives.swift
//  Forum
//
//  Created by Sam Russell on 12/15/23.
//

import Foundation

struct CivicInfo: Codable {
    let normalizedInput: Address
    let kind: String
    let divisions: [String: Division]
    let offices: [Office]
    let officials: [Official]
}

struct Address: Codable, Equatable, Hashable {
    let line1: String
    let city: String
    let state: String
    let zip: String
    
    func formatted() -> String {
        return "\(line1), \(city), \(state) \(zip)"
    }
}

struct Division: Codable {
    let name: String
    let officeIndices: [Int]?
}

struct Office: Codable {
    let name: String
    let divisionId: String
    let levels: [String]?
    let roles: [String]?
    let officialIndices: [Int]
}

struct Official: Codable, Equatable {
    let name: String
    let address: [Address]?
    let party: String?
    let phones: [String]?
    let urls: [String]?
    let channels: [Channel]?
}

enum OfficeLevel: String, CaseIterable {
    case federal = "country"
    case state = "administrativeArea1"
    case county = "administrativeArea2"
    case local = "locality"
}

struct Channel: Codable, Equatable, Hashable {
    let type: String
    let id: String
}

typealias RepresentativesCompletionHandler = (Result<CivicInfo, Error>) -> Void
func fetchRepresentatives(for address: String, completion: @escaping RepresentativesCompletionHandler) {
    let apiKey = "AIzaSyAotagoOFtRIAi22HU5-luKjX26FilO1w4"
    let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://www.googleapis.com/civicinfo/v2/representatives?key=\(apiKey)&address=\(formattedAddress)"
    guard let url = URL(string: urlString) else {
        completion(.failure(URLError(.badURL)))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotDecodeRawData)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let info = try decoder.decode(CivicInfo.self, from: data)
                completion(.success(info))
            } catch {
                completion(.failure(error))
            }
        }
    }
    task.resume()
}
