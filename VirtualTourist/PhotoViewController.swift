//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 2/25/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var currentCoordinate = CLLocationCoordinate2D()
    var annotation = MKPointAnnotation()
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        annotation.coordinate = currentCoordinate
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentCoordinate, 1000, 1000),animated: true)
        mapView.addAnnotation(annotation)

       fectchImages()
     
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
       
    }
    
    func fectchImages() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sort = NSSortDescriptor(key: "image", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            let results = fetchedResultsController.fetchedObjects?.count
            
        } catch let error as NSError {
            print("Error fecthing pins \(error.localizedDescription)")
        }
    }
    
    
}

extension PhotoViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell
        
        performUIUpdatesOnMain {
           let image =  UIImage(data: photo.image as! Data)
            cell?.photo.image = image
        }
        return cell!
    }
}
