//
//  Network.swift
//  IdentityVault
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    
    func fetchAccounts(completion: @escaping (Result<[AccountModel], Error>) -> Void) {
        AF.request("https://fssservices.bookxpert.co/api/Fillaccounts/nadc/2024-2025").responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    // Step 1: Decode the top-level JSON string
                    let jsonString = try JSONDecoder().decode(String.self, from: data)
                    print("JSON String: \(jsonString)")

                    // Step 2: Convert the string back to Data
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        print("Failed to convert JSON string to Data")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "String to Data conversion failed."])))
                        return
                    }

                    // Step 3: Decode the actual array
                    let accounts = try JSONDecoder().decode([AccountModel].self, from: jsonData)
                    print("Decoded Accounts: \(accounts)")
                    completion(.success(accounts))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Request error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func downloadPDF(from urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400)))
                return
            }
            
            let destination: DownloadRequest.Destination = { _, _ in
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(url, to: destination).response { response in
                if let fileURL = response.fileURL {
                    completion(.success(fileURL))
                } else {
                    completion(.failure(response.error ?? NSError(domain: "Download error", code: 500)))
                }
            }
        }
}
