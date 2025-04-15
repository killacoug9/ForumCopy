//
//  Feed.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/17/24.
//

import Foundation
import SwiftUI

struct LawsList: View {
    @State private var bills: [Bill] = []
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 10)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    ForEach(bills, id: \.number) { bill in
                        VStack(alignment: .leading) {
                            Text(bill.title)
                                .font(.headline)
                                .foregroundColor(Color("Text"))
                            Text("Number: \(bill.number)")
                                .foregroundColor(Color("Text"))
                            Text("Type: \(bill.type)")
                                .foregroundColor(Color("Text"))
                            Text("Updated: \(bill.updateDate)")
                                .foregroundColor(Color("Text"))
                            Link("More Info", destination: URL(string: bill.url)!)
                                .foregroundColor(.blue)
                        }
                        .padding()
//                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadBills()
        }
    }
    
    func loadBills() {
        getBillData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let billResponse):
                    self.bills = billResponse.bills
                case .failure(let error):
                    self.errorMessage = "Failed to fetch bills: \(error.localizedDescription)"
                }
            }
        }
    }
}
