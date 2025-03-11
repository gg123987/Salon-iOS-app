//
//  Client+CoreDataProperties.swift
//  Assignment
//
//  Created by Gabi Franck on 10/5/2023.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?

}

extension Client : Identifiable {

}
