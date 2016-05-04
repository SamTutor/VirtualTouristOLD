//
//  Pin.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation

// 1. Import CoreData
import CoreData

// 2. Make Pin a subclass of NSManagedObject
class Pin : NSManagedObject {
    
    // 3. Simple properties, to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var hashNumber: NSNumber
    @NSManaged var photos: [Photo]
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //5. Write an init method that only needs a context.
    init(context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the Virtual_Tourist.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        //latitude = coordinate.latitude
        //longitude = coordinate.longitude
    }
    
//    var coordinate: CLLocationCoordinate2D {
//        get {
//            return CLLocationCoordinate2DMake(latitude, longitude)
//        }
//        set {
//            latitude = newValue.latitude
//            longitude = newValue.longitude
//        }
  //  }

}
