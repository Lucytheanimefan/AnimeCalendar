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
    var clientID:String!
    var clientSecret:String!
    var accessToken:String!
    
    init(clientID:String, clientSecret:String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func authenticate(){
        let auth = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        makeGeneralRequest(url: baseURL + authEndpoint, parameters: auth.data(using: .utf8), type: "POST") { (response) in
            if let data = response as? [String:Any]{
                self.accessToken = data["access_token"] as! String
                print(self.accessToken)
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
