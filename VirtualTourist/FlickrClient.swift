//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 2/25/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrClient: NSObject {
    
    let session = URLSession.shared
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override init() {
        super.init()
    }
    
    
    func fetchImages(_ page:Int,_ lat:Double,_ long:Double,  pin:Pin, completionHandler:@escaping (_ success: Bool, _ error: String?)->Void){
        
        let methodParameters = [
        "method": "flickr.photos.getRecent",
        "api_key": Constants.FlickrParameterValues.APIKey,
        "safe_search": "1",
        "format": "json",
        "nojsoncallback": "1",
        "per_page": "30",
        "page": String(page),
        "lat": String(lat),
        "long":String(long)
        ]
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        print("Requesr \(request.url)")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandler(false, "Error getting data")
            } else {
                if let results = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject] {
                    
                    if let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] {
                        if let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                            
                            for photoObject in photosArray {
                                let farm = photoObject["farm"] as AnyObject
                                let server = photoObject["server"] as AnyObject
                                let photo = photoObject["id"] as AnyObject
                                let secret = photoObject["secret"] as AnyObject
                                let title = photoObject["title"] as? String
                                
                                let imageString = "https://farm\(farm).staticflickr.com/\(server)/\(photo)_\(secret)_m.jpg"
                                
                                let managedContext = self.appDelegate?.persistentContainer.viewContext
                                
                                let photos = Photo(entity: Photo.entity(), insertInto: managedContext)
                                photos.url = imageString
                                photos.title = title
                                photos.pin = pin
                                
                                completionHandler(true, nil)
                                
                                do {
                                    try managedContext?.save()
                                } catch let error as NSError {
                                    print("Could not save \(error.userInfo)")
                                }

                            }
                            
                        }
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func getImages(_ url:String, _ pin:Pin) {
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error with request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            let results = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            
            guard let photosDictionary = results??[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                return
            }
            
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                return
            }
            
            
            for photoObject in photosArray {
                //title, imageURL, image, Pin
                let farm = photoObject["farm"] as AnyObject
                let server = photoObject["server"] as AnyObject
                let photo = photoObject["id"] as AnyObject
                let secret = photoObject["secret"] as AnyObject
                let title = photoObject["title"] as? String
                
                let imageString = "https://farm\(farm).staticflickr.com/\(server)/\(photo)_\(secret)_m.jpg"
                
                let managedContext = self.appDelegate?.persistentContainer.viewContext
                
                let photos = Photo(entity: Photo.entity(), insertInto: managedContext)
                photos.url = imageString
                photos.title = title
                photos.pin = pin
                
                do {
                    try managedContext?.save()
                } catch let error as NSError {
                    print("Could not save \(error.localizedFailureReason)")
                }
            }
            
        }
        
        task.resume()
    }
    
    
    
    func convertStringToImage(_ photo: Photo, completionHandler: @escaping(_ image: UIImage?, _ error: NSError?)-> Void)  {
        
        print("ULR \(photo.url)")
        let request = URLRequest(url: URL(string: photo.url!)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completionHandler(nil, error as NSError?)

            } else {
           
                performUIUpdatesOnMain {
                let imageData = UIImage(data: data!)
                    photo.image = data as NSData?
                    
                    do {
                        
                        try photo.managedObjectContext?.save()
                        
                    } catch let error as NSError {
                        print("Error saving image data: \(error.localizedFailureReason)")
                        completionHandler(nil, error)
                    }
                    
                    completionHandler(imageData, nil)
                
                }
        
            }
        }
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}




