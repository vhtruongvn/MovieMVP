//
//  MovieService.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import Alamofire

let apiKey = "7527d0b5f5482e11b0140ba3947c3ade"
let apiBaseURL = "https://api.themoviedb.org/3"

class MovieService {
    
    var fetching: Bool = false
    var failed: Bool = false
    var done: Bool = false
    
    private var requestURLString = "\(apiBaseURL)/discover/movie"
    private var parameters: Dictionary<String, Any> = [
        "api_key": apiKey,
        "sort_by": "release_ date.desc"
    ]
    private var currentPage: Int = -1
    
    init() {}
    
    func fetch(done: @escaping ([Movie]) -> Void, fail: @escaping (NSError?) -> Void) {
        if fetching {
            // TODO: Handle noop
            return
        }
        
        fetching = true
        
        // reset pagination
        parameters["page"] = nil
        currentPage = -1
        
        print("Fetch movies \(parameters)")
        
        Alamofire.request(self.requestURLString, parameters: self.parameters).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary {
                self.fetching = false
                self.failed = false
                self.done = true
                
                self.currentPage = JSON["page"] as! Int
                let movies = (JSON["results"] as! [NSDictionary]).map { rawData in
                    return Movie(rawData: rawData)
                }
                
                done(movies)
            }
            
            if let error = response.result.error {
                self.fetching = false
                self.failed = true
                
                fail(error as NSError)
            }
        }
    }
    
    func fetchMore(done: @escaping ([Movie]) -> Void, fail: @escaping (NSError?) -> Void) {
        if fetching {
            // TODO: Handle noop
            return
        }
        
        fetching = true
        
        parameters["page"] = currentPage + 1
        
        print("Fetch more movies \(parameters)")
        
        Alamofire.request(self.requestURLString, parameters: self.parameters).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary {
                self.fetching = false
                self.failed = false
                
                self.currentPage = JSON["page"] as! Int
                let movies = (JSON["results"] as! [NSDictionary]).map { movieRawData in
                    return Movie(rawData: movieRawData)
                }
                
                done(movies)
            }
            
            if let error = response.result.error {
                self.fetching = false
                self.failed = true
                
                fail(error as NSError)
            }
        }
    }
    
    // the service delivers mocked data with a delay
    /*func getMovies(callBack:@escaping ([Movie]) -> Void) {
        let movies = [
            Movie(id: 439468, adult: false, backdropPath: nil, genreIds: [], originalLang: "en", originalTitle: "Puccini Gianni Schicchi", overview: "", popularity: 1.012058, posterPath: "/cWWCWbsJa2t0FbQwsdQR27MRP3k.jpg", releaseDate: "2015-02-04", title: "Puccini Gianni Schicchi", video: false, voteAverage: 0, voteCount: 0),
            Movie(id: 328749, adult: false, backdropPath: nil, genreIds: [], originalLang: "en", originalTitle: "Boys in the Sand", overview: "", popularity: 1, posterPath: "/byIYYC1actrUIEl2opmOTgTrRIv.jpg", releaseDate: "1971-01-04", title: "Boys in the Sand", video: false, voteAverage: 0, voteCount: 0),
            Movie(id: 3475, adult: false, backdropPath: "/eXgfPMRDR53Wuw6MWCL1oVOf38v.jpg", genreIds: [], originalLang: "fr", originalTitle: "The Last Train", overview: "Two people, a Frenchman Julien Maroyeur and a Jewish German woman (Anna Kupfer) met on a train while escaping the German army entering France.", popularity: 1.154132, posterPath: "/ac0nFv6O22Zy7HJgd8JtLmg8pWr.jpg", releaseDate: "1973-10-31", title: "The Last Train", video: false, voteAverage: 8.3, voteCount: 4)
        ]
        
        // delay 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            callBack(movies)
        }
    }*/
    
}
