//
//  FLKRClient.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class FLKRClient: NSObject {

    let session = URLSession.shared
    
    class func sharedInstance() -> FLKRClient {
        struct Singleton {
            static var sharedInstance = FLKRClient()
        }
        return Singleton.sharedInstance
    }
    
    func getSearchParameters(coordinatesBox: FLKRBoundingBox) -> [String: Any]{
    
        return [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            
            // Your API application key.
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            
            // - A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched.
            // - The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude,
            //   minimum_latitude, maximum_longitude, maximum_latitude.
            // - Longitude has a range of -180 to 180 , latitude of -90 to 90. Defaults to -180, -90, 180, 90
            //   if not specified.
            Constants.FlickrParameterKeys.BoundingBox: coordinatesBox.getString(),
            
            // Safe search setting: 1 for safe.
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            
            // extras: url_m
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            
            // format json
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            
            // ?
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func flickrURLFromParameters(_ parameters: [String: Any]) -> URL {
        
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
    
    func retrievePictureList(coordinatesBox : FLKRBoundingBox){
        
        let parameters = getSearchParameters(coordinatesBox: coordinatesBox)
        let url = flickrURLFromParameters(parameters)
        let request = URLRequest(url: url)
        
        print("Requesting pictures for coordinates (\(coordinatesBox.getString()))")
        print(url.absoluteString)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                print(data)
            }
            
            guard let map = self.dataJsonToMap(data: data) else {
                return
            }
            
            print(map)
            
        }
        task.resume()
    }
    

    func dataJsonToMap(data : Data?) -> [String:Any?]? {
        
        guard let data = data else {
            // Invalid data
            return nil
        }
        
        do {
            let map = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return map as? [String:Any?]
        } catch {
            return nil
        }
    }
    
    //quest = URLRequest(url: flickrURLFromParameters(methodParameters))
//        
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//            
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.photoTitleLabel.text = "No photo returned. Try again."
//                    self.photoImageView.image = nil
//                }
//            }
//            
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(error)")
//                return
//            }
//            
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//            
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//            
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//            
//            /* GUARD: Is "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//            
//            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                return
//            }
//            
//            // pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage)
//        }
//        
//        // start the task!
//        task.resume()
//    }
    
    
    
//    
//    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
//        
//        // add the page to the method's parameters
//        var methodParametersWithPageNumber = methodParameters
//        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
//        
//        // create session and request
//        let session = URLSession.shared
//        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
//        
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//            
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.photoTitleLabel.text = "No photo returned. Try again."
//                    self.photoImageView.image = nil
//                }
//            }
//            
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(error)")
//                return
//            }
//            
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//            
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//            
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//            
//            /* GUARD: Is the "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//            
//            /* GUARD: Is the "photo" key in photosDictionary? */
//            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
//                return
//            }
//            
//            if photosArray.count == 0 {
//                displayError("No Photos Found. Search Again.")
//                return
//            } else {
//                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
//                
//                /* GUARD: Does our photo have a key for 'url_m'? */
//                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
//                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
//                    return
//                }
//                
//                // if an image exists at the url, set the image and title
//                let imageURL = URL(string: imageUrlString)
//                if let imageData = try? Data(contentsOf: imageURL!) {
//                    performUIUpdatesOnMain {
//                        self.setUIEnabled(true)
//                        self.photoImageView.image = UIImage(data: imageData)
//                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                    }
//                } else {
//                    displayError("Image does not exist at \(imageURL)")
//                }
//            }
//        }
//        
//        // start the task!
//        task.resume()
//    }

}
