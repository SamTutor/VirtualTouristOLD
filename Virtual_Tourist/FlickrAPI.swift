//
//  FlickrAPI.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation

class FlickrAPI : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    override init() {
        super.init()
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrAPI {
        
        struct Singleton {
            static var sharedInstance = FlickrAPI()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Date Formatter
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }

    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Help with updating the Config
    func updateConfig(completionHandler: (didSucceed: Bool, error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        //taskForResource(Resources.Config, parameters: parameters) { JSONResult, error in
       //
       //     if let error = error {
      //          completionHandler(didSucceed: false, error: error)
      //      } else if let newConfig = Config(dictionary: JSONResult as! [String : AnyObject]) {
      //          self.config = newConfig
      //          completionHandler(didSucceed: true, error: nil)
      //      } else {
      //          completionHandler(didSucceed: false, error: NSError(domain: "Config", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse config"]))
      //      }
      //  }
    }

  }
