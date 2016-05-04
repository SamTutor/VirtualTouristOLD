//
//  MapViewController.swift
//  Virtual_Tourist
//
//  Created by Mac on 4/30/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate,  MKMapViewDelegate  {
    
    
    //Outlets
    @IBOutlet weak var vtitleBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var deletePin: UIBarButtonItem!
    @IBOutlet weak var deleteMessage: UILabel!
    
    let deletePinsMessage = "TAP ON PIN(S) TO DELETE"
    let addPinsMessage = "PRESS ON MAP TO ADD PINS"
    
    let locManager = CLLocationManager()
    let startMessage = "Start Your Journey"
    var pinLat: Double?
    var pinLong: Double?
  
    var mapState: String = "Add"

    
    
    //CORE DATA: Convenience. Useful for fetching, adding, and saving objects
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    
    //FUNC: View Did Load()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        longPressGesture()
        
        deleteMessage.text = addPinsMessage
        deleteMessage.backgroundColor = UIColor.darkGrayColor()
        
        vtitleBar.rightBarButtonItem?.image = UIImage(named: "Delete")
        
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.delegate = self
        
        self.mapView.showsUserLocation = true
        self.mapView.showsPointsOfInterest = true
        self.mapView.delegate = self
        
        self.mapView.addAnnotations(fetchAllPins())
    }// END OF FUNC
    
    
    
    /**
     * This is the convenience method for fetching all persistent pins
     * The method creates a "Fetch Request" and then executes the request on
     * the shared context.
     */
    
    //CORE DATE: FUNC fetchAllPins()
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            
            print("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
    }// END OF FUNC

    
    
    // FUNC: longPressGresture(): Add Gesture Recognizers to the mapView
    func longPressGesture() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPressAction))
        longpress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longpress)
    }// END OF FUNC
    
    
    
    // FUNC: Long Press Action
    func longPressAction(myLongP:UILongPressGestureRecognizer) {
        let myCGPoint = myLongP.locationInView(mapView)
        let myMapPoint = mapView.convertPoint(myCGPoint, toCoordinateFromView: mapView)
        
        let annotations = MKPointAnnotation()
        annotations.coordinate = myMapPoint
        
        //initialize
        annotations.title = "Getting Title Info..."
        annotations.subtitle = "Getting SubTitle Info..."
        
        //geocoder
        let myPinCoordinates = CLLocation(latitude: myMapPoint.latitude, longitude: myMapPoint.longitude)
        CLGeocoder().reverseGeocodeLocation(myPinCoordinates) {
            (myPinPlaces, myPinError) -> Void in

            if (myPinError != nil) {
            }
            
            if let myPinPlaceFirst = myPinPlaces?.first {

                //var myPinName = "\(myPinPlaceFirst.locality!)  \(myPinPlaceFirst.administrativeArea!)"
                let myPinName = "N/A"
                annotations.title = myPinName
                
                //var myPinAddress = "\(myPinPlaceFirst.country!)"
                let myPinAddress = "N/A"
                annotations.subtitle = myPinAddress
            }
        }
        self.mapView.addAnnotation(annotations)
    }// END OF FUNC
    
    

    //FUNC: mapView(): Formats the Pins
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        
            if (annotation.title!! == startMessage) {
                pinView!.pinTintColor = UIColor(red: 1.0, green:0.0, blue:0.0, alpha: 1.0)
                pinView!.leftCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                let delButton = UIButton(type: UIButtonType.System) as UIButton
                delButton.frame.size.width = 35
                delButton.frame.size.height = 35
                delButton.backgroundColor = UIColor.whiteColor()
                delButton.setImage(UIImage(named: "Delete"), forState: .Normal)
                pinView!.rightCalloutAccessoryView = delButton
          
            } else {
                pinView!.pinTintColor = UIColor.purpleColor()
            }
        
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }// END OF FUNC
    
    
    
    // FUNC: mapView(): Triggers a segue to the photo album when the pin is pressed
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)  {
        if (view.annotation?.title!! == startMessage || view.annotation?.title!! == "Current Location"){
            print("selected")
 
        } else {
            
            self.pinLat = view.annotation?.coordinate.latitude
            self.pinLong = view.annotation?.coordinate.longitude
            
            if (self.mapState == "Add") {
                //go to pin details
                mapView.deselectAnnotation(view.annotation, animated: true)
                performSegueWithIdentifier("PinViewController", sender: view.annotation)
    
            } else {
                //remove pins
                mapView.removeAnnotation(view.annotation!)
            }
        }
    }// END OF FUNC
    
    
    
    //FUNC: mapView(): Opens the Links that are associated with the starting pin
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                //Determines if the Link is a valid URL
                if (validUrlChk (toOpen) == false) {
                    self.popAlert("ERROR", errorString: "Invalid Link")
    
                } else {
                }
            }
        
        } else if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("PinViewController", sender: self)
        }
    }// END OF FUNC
    
    
    
    //FUNC: locationManger(): Shows User's Current Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        //get the most recent coordinate
        let myCoordinates = locations[locations.count-1]
        self.locManager.stopUpdatingLocation()
        
        //get lat and long
        let myLat = myCoordinates.coordinate.latitude
        let myLong = myCoordinates.coordinate.longitude
        let myCoord2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        
        //set span
        let myLatDelta = 4.0
        let myLongDelta = 4.0
        let mySpan = MKCoordinateSpan(latitudeDelta: myLatDelta, longitudeDelta: myLongDelta)
        
        //center map at this region
        let myRegion = MKCoordinateRegion(center:myCoord2D, span: mySpan)
        mapView.setRegion(myRegion, animated:true)
        
        //add annotation
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = myCoord2D
        myAnnotation.title = startMessage
        
        mapView.addAnnotation(myAnnotation)
        
        //geocoder
        CLGeocoder().reverseGeocodeLocation(myCoordinates) {
            (myPlaces, myError) -> Void in
        
            if (myError != nil) {
            }
            
            if let myPlaceFirst = myPlaces?.first {
                let myAddress = "\(myPlaceFirst.locality!) \(myPlaceFirst.country!) \(myPlaceFirst.postalCode!)"
                myAnnotation.subtitle = myAddress
            }
        }
    }// END OF FUNC
    
    
    
    //FUNC: locationManager(): Prints Error Messages (Debugger)
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }// END OF FUNC
    

    
    //FUNC: validUrlChk(): Checks if the URL is valid or not
    func validUrlChk (URLinput: String?) -> Bool {
        if URLinput != nil {
            if let URLinput = NSURL(string: URLinput!) {
                return UIApplication.sharedApplication().canOpenURL(URLinput)
            }
        }
        return false
    }// END OF FUNC
    
    
    
    //FUNC: popAlert(): Display an Alrt Box
    func popAlert(typeOfAlert: String, errorString: String) {
        let alertController = UIAlertController(title: typeOfAlert, message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }// END OF FUNC

    
    
    //FUNC: prepareForSeque(): Pass Data to the PinViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let selectedPinViewController: PinViewController = segue.destinationViewController as? PinViewController {
            selectedPinViewController.pinLatitude = self.pinLat!
            selectedPinViewController.pinLongitude = self.pinLong!
        }
    }// END OF FUNC
    
    
    // FUNC: delPin(): Removes the pins
    @IBAction func delPin(sender: AnyObject) {
        if (vtitleBar.rightBarButtonItem?.image == UIImage(named: "Delete")) {
            self.mapState = "Delete"
            deleteMessage.text = deletePinsMessage
            deleteMessage.backgroundColor = UIColor.orangeColor()
            vtitleBar.rightBarButtonItem?.image = UIImage(named: "Done")
            
        } else {
            self.mapState = "Add"
            vtitleBar.rightBarButtonItem?.image = UIImage(named: "Delete")
            deleteMessage.text = addPinsMessage
            deleteMessage.backgroundColor = UIColor.darkGrayColor()
        }
    }
    
}
    
   