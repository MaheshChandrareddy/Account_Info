//
//  AccountListViewModel.swift
//  IdentityVault
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import Foundation
import CoreData

class AccountListViewModel {
    
    var accounts: [AccountModel] = []
    
    func getAccounts(completion: @escaping () -> Void) {
        // Step 1: Check if data exists in Core Data
        let storedAccounts = CoreDataManager.shared.fetchAccounts()
        
        if !storedAccounts.isEmpty {
            // Use cached data
            self.accounts = storedAccounts
            completion()
        } else {
            // Step 2: If not, fetch from API
            APIManager.shared.fetchAccounts { result in
                switch result {
                case .success(let accounts):
                    self.accounts = accounts
                    
                    // Step 3: Save to Core Data
                    CoreDataManager.shared.saveAccounts(accounts)
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                case .failure(let error):
                    print("Error fetching accounts: \(error.localizedDescription)")
                }
            }
        }
    }

    func numberOfRows() -> Int {
        return accounts.count
    }

    func account(at index: Int) -> AccountModel? {
        guard index >= 0 && index < accounts.count else { return nil }
        return accounts[index]
    }
    
    func deleteAccount(at index: Int) {
        guard index < accounts.count else { return }
        let accountToDelete = accounts[index]
        CoreDataManager.shared.deleteAccount(accountToDelete)
        accounts.remove(at: index)
    }

     func updateAccountName(for id: Int, newName: String, completion: (() -> Void)? = nil) {
        CoreDataManager.shared.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<UserAccount> = UserAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "accountId == %d", id)
            fetchRequest.fetchLimit = 1

            do {
                if let account = try context.fetch(fetchRequest).first {
                    account.accountName = newName

                    try context.save()
                    DispatchQueue.main.async {
                        completion?()
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }


    func updateAlternateName(forid: Int, alternateName: String, completion: (() -> Void)? = nil) {
        CoreDataManager.shared.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<UserAccount> = UserAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "accountId == %d", forid)
            fetchRequest.fetchLimit = 1
            
            do {
                if let account = try context.fetch(fetchRequest).first {
                    print("✅ Found account with id: \(forid), old alternative name: \(account.alternateName ?? "-")")
                    account.alternateName = alternateName
                    
                    try context.save()
                    print("✅ Updated alternativename to: \(alternateName)")
                    
                    DispatchQueue.main.async {
                        completion?()
                    }
                } else {
                    print("⚠️ No account found with id: \(forid)")
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            } catch {
                print("❌ Failed to update account name: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    func fetchPDF(completion: @escaping (Result<URL, Error>) -> Void) {
            let url = "https://fssservices.bookxpert.co/GeneratedPDF/Companies/nadc/2024-2025/BalanceSheet.pdf"
            APIManager.shared.downloadPDF(from: url, completion: completion)
        }
}
