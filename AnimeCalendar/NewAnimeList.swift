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
    var calendarDict = [Int:[[String:Any]]]()
    
    static let sharedInstance = NewAnimeList(clientID: "kowaretasekai-xquxb", clientSecret: "T5yjmG9hn3x5LvLK7lKTP")
    
 
    
    lazy var currentYear:String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: Date())
    }()
    
    lazy var currentSeason:String = {
        var season:String!
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        if (month >= 10 && month <= 12)
        {
            season = "fall"
        }
        else if (month >= 1 && month <= 3)
        {
            season = "winter"
        }
        else if (month >= 4 && month <= 6)
        {
            season = "spring"
        }
        else
        {
            season = "summer"
        }
        return season
    }()
    
    init(clientID:String, clientSecret:String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion:@escaping (_ accessToken:String) -> Void){
        let auth = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        makeGeneralRequest(url: baseURL + authEndpoint, parameters: auth.data(using: .utf8), type: "POST") { (response) in
            if let data = response as? [String:Any]{
                self.accessToken = data["access_token"] as! String
                //print(self.accessToken)
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
    
    func monthAnimeList(completion:@escaping (_ calendarDict:[Int:[[String:Any]]]) -> Void){
        self.authenticate { (accessToken) in
            self.generateThisMonthAnime(month: Calendar.current.component(.month, from: Date()), completion: { (calendarDict) in
                self.calendarDict = calendarDict
                completion(calendarDict)
            })
        }
    }
    
    func generateThisMonthAnime(month:Int,completion:@escaping (_ calendarDict:[Int:[[String:Any]]]) -> Void){
        //var calendarDict = [Int:Any]()
        self.animeToDate { (animez) in
            for anime:[String:Any] in animez{
                if let id = anime["id"] as? NSNumber{
                    self.makeGeneralRequest(url: self.baseURL + "anime/" + String(describing:id) + "?access_token=" + self.accessToken, parameters: nil, type: "GET") { (data) in
                        if let animeData = data as? [String:Any]{
                            //print(animeData)
                            if let airingInfo = animeData["airing"] as? [String:Any]{
                                if let time = airingInfo["time"] as? String{
                        
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                    let date = dateFormatter.date(from: time)!
                                    print(date)
                                    let dateMonth = Calendar.current.component(.month, from: date)
                                    let day = Calendar.current.component(.day, from: date)
                                    if (month == dateMonth){
                                        print(month)
                                        print(dateMonth)
                                        print(time)
                                        print(animeData["title_english"])
                                        print(day)
                                        print("-------------------")
                                        if (self.calendarDict[day] != nil)
                                        {
                                            self.calendarDict[day]?.append(animeData)
                                        }
                                        else
                                        {
                                            self.calendarDict[day] = [animeData]
                                        }
                                        completion(self.calendarDict)
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            //return calendarDict
        }
        //return nil
    }
    
    func animeToDate(completion:@escaping (_ data:[[String:Any]]) -> Void){
        let endPoint =  "browse/anime?access_token=" + self.accessToken + "&year=" + self.currentYear + "&season=" + self.currentSeason
        makeGeneralRequest(url: baseURL + endPoint, parameters: nil, type: "GET") { (data) in
            if let animez = data as? [[String:Any]]{
                completion(animez)
            }
        }
    }
    
    private func makeGeneralRequest(url:String, parameters:Data?, type:String, completion:@escaping ((_ data:/*[String:Any]*/Any)->Void)){
        //print(url)
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
                    //print(type(of:json))
                    completion(json)
                    
                    
                }catch let error as NSError{
                    print(error)
                }
            }
            }.resume()
    }
    
}
