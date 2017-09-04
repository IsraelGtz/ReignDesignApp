//
//  DeletedPostCD+CoreDataProperties.swift
//  
//
//  Created by Israel on 03/09/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension DeletedPostCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeletedPostCD> {
        return NSFetchRequest<DeletedPostCD>(entityName: "DeletedPostCD");
    }

    @NSManaged public var id: String?

}
