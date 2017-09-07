//
//  FLKRClient.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class FLKRClient: NSObject {

    
    
    
//    private func bboxString() -> String {
//        // ensure bbox is bounded by minimum and maximums
//        if let latitude = Double(latitudeTextField.text!), let longitude = Double(longitudeTextField.text!) {
//            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
//            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
//            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
//            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
//            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
//        } else {
//            return "0,0,0,0"
//        }
//    }
    
    
//    let methodParameters = [
//        Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
//        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
//        Constants.FlickrParameterKeys.Text: phraseTextField.text!,
//        Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
//        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
//        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
//        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
//    ]
    
    
//    // MARK: Flickr API
//
//    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
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
//    // FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.
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
//    
//    // MARK: Helper for Creating a URL from Parameters
//    
//    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
//        
//        var components = URLComponents()
//        components.scheme = Constants.Flickr.APIScheme
//        components.host = Constants.Flickr.APIHost
//        components.path = Constants.Flickr.APIPath
//        components.queryItems = [URLQueryItem]()
//        
//        for (key, value) in parameters {
//            let queryItem = URLQueryItem(name: key, value: "\(value)")
//            components.queryItems!.append(queryItem)
//        }
//        
//        return components.url!
//    }
}
