//
//  User+CoreDataProperties.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 07/08/25.
//
//

import Foundation
import CoreData

@objc(UserCD)
public class UserCD: NSManagedObject {

}


extension UserCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCD> {
        return NSFetchRequest<UserCD>(entityName: "User")
    }

    @NSManaged public var id: String?
    @NSManaged public var username: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var bio: String?
    
    static func insert(into context: NSManagedObjectContext) -> UserCD {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        return UserCD(entity: entity, insertInto: context)
    }
}

extension UserCD : Identifiable {

}
