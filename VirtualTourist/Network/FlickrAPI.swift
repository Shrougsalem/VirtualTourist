//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 23/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MapKit

class FlickrAPI: UIViewController {
    //MARK: Constants
    static let APIKey="0c8556575aa867675cae3e0982d08871"
    static let secret="b4202be5bbd8def6"
    static let baseURL="https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(APIKey)&format=json&nojsoncallback=1&per_page=12"
    
    //MARK: Get Flickr Images URLs
    static func getFlickrPhotosURLs (coordinate: CLLocationCoordinate2D, page: Int, completion: @escaping ([URL]?, String?) -> ()){
        
        guard let url=URL(string: FlickrAPI.baseURL + "&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&page=\(page)&bbox=\(getBBox(lat: coordinate.latitude, long: coordinate.longitude))")
            else {
                return
        }
        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                completion(nil,error.errorDescription)
            case .success(let value):
                let json = JSON(value)
               //debugPrint(String(data: try! json.rawData(),encoding: .utf8)!)
                var photosURLs = [URL]()
                for photo in json["photos"]["photo"] {
                    let urlString = self.getPhotoURL(farmID: photo.1["farm"].stringValue, serverID: photo.1["server"].stringValue, photoID: photo.1["id"].stringValue, secret: photo.1["secret"].stringValue)
                    let url = URL(string: urlString)
                    photosURLs.append(url!)
                }
                completion(photosURLs,nil)

            }
        }
    }
    //MARK: Get Image's URL
    static func getPhotoURL(farmID:String, serverID:String, photoID:String, secret:String) -> String{
        return "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secret).jpg"
    }
    
    static func getBBox(lat:Double, long:Double)->String{
            let value = 0.5
            let minLongitude = max(long - value, -180)
            let minLatitude = max(lat - value, -90)
            let maxLongitude = min(long + value, 180)
            let maxLatitude = min(lat + value, 90)
            return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
}

