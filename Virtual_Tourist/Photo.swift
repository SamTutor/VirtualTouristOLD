//
//  Photo.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//
import Foundation
import UIKit

// 1. Import CoreData
import CoreData

// 2. Make Photo a subclass of NSManagedObject
class Photo : NSManagedObject {
    
    struct Keys {
        static let Url = "url_m"
        static let Id = "id"
    }

    // 3. Simple properties, to Core Data attributes
    @NSManaged var url: String
    @NSManaged var id: String?
    @NSManaged var pin: Pin?
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
     * 5. The two argument init method
     *
     * The Two argument Init method. The method has two goals:
     *  - insert the new Photo into a Core Data Managed Object Context
     *  - initialze the Photo's properties from a dictionary
     */
    init(pin: Pin, id: String, url: String, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Photo" type.  This is an object that contains
        // the information from the Virtual_Tourist.xcdatamodeld file.        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Photo class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary.
        self.url = url
        self.pin = pin
        self.id = id + ".png"
    }
    
    var flickrImage: UIImage? {
        
        get {
            print(" GET Image")
            return FlickrAPI.Caches.imageCache.imageWithIdentifier(id)
        }
        
        set {
            print(" SET Image")
            FlickrAPI.Caches.imageCache.storeImage(newValue, withIdentifier: id!)
        }
    }
}

