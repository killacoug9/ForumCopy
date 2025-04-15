import Foundation

struct BillResponse: Codable {
    let bills: [Bill]
}

struct Bill: Codable {
    let congress: Int
    let latestAction: LatestAction
    let number: String
    let originChamber: String
    let originChamberCode: String
    let title: String
    let type: String
    let updateDate: String
    let updateDateIncludingText: String
    let url: String
}

struct LatestAction: Codable {
    let actionDate: String
    let text: String
}

func getBillData(completion: @escaping (Result<BillResponse, Error>) -> Void) {
    let key = "bdJO4SE8CAvYw46VXOvkayhbupxuVZrfv8nEF6mJ"
    guard let url = URL(string: "https://api.congress.gov/v3/bill?api_key=\(key)") else {
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
                let responseData = try decoder.decode(BillResponse.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Start the task
    task.resume()
}
