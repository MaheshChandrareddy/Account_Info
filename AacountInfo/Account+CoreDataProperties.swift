//
//  Account+CoreDataProperties.swift
//  AacountInfo
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var accountName: String?
    @NSManaged public var accountId: Int64

}

extension Account : Identifiable {

}
