//
//  NewAnimeList.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/17/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import os.log

class NewAnimeList: NSObject {
    
    let baseURL = "https://anilist.co/api/"
    let authEndpoint = "auth/access_token"
    let genreList = "genre_list"
    var clientID:String!
    var clientSecret:String!
    var accessToken:String!
    var calendarDict = [Int:[[String:Any]]]()
    
    var numAnimeToIterateThrough:Int = 0
    
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

        }
    }
    
    func monthAnimeList(completion:@escaping (_ calendarDict:[Int:[[String:Any]]]) -> Void, fullyDoneCompletion:@escaping () -> Void){
        self.authenticate { (accessToken) in
            self.generateThisMonthAnime(month: Calendar.current.component(.month, from: Date()), completion: { () in
                //print("Not done yet")
                completion(self.calendarDict)
            }, allAnimeDoneCompletion: {() in
                //print("!----Fully done----!")
                print(self.calendarDict)
                fullyDoneCompletion()
            })
        }
    }
    
    func addAnimeDictToCalendar(date:Date, shouldAdd:Bool, animeData:[String:Any]){
        let dateMonth = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        if (shouldAdd/*month == dateMonth*/){
            //self.addAnimeDictToCalendar(day: day, animeData: animeData)
            if (self.calendarDict[day] != nil)
            {
                self.calendarDict[day]?.append(animeData)
            }
            else
            {
                self.calendarDict[day] = [animeData]
            }
            //completion()
        }
//        if (self.calendarDict[day] != nil)
//        {
//            self.calendarDict[day]?.append(animeData)
//        }
//        else
//        {
//            self.calendarDict[day] = [animeData]
//        }
    }
    
    func generateThisMonthAnime(month:Int,completion:@escaping () -> Void, allAnimeDoneCompletion:@escaping ()->Void){
        var i = 0
        self.calendarDict = [Int:[[String:Any]]]()
        self.animeToDate { (animez) in
            for anime:[String:Any] in animez{
                if let id = anime["id"] as? NSNumber{
                    self.makeGeneralRequest(url: self.baseURL + "anime/" + String(describing:id) + "?access_token=" + self.accessToken, parameters: nil, type: "GET") { (data) in
                        i+=1
                        //os_log("%@: i: %@, animez.count: %@", self.className, i.description, animez.count.description)
                        if (i >= animez.count)
                        {
                            allAnimeDoneCompletion()
                        }
                        if let animeData = data as? [String:Any]{
                            if let startDate = animeData["start_date_fuzzy"] as? Int{
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyyMMdd"
                                let startdate = dateFormatter.date(from: String(describing:startDate))!
                                let dateMonth = Calendar.current.component(.month, from: startdate)
                                self.addAnimeDictToCalendar(date: startdate, shouldAdd: month == dateMonth, animeData: animeData)
                                
                                if let airingInfo = animeData["airing"] as? [String:Any]{
                                    
                                    if let time = airingInfo["time"] as? String{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                        let date = dateFormatter.date(from: time)!
                                        
                                        // Don't add the same anime twice (from both the airing date and starting date)
                                        if (startdate != date)
                                        {
                                            let dateMonth = Calendar.current.component(.month, from: date)
                                            self.addAnimeDictToCalendar(date: date, shouldAdd: month == dateMonth, animeData: animeData)
                                            completion()

                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
                else
                {
                    //os_log("%@: No id i: %@, animez.count: %@", self.className, i.description, animez.count.description)
                    i += 1
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
    
    private func makeGeneralRequest(url:String, parameters:Data?, type:String, completion:@escaping ((_ data:Any)->Void)){
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
                    completion(["title":err!.localizedDescription])
                }
            }
            }.resume()
    }
    
}
