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
                    print("Could not save \(error.userInfo)")
                }
            }
            
        }
        
        task.resume()
    }
    
    
    
    func convertStringToImage(_ photo: Photo, completionHandler: @escaping(_ image: UIImage?, _ error: NSError?)-> Void)  {
        
        let request = URLRequest(url: URL(string: photo.url!)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
           
            if let imageData = UIImage(data: data!) {
                performUIUpdatesOnMain {
                photo.image = data as NSData?
                }
                
                do {
                    try photo.managedObjectContext?.save()
                    
                } catch let error as NSError {
                    print("Error saving image data: \(error.localizedFailureReason)")
                    print("Response \(response)")
                }
                completionHandler(imageData, nil)
            }
            
            if error != nil {
                completionHandler(nil, error as NSError?)
            }
        }
        // data task  -> request -> image url as url
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




