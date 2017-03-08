//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 3/2/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    func deletePhotos(_ context: NSManagedObjectContext, handler: (_ error: String?) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin == %@", self)
        
        do {
            let photos = try context.fetch(request) as! [Photo]
            for photo in photos {
                context.delete(photo)
            }
        } catch { }
        
        handler(nil)
    }

}
