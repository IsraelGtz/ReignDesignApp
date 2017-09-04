//
//  PostCD+CoreDataProperties.swift
//  
//
//  Created by Israel on 03/09/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PostCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostCD> {
        return NSFetchRequest<PostCD>(entityName: "PostCD");
    }

    @NSManaged public var id: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}
