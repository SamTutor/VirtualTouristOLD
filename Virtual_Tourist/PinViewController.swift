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

class PinViewController: UIViewController {
    
    //Initializes
    var pinLatitude: Double?
    var pinLongitude: Double?
    
    @IBOutlet weak var pinMapView: MKMapView!
    
    //FUNC: View Did Load()
    override func viewDidLoad() {
        super.viewDidLoad()
        print (pinLatitude, pinLongitude)
        pinMap()
        
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

    
}
