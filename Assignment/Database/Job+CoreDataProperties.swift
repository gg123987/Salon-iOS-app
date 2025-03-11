//
//  Job+CoreDataProperties.swift
//  Assignment
//
//  Created by Gabi Franck on 7/6/2023.
//
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var dropoff_date: Date?
    @NSManaged public var isComplete: String?
    @NSManaged public var pickup_date: Date?
    @NSManaged public var quote: String?
    @NSManaged public var job_appointmentType: AppointmentType?
    @NSManaged public var job_client: Client?

}

extension Job : Identifiable {

}
