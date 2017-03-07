//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 2/25/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import SafariServices
import ReachabilitySwift




class MapViewController: UIViewController, MKMapViewDelegate {
    let reachability = Reachability()!

    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
  
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var pin = Pin()
    var pageNum = UserDefaults()
    var number: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reachability.currentReachabilityStatus == .notReachable {
            performUIUpdatesOnMain {
                alert("Lost of internet connection", "Try again", self)
            }
        } else {
            
            self.mapView.delegate = self
            let mapTouched = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapTouched(gestureRecognizer:)))
            mapView.addGestureRecognizer(mapTouched)
        }
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            
            fectchPins()
    }
    
    
    func mapTouched(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let pinDropped = MKPointAnnotation()
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            pinDropped.coordinate = newCoordinates
            mapView.addAnnotation(pinDropped)
            
            savePin(Double(pinDropped.coordinate.latitude), long: Double(pinDropped.coordinate.longitude))
            
            if reachability.currentReachabilityStatus == .notReachable {
                performUIUpdatesOnMain {
                    alert("Lost of internet connection", "Try again", self)
                }
            } else {
                
            FlickrClient.sharedInstance().getImages("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1201bff4632c3631ae68d58d6bce474c&lat=\(pinDropped.coordinate.latitude)&lon=\(pinDropped.coordinate.longitude)&per_page=20&format=json&nojsoncallback=1", pin)
                
                 number  = pageNum.value(forKey: "pageNumber") as! Int
            }
        }
    }
    
    func savePin(_ lat:Double, long:Double) {
        
        let managedContext = appDelegate?.persistentContainer.viewContext
        pin = Pin(entity: Pin.entity(), insertInto: managedContext)
        pin.latitude = Double(lat)
        pin.longitude = Double(long)
        
        
        do {
            try managedContext?.save()
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not save \(error.userInfo)")
        }
    }
    

    func fectchPins() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sort = NSSortDescriptor(key: "latitude", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            let results = fetchedResultsController.fetchedObjects
            var pins = [MKPointAnnotation]()
            for pin in results! {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
                annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
                pins.append(annotation)
                mapView.addAnnotation(annotation)
            }
            
        } catch let error as NSError {
            print("Error fecthing pins \(error.localizedDescription)")
        }
        
    }
    
}

extension MapViewController {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let photoVC = storyboard?.instantiateViewController(withIdentifier: "photoVC") as! PhotoViewController
            photoVC.currentCoordinate = (view.annotation?.coordinate)!
        
        let pins = fetchedResultsController.fetchedObjects
            for pin in pins! {
                if pin.latitude == Double((view.annotation?.coordinate.latitude)!) && pin.longitude == Double((view.annotation?.coordinate.longitude)!) {
                    photoVC.pin = pin
                    navigationController?.pushViewController(photoVC, animated: true)
            }
            
        }
       
        
    }
    
}
