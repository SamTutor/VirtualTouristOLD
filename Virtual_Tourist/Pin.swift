//
//  Pin.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import MapKit
// 1. Import CoreData
import CoreData

// 2. Make Pin a subclass of NSManagedObject
class Pin: NSManagedObject, MKAnnotation {
    
    // 3. Simple properties, to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var pageNumber: Int
    @NSManaged var photos: [Photo]
    
    let imageCache = ImageCache()
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //5. Write an init method that only needs a context.
    init(pinAnnLatitude: Double, pinAnnLongitude: Double, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the Virtual_Tourist.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        latitude = NSNumber(double: pinAnnLatitude)
        longitude = NSNumber(double: pinAnnLongitude)
        
        /* Save the Core Data Context that includes the new pin object */
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    @objc var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
    
}


// MARK: - Core Data Convenience

var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance().managedObjectContext
}