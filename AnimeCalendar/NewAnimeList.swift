//
//  NewAnimeList.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/17/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class NewAnimeList: NSObject {
    
    let baseURL = "https://anilist.co/api/"
    let authEndpoint = "auth/access_token"
    let genreList = "genre_list"
    var clientID:String!
    var clientSecret:String!
    var accessToken:String!
    
    init(clientID:String, clientSecret:String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion:@escaping (_ accessToken:String) -> Void){
        let auth = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        makeGeneralRequest(url: baseURL + authEndpoint, parameters: auth.data(using: .utf8), type: "POST") { (response) in
            if let data = response as? [String:Any]{
                self.accessToken = data["access_token"] as! String
                print(self.accessToken)
                completion(self.accessToken)
                //self.genres()
               
            }
        }
    }
    
    func genres(){
        let auth = "?access_token=" + self.accessToken
        makeGeneralRequest(url: baseURL + genreList + auth, parameters: nil, type: "GET") { (genres) in
            //print(genres)
        }
    }
    
    func generateThisMonthAnime(){
        self.animeToDate { (animez) in
            for anime:[String:Any] in animez{
                if let id = anime["id"] as? NSNumber{
                    self.makeGeneralRequest(url: self.baseURL + "anime/" + String(describing:id) + "?access_token=" + self.accessToken, parameters: nil, type: "GET") { (data) in
                        if let animeData = data as? [String:Any]{
                            print(animeData)
                        }
                    }
                }
            }
        }
    }
    
    func animeToDate(completion:@escaping (_ data:[[String:Any]]) -> Void){
        let endPoint =  "browse/anime?access_token=" + self.accessToken + "&year=2017&season=summer&full_page=true"
        makeGeneralRequest(url: baseURL + endPoint, parameters: nil, type: "GET") { (data) in
            if let animez = data as? [[String:Any]]{
                completion(animez)
                //for anime:[String:Any] in animez{
                    //var time:NSDate!
                    //var name:String!
                    //completion(anime)
//                    if let date = anime["updated_at"] as? NSNumber{
//                        time = NSDate(timeIntervalSince1970: TimeInterval(date))
//                    }
//                    if let title = anime["title_english"] as? String{
//                        name = title
//                    }
//                    if (time != nil && name != nil)
//                    {
//                        completion([name:time])
//                    }
               // }
            }
        }
    }
    
    private func makeGeneralRequest(url:String, parameters:Data?, type:String, completion:@escaping ((_ data:/*[String:Any]*/Any)->Void)){
        print(url)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = type
        request.httpBody = parameters
        let session = URLSession.shared
        
        
        session.dataTask(with: request) {data, response, err in
            if (err != nil){
                print("Error with request :(")
                completion(["title":err!.localizedDescription])
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    //print(json)
                    print(type(of:json))
                    completion(json)
                    
                    
                }catch let error as NSError{
                    print(error)
                }
            }
            }.resume()
    }
    
}
