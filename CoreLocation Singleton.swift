//
//  CoreLocation Singleton.swift
//  Go
//
//  Created by Amir lahav on 15/02/2019.
//  Copyright © 2019 LA Computers. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class CoreLocationServiceManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - shared CoreLocation Service Manager

    
    private static var sharedLcationManager: CoreLocationServiceManager = {
        
        let locationServiceManager = CoreLocationServiceManager()
        
        return locationServiceManager
        
    }()
    
    let debugMode:String = "debugMode"
    
    var DEBUG:Bool { return UserDefaults.standard.bool(forKey: debugMode) }
    
    // MARK: - prive initiation
    
    private let locationManager = CLLocationManager()
    
    // Initialization
    
    private override init() {
        
        super.init()
        
        
        // configuration
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
    }
    
    // MARK: - Accessors
    
    class func shared() -> CoreLocationServiceManager {
        return sharedLcationManager
    }
    
    
    func startLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if DEBUG{
                print("start location service")
            }
            locationManager.startUpdatingLocation()
        }
    }
    
    func startHeadingServices() {
        if CLLocationManager.locationServicesEnabled() {
            if DEBUG{
                print("start heading service")
            }
            locationManager.startUpdatingHeading()
        }
    }
    
    
    func stopLocationServices()
    {
        if CLLocationManager.locationServicesEnabled() {
            if DEBUG{
                print("stop location service")
            }
            locationManager.stopUpdatingLocation()
        }
    }
    func stopHeadingServices()
    {
        if CLLocationManager.locationServicesEnabled() {
            if DEBUG{
                print("stop heading service")
            }
            locationManager.stopUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // chacking for last location
        guard let location = locations.last else {  return }
        
        // Post data
        let userInfo:[RouteControllerNotificationUserInfoKey:CLLocation] = [RouteControllerNotificationUserInfoKey.rawLocation:location]
        
        // Post Notification Center
        NotificationCenter.default.post(name: .navigationLocationDidChange, object: nil, userInfo: userInfo)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 { return }
        
        
        // cheacking for trueHeading
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        
        // Post data
        var userInfo : [RouteControllerNotificationUserInfoKey: CLLocationDirection] = [RouteControllerNotificationUserInfoKey.heading:heading]
        
        let headingAccurcy:[RouteControllerNotificationUserInfoKey: CLLocationAccuracy] = [RouteControllerNotificationUserInfoKey.headingAccurcy:newHeading.headingAccuracy]
        
        
        // Post Notification Center
        NotificationCenter.default.post(name: .navigationHeadingDidChange, object: nil, userInfo: userInfo)
        
        NotificationCenter.default.post(name: .navigationHeadingDidChange, object: nil, userInfo: headingAccurcy)
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        
        return true
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    
}


extension Notification.Name {
    static let navigationLocationDidChange = NSNotification.Name(rawValue: "navigationLocationDidChange")
    static let navigationHeadingDidChange = NSNotification.Name(rawValue: "navigationHeadingDidChange")
}

enum RouteControllerNotificationUserInfoKey: String, Hashable
{
    case rawLocation
    case heading
    case headingAccurcy = "headingAccurcy"
}
