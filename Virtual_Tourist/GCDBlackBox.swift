//
//  GCDBlackBox.swift
//  Virtual_Tourist
//
//  Created by Mac on 5/5/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation

/* Global GCD function to update main queue */
func performOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}