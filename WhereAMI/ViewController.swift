//
//  ViewController.swift
//  WhereAMI
//
//  Created by Chris Prince on 8/25/16.
//  Copyright © 2016 Angies List. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

private class LocationInfo {
    var location:CLLocation!
    var address:String?
    static var geocoder = CLGeocoder()
    
    init(withLocation location:CLLocation, geocodingComplete:()->()) {
        self.location = location
        
        LocationInfo.geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            if let placemark = placemarks?[0] where placemark.addressDictionary != nil {
                
                let postalAddress =
                    CNPostalAddressFormatter.postalAddressFromAddressDictionary(placemark.addressDictionary!)
                let addressString = CNPostalAddressFormatter.stringFromPostalAddress(postalAddress, style: .MailingAddress)
                self.address = addressString.stringByReplacingOccurrencesOfString("\n", withString: ", ")
                
                print(self.address)
                
                geocodingComplete()
            }
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let cellReuseId = "CellReuseId"
    
    // https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/
    let locationManager = CLLocationManager()
    
    private var locations = [LocationInfo]()
    
    // Debouncing the add button. For some reason, we can get what looks like multiple hits.
    private var currentlyGettingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // You also have to add a key to the info.plist. See: http://matthewfecher.com/app-developement/getting-gps-location-using-core-location-in-ios-8-vs-ios-7/ in order to get the user prompted.
        
        // This just checks to see if we are authorized-- it doesn't actually ask the user.
        let locationServicesStatus = CLLocationManager.authorizationStatus()
        
        switch  locationServicesStatus {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            NSLog("Already authorized to use location services")
            
        case .NotDetermined:
            NSLog("User will be asked if we can use location services")
            self.locationManager.requestWhenInUseAuthorization()
            
        default:
            NSLog("Not authorized to use location services")
        }
    }
    
    @IBAction func addAction(sender: AnyObject) {
        if !self.currentlyGettingLocation {
            self.currentlyGettingLocation = true
            self.locationManager.requestLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath)
        
        let location = self.locations[indexPath.row].location
        let latLong = "\(location.coordinate.latitude); \(location.coordinate.longitude)"
        cell.textLabel!.text = latLong
        
        cell.detailTextLabel!.text = self.locations[indexPath.row].address
            
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.locations.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("New authorization status: \(status.rawValue)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        if !self.currentlyGettingLocation {
            return
        }
        
        self.currentlyGettingLocation = false
        
        let locationInfo = LocationInfo(withLocation: locations[0]) {
            self.tableView.reloadData()
        }
        
        self.locations = [locationInfo] + self.locations
        self.tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}

// See http://stackoverflow.com/questions/7848291/how-to-get-formatted-address-nsstring-from-addressdictionary/29327953
extension CNPostalAddressFormatter {
    // Convert to the newer CNPostalAddress
    class func postalAddressFromAddressDictionary(dict: Dictionary<NSObject,AnyObject>) -> CNMutablePostalAddress {
        
        let address = CNMutablePostalAddress()
        
        address.street = dict["Street"] as? String ?? ""
        address.state = dict["State"] as? String ?? ""
        address.city = dict["City"] as? String ?? ""
        address.country = dict["Country"] as? String ?? ""
        address.postalCode = dict["ZIP"] as? String ?? ""
        
        return address
    }
}

