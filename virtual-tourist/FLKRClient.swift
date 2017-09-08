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

    typealias FLKRCompletionHandler = (_ photos : [FLKRPicture]?, _ error : String?) -> Void
    
    let session = URLSession.shared
    
    class func sharedInstance() -> FLKRClient {
        struct Singleton {
            static var sharedInstance = FLKRClient()
        }
        return Singleton.sharedInstance
    }
    
    func getSearchParameters(coordinates: CLLocationCoordinate2D) -> [String: Any]{
        
        var param = Constants.Flickr.SearchParameters
        param[Constants.Flickr.ParameterKeys.Latitude] = "\(coordinates.latitude)"
        param[Constants.Flickr.ParameterKeys.Longitude] = "\(coordinates.longitude)"
        return param
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
    
    func retrievePictureList(coordinates : CLLocationCoordinate2D,
                             completionHandler: @escaping FLKRCompletionHandler){
        
        let parameters = getSearchParameters(coordinates: coordinates)
        let url = flickrURLFromParameters(parameters)
        let request = URLRequest(url: url)
        
        print("Requesting pictures for coordinate...", url.absoluteString)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.parseResponse(data, response, error, completionHandler)
        }
        task.resume()
    }
    
    func parseResponse(_ data : Data?, _ response : URLResponse?, _ error : Error?,
                       _ completionHandler: @escaping FLKRCompletionHandler) {
        
        func fireResults(_ photos : [FLKRPicture]?, _ error : String?) {
            DispatchQueue.main.async {
                completionHandler(photos, error)
            }
        }
        
        guard error == nil else {
            fireResults(nil, error!.localizedDescription)
            return
        }
        
//        guard let resp = response else {
//            fireResults(nil, "Invalid response type")
//            return
//        }
        
        guard let data = data else {
            fireResults(nil, "Invalid response data")
            return
        }
        
        guard let map = self.dataJsonToMap(data: data) else {
            fireResults(nil, "Invalid response json")
            return
        }
        
        guard let photos = map["photos"] as? [String: Any?] else {
            fireResults(nil, "Invalid response json")
            return
        }
        
        guard let stat = map["stat"] as? String else {
            fireResults(nil, "Stat param not found")
            return
        }
        
        guard "ok" == stat else {
            fireResults(nil, "Server returned error")
            return
        }
        
        guard let photoList = photos["photo"] as? [[String : Any?]] else {
            fireResults(nil, "Invalid response json")
            return
        }
        
        let pictures = photoList.map { (row) -> FLKRPicture in
            var picture = FLKRPicture()
            picture.key = row["id"] as? Int64
            picture.url = row["url_m"] as? String
            return picture
        }
        
        // Success!
        fireResults(pictures, nil)
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
