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
    @IBOutlet weak var refreshImagesButton: UIButton!

    var currentCoordinate = CLLocationCoordinate2D()
    var annotation = MKPointAnnotation()
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var pin = Pin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        annotation.coordinate = currentCoordinate
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentCoordinate, 1000, 1000),animated: true)
        mapView.addAnnotation(annotation)
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.toolbar.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fectchImages()
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func refreshImagesButton(_ sender: Any) {
        let randomNumber = arc4random_uniform(UInt32(20))
        
        performUIUpdatesOnMain {
            self.pin.removeFromPhotos(self.pin.photos!)

        }
        
        
        FlickrClient.sharedInstance().getImages("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1201bff4632c3631ae68d58d6bce474c&page=\(randomNumber)&lat=\(currentCoordinate.latitude)&lon=\(currentCoordinate.longitude)&per_page=20&format=json&nojsoncallback=1", pin)
        
        self.fectchImages()
        try? fetchedResultsController.managedObjectContext.save()
        self.collectionView.reloadData()
        
    }
    
    func onClickedToolbeltButton(_ sender: UIBarButtonItem) {
        let indexPaths = collectionView.indexPathsForSelectedItems! as[IndexPath]
        for indexPath in indexPaths {
            let photo = fetchedResultsController.object(at: indexPath)
                        fetchedResultsController.managedObjectContext.delete(photo)
            collectionView.deleteItems(at: indexPaths)
            collectionView.reloadData()
           
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
        
        cell?.activityIndicator.startAnimating()
        FlickrClient.sharedInstance().convertStringToImage(photo) { (image, error) in
            if photo.image != nil {
                if error != nil {
                    print("Error \(error)")
                } else {
                    performUIUpdatesOnMain {
                        cell?.photo.image = image
                        cell?.activityIndicator.stopAnimating()
                        cell?.activityIndicator.isHidden = true
                    }
                }
            } else {
                performUIUpdatesOnMain {
                    if let image =  UIImage(data: photo.image as! Data) {
                        cell?.photo.image = image
                        cell?.editing = self.isEditing
                        self.collectionView.reloadData()
                        try? self.fetchedResultsController.managedObjectContext.save()
                        cell?.activityIndicator.stopAnimating()
                    }
                    
                }
            }
        }
        return cell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let photo = fetchedResultsController.object(at: indexPath)
//        fetchedResultsController.managedObjectContext.delete(photo)
//        
//        performUIUpdatesOnMain {
//        
//        collectionView.deleteItems(at: [indexPath])
//        collectionView.reloadData()
//        }
        
        if isEditing {
            navigationController?.setToolbarHidden(false, animated: true)
            var items = [UIBarButtonItem]()
            items.append(
                UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: Selector(("onClickedToolbeltButton:")))
            )
            self.navigationController?.toolbar.items = items

        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            if collectionView.indexPathsForSelectedItems?.count == 0 {
                navigationController?.setToolbarHidden(true, animated: true)
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        collectionView.allowsMultipleSelection = editing
        let indexpaths = collectionView.indexPathsForVisibleItems as[IndexPath]
        for indexpath in indexpaths {
            collectionView.deselectItem(at: indexpath, animated: false)
            let cell = collectionView.cellForItem(at: indexpath) as? PhotoCollectionViewCell
            cell?.editing = editing
        }
        
        if !editing {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }
    
    
   

    
}



