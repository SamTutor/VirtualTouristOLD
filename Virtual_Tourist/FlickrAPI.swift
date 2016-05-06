//
//  FlickrAPI.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class FlickrAPI : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // MARK: - Help with updating the Config
    func getpinPhotos(pin: Pin, completionHandler: (didSucceed: Bool, error: String?) -> Void) {
        print ("getpinPhotos")
        
        let methodArguments = [
            "method": FlickrParameterValues.SearchMethod,
            "api_key": FlickrParameterValues.APIKey,
            "bbox": createBoundingBoxString(pin),
            "safe_search": FlickrParameterValues.UseSafeSearch,
            "extras": FlickrParameterValues.MediumURL,
            "format": FlickrParameterValues.ResponseFormat,
            "nojsoncallback": FlickrParameterValues.DisableJSONCallback,
            "per_page": FlickrParameterValues.Page
        ]

        
        let session = NSURLSession.sharedSession()
        let url = constructFlickrURL()
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

       
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(didSucceed: false, error: "There was a network error with your request.")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(didSucceed:  false, error: "There was a network error with your request.")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(didSucceed: false, error: "There was a network error with your request.")
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(didSucceed: false, error: "There was a network error with your request.")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(didSucceed: false, error: "There was a data error with your request.")
                return
            }
   
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                completionHandler(didSucceed:  false, error: "There was a data error with your request.")
                return
            }

            
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                completionHandler(didSucceed:  false, error: "There was an error with the Flickr service.")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find key 'photos' in \(parsedResult)")
                completionHandler(didSucceed: false, error: "There was an error reading the photo data.")
                return
            }
            
            /* GUARD: Is the "total" key in photosDictionary? */
            guard let totalPhotosVal = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                completionHandler(didSucceed:  false, error: "There was an error reading the photo data.")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                print("Cannot find key 'photo' in \(photosDictionary)")
                completionHandler(didSucceed: false, error: "There was an error reading the photo data.")
                return
            }
            
            /* Use comparison tests to see what photos, if any, were returned */
            if photosArray.count == 0 && totalPhotosVal > 0 {
                completionHandler(didSucceed:  false, error: "There are no more photos for this location.")
            } else if photosArray.count == 0 && totalPhotosVal == 0 {
                completionHandler(didSucceed: false, error: "There are no photos for this location.")
            } else {
                for photo in photosArray {
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photo["url_m"] as? String else {
                        print("Cannot find key 'url_m' in \(photo)")
                        completionHandler(didSucceed: false, error: "There was an error reading the photo data.")
                        return
                    }
                    
                    /* GUARD: Does our photo have a key for 'id'? */
                    guard let photoID = photo["id"] as? String else {
                        print("Cannot find key 'id' in \(photo)")
                        completionHandler(didSucceed:  false, error: "There was an error reading the photo data.")
                        return
                    }
                    
                    performOnMain {
                        /* Create a new photo object */
                        let _ = Photo(pin: pin, id: photoID, url: imageUrlString, context: self.sharedContext)
                        
                        /* Save the Core Data Context that includes the new photo object */
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                    
                }
                
                performOnMain {
                    /* If the download has been successful, increment the page number for the next network call */
                    pin.pageNumber = pin.pageNumber + 1
                }
                /* Send back a success message to the caller through the completion handler */
                completionHandler(didSucceed: true, error: nil)
            }
            
        }
        
        task.resume()
    }

    
    func downloadPhoto(photo: Photo, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // citation: http://stackoverflow.com/questions/28868894/swift-url-reponse-is-nil
        let session = NSURLSession.sharedSession()
        let imageURL = NSURL(string: photo.url)
        
        let sessionTask = session.dataTaskWithURL(imageURL!) { data, response, error in
            
            /* GUARD: Was data returned? */
            guard let data = data else {
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            
            performOnMain {
                /* Add the downloaded photo image to the photo object */
                photo.flickrImage = UIImage(data: data)
            }
            /* Send back a success message to the caller through the completion handler */
            completionHandler(success: true, errorString: nil)
            
        }
        
        sessionTask.resume()
    }
    
    // MARK: - Helper Functions
    
    /* Set the box boundaries of the search for the pin location */
    func createBoundingBoxString(pin: MKAnnotation) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - FlickrParameterValues.BOUNDING_BOX_HALF_WIDTH, FlickrParameterValues.LON_MIN)
        let bottom_left_lat = max(latitude - FlickrParameterValues.BOUNDING_BOX_HALF_HEIGHT, FlickrParameterValues.LAT_MIN)
        let top_right_lon = min(longitude + FlickrParameterValues.BOUNDING_BOX_HALF_HEIGHT, FlickrParameterValues.LON_MAX)
        let top_right_lat = min(latitude + FlickrParameterValues.BOUNDING_BOX_HALF_HEIGHT, FlickrParameterValues.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* Construct a Flickr URL from parameters */
    func constructFlickrURL() -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = FlickrConstants.APIScheme
        components.host = FlickrConstants.APIHost
        components.path = FlickrConstants.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        print (components.URL!)
        return components.URL!
        
    }
    
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    
    // MARK: - Shared Class Instance
    
    class func sharedInstance() -> FlickrAPI{
        
        struct Singleton {
            static var sharedInstance = FlickrAPI()
        }
        
        return Singleton.sharedInstance
    }
    

    
    

  }
