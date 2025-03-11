//
//  AppointmentType+CoreDataProperties.swift
//  Assignment
//
//  Created by Gabi Franck on 18/5/2023.
//
//

import Foundation
import CoreData


extension AppointmentType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppointmentType> {
        return NSFetchRequest<AppointmentType>(entityName: "AppointmentType")
    }

    @NSManaged public var type: String?
    @NSManaged public var cost: String?

}

extension AppointmentType : Identifiable {

}
