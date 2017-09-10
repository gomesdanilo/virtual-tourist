//
//  FLKRClient.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit


class FLKRClient: NSObject {

    typealias FLKRListPicturesCompletionHandler = (_ response : FLKRResponse) -> Void
    typealias FLKRDownloadPictureCompletionHandler = (_ data : Data?, _ error : String?) -> Void
    
    let session = URLSession.shared
    
    class func sharedInstance() -> FLKRClient {
        struct Singleton {
            static var sharedInstance = FLKRClient()
        }
        return Singleton.sharedInstance
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
    
    
    private func parseResponseDownloadPicture(_ data : Data?, _ response : URLResponse?, _ error : Error?,
                                              _ completionHandler : @escaping FLKRDownloadPictureCompletionHandler) {
        func fireResults(_ data : Data?, _ error : String?) {
            DispatchQueue.main.async {
                completionHandler(data, error)
            }
        }
        
        guard let data = data else {
            fireResults(nil, "Failed to download picture")
            return
        }
        
        fireResults(data, nil)
    }
    
    func downloadPicture(url : String, completionHandler : @escaping FLKRDownloadPictureCompletionHandler){
        let request = URLRequest(url: URL(string: url)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.parseResponseDownloadPicture(data, response, error, completionHandler)
        }
        task.resume()
    }
    
    func retrievePictureList(pin : Pin,
                             completionHandler: @escaping FLKRListPicturesCompletionHandler){
        
        // Search parameters
        let coordinates = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        
        var parameters = Constants.Flickr.SearchParameters
        parameters[Constants.Flickr.ParameterKeys.Latitude] = "\(coordinates.latitude)"
        parameters[Constants.Flickr.ParameterKeys.Longitude] = "\(coordinates.longitude)"
        parameters[Constants.Flickr.ParameterKeys.Page] = "\(pin.page)"
        
        
        print("Retrieving pictures from flickr with page \(pin.page) for coordinates \(coordinates.longitude),\(coordinates.latitude)")
        
        
        let url = flickrURLFromParameters(parameters)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.parseResponsePictureList(data, response, error, completionHandler)
        }
        task.resume()
    }
    
    private func parseResponsePictureList(_ data : Data?, _ response : URLResponse?, _ error : Error?,
                                  _ completionHandler: @escaping FLKRListPicturesCompletionHandler) {
        
        func fireResults(_ photos : [FLKRPicture]?, _ page: Int32?, _ numberOfPages : Int32?, _ error : String?) {
            DispatchQueue.main.async {
                
                if let photos = photos, let page = page, let numberOfPages = numberOfPages {
                    completionHandler(FLKRResponse(pictures: photos, page: page, numberOfPages: numberOfPages))
                } else if let error = error {
                    completionHandler(FLKRResponse(errorMessage: error))
                } else {
                    completionHandler(FLKRResponse(errorMessage: "Failed to retrieve pictures from flickr"))
                }
            }
        }
        
        guard error == nil else {
            fireResults(nil, nil, nil, error!.localizedDescription)
            return
        }
        
        guard let data = data else {
            fireResults(nil, nil, nil, "Invalid response data")
            return
        }
        
        guard let map = self.dataJsonToMap(data: data) else {
            fireResults(nil, nil, nil, "Invalid response json")
            return
        }
        
        guard let photos = map["photos"] as? [String: Any?] else {
            fireResults(nil, nil, nil, "Invalid response json")
            return
        }
        
        guard let stat = map["stat"] as? String else {
            fireResults(nil, nil, nil, "Stat param not found")
            return
        }
        
        guard "ok" == stat else {
            fireResults(nil, nil, nil, "Server returned error")
            return
        }
        
        guard let photoList = photos["photo"] as? [[String : Any?]] else {
            fireResults(nil, nil, nil, "Invalid response json")
            return
        }
        
        let pictures = photoList.map { (row) -> FLKRPicture in
            var picture = FLKRPicture()
            picture.key = row["id"] as? Int64
            picture.url = row["url_m"] as? String
            return picture
        }
        
        let page = photos["page"] as! Int32
        let numberOfPages = photos["pages"] as! Int32
        
        // Success!
        fireResults(pictures, page, numberOfPages, nil)
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
}
