//
//  CoreDataManager.swift
//  AacountInfo
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

//
//  CoreDataManager.swift
//  AacountInfo
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {
        persistentContainer = NSPersistentContainer(name: "AccountData")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Core Data load error: \(error.localizedDescription)")
            }
        }
    }

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error.localizedDescription)")
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - CRUD for Accounts

    func saveAccounts(_ accounts: [AccountModel]) {
        for account in accounts {
            let entity = UserAccount(context: context)
            entity.accountId = Int64(account.actid ?? 0)
            entity.accountName = account.ActName
            entity.alternateName = account.alternateName
        }
        saveContext()
    }

    func fetchAccounts() -> [AccountModel] {
        let request: NSFetchRequest<UserAccount> = UserAccount.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { AccountModel(ActName: $0.accountName ?? "", actid: Int($0.accountId), alternateName: $0.alternateName) }
        } catch {
            print("Failed to fetch accounts: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAccount(_ account: AccountModel) {
        let fetchRequest: NSFetchRequest<UserAccount> = UserAccount.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "accountId == %d", account.actid ?? 0)

        do {
            let results = try context.fetch(fetchRequest)
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                saveContext()
            } else {
                print("No matching account found in Core Data to delete.")
            }
        } catch {
            print("Failed to fetch account for deletion: \(error.localizedDescription)")
        }
    }


}
