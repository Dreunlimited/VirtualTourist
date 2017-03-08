//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 3/1/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?
    
    

}
