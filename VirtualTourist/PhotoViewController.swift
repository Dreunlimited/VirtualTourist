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
    var pin = Pin()
    var photos = [Photo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
         print("My \(pin)")
          fectchImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        annotation.coordinate = currentCoordinate
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentCoordinate, 1000, 1000),animated: true)
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func fectchImages() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sort = NSSortDescriptor(key: "image", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)

        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            self.collectionView.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as?
        PhotoCollectionViewCell
        
        FlickrClient.sharedInstance().convertStringToImage(photo) { (image, error) in
            if photo.image != nil {
                if error != nil {
                print("Error \(error)")
            } else {
                performUIUpdatesOnMain {
                    cell?.photo.image = image
                }
            }
            } else {
                        performUIUpdatesOnMain {
                           let image =  UIImage(data: photo.image as! Data)
                           cell?.photo.image = image
                        }
            }
        }
            return cell!
    }
}

// cell.activiy.startanimating
// photo.image != nil -> image data in core data -> create UIIMage from binary data
// esle now download the image -> call the web servi e
// photo entity
// image url
//        performUIUpdatesOnMain {
////           let image =  UIImage(data: photo.image as! Data)
////            cell?.photo.image = image
//        }

