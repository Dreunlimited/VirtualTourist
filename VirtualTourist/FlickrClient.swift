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
    var currentImage:Photo!
   
    
    
    override init() {
        super.init()
    }
    
    func getImages(_ url:String) {
        let request = URLRequest(url: URL(string: url)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
               print("Error \(error)")
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
                let farm = photoObject["farm"] as AnyObject
                let server = photoObject["server"] as AnyObject
                let photo = photoObject["id"] as AnyObject
                let secret = photoObject["secret"] as AnyObject
                
                
                let imageStrings = "https://farm\(farm).staticflickr.com/\(server)/\(photo)_\(secret)_m.jpg"
                let data = self.convertStringToImage(imageStrings)
                
                
                let managedContext = self.appDelegate?.persistentContainer.viewContext
                
                 let photos = Photo(entity: Photo.entity(), insertInto: managedContext)
                 photos.image = data as NSData?
                 photos.pin = self.appDelegate?.currentPin
                
                print(photos.pin?.longitude)
                print(photos.pin?.latitude)
                
                
                
                do {
                  try managedContext?.save()
                } catch let error as NSError {
                    print("Could not save \(error.userInfo)")
                }

                
            }
           
        }
        
        task.resume()
    }
    
    
    func convertStringToImage(_ imageString:String) -> Data {
        let image = URL(string: imageString)
        let imageData = try? Data(contentsOf: image!)
        
        return imageData!
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

    


