//
//  PinViewController.swift
//  Virtual_Tourist
//
//  Created by Mac on 5/2/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PinViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    let reuseIdentifier = "pincell"
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]

    //Initializes
    var pin: Pin!
    
    var pinLatitude: Double?
    var pinLongitude: Double?
    
    @IBOutlet weak var pinMapView: MKMapView!
    
    @IBOutlet weak var picsCollection: UICollectionView!
    
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PinPhotoCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.pinLabel.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.yellowColor() // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    //FUNC: View Did Load()
    override func viewDidLoad() {
        super.viewDidLoad()
        //print (pinLatitude, pinLongitude)
        pinMap()
        //downloadNewPhotoCollection()
        
    }
    
    //CORE DATA: Convenience. Useful for fetching, adding, and saving objects
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    
    //FUNC: pinManager(): Shows Pin on the Map
    func pinMap() {
        //get the most recent coordinate

        
        //get lat and long
        let myLat = self.pinLatitude!
        let myLong = self.pinLongitude!
        let myCoord2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        
        //set span
        let myLatDelta = 0.5
        let myLongDelta = 0.5
        let mySpan = MKCoordinateSpan(latitudeDelta: myLatDelta, longitudeDelta: myLongDelta)
        
        //center map at this region
        let myRegion = MKCoordinateRegion(center:myCoord2D, span: mySpan)
        pinMapView.setRegion(myRegion, animated:true)
        
        //add annotation
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = myCoord2D
        pinAnnotation.title = "Test"
        
        pinMapView.addAnnotation(pinAnnotation)
        
    }
    
    
    // MARK: - Helper Functions
    
 //   func downloadNewPhotoCollection() {
 //
 //       FlickrAPI.sharedInstance().getpinPhotos(pin) { (success, errorString) in
 //
 //           /* If for some reason the photo locations cannot be downloaded, state why in error message */
 //           if success == false {
 //               performOnMain {
 //                   //self.errorMessage.text = errorString
 //                   //self.errorMessage.hidden = false
 //               }
 //           }
 //      }
 //   }

    
}
