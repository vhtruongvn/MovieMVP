//
//  Movie.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import Alamofire

let imageBaseURL = "https://image.tmdb.org/t/p"

class Movie {
    let id: Int
    var adult: Bool
    var backdropPath: String?
    var originalLang: String
    var originalTitle: String
    var overview: String?
    var popularity: Float?
    var posterPath: String?
    var releaseDate: Date?
    var title: String
    var video: Bool
    var voteAverage: Float?
    var voteCount: Int?
    var genres: [String]? // details
    var duration: Int? // details
    var spokenLang: [String]? // details
    
    init(rawData: NSDictionary) {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        
        self.id = rawData["id"] as! Int
        self.adult = rawData["adult"] as! Bool
        self.backdropPath = rawData["backdrop_path"] as? String
        self.originalLang = rawData["original_language"] as! String
        self.originalTitle = rawData["original_title"] as! String
        self.overview = rawData["overview"] as? String
        self.popularity = rawData["popularity"] as? Float
        self.posterPath = rawData["poster_path"] as? String
        self.releaseDate = dateFormater.date(from: rawData["release_date"] as! String)
        self.title = rawData["title"] as! String
        self.video = rawData["video"] as! Bool
        self.voteAverage = rawData["vote_average"] as? Float
        self.voteCount = rawData["vote_count"] as? Int
    }
    
    func defaultPosterPath() -> String {
        if let deafaultPosterPath = posterPath {
            return "\(imageBaseURL)/w150\(deafaultPosterPath)"
        } else {
            return ""
        }
    }
    
    func formatedDuration() -> String {
        if self.duration == nil {
            return ""
        }
        
        let minute = self.duration! % 60
        let hour = (self.duration! - minute) / 60
        
        return "\(hour)h" + (minute > 0 ? " \(minute)min" : "")
    }
    
    func fetchMovieDetails(done: @escaping (Movie) -> Void, fail: @escaping (NSError?) -> Void) {
        Alamofire.request("\(apiBaseURL)/movie/\(id)", parameters: ["api_key": apiKey]).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary {
                if JSON["status_code"] != nil && JSON["status_message"] != nil {
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: JSON["status_message"] as! String,
                        NSLocalizedFailureReasonErrorKey: JSON["status_message"] as! String
                    ]
                    let errorTemp = NSError(domain: "DataError", code: JSON["status_code"] as! Int, userInfo: userInfo)
                    
                    fail(errorTemp)
                    
                    return
                }
                
                self.duration = JSON["runtime"] as? Int
                self.genres = (JSON["genres"] as? [NSDictionary])?.map { genreRawData in
                    return genreRawData["name"] as! String
                }
                self.spokenLang = (JSON["spoken_languages"] as? [NSDictionary])?.map { spokeLanguageRawData in
                    return spokeLanguageRawData["name"] as! String
                }
                
                done(self)
            }
            
            if let error = response.result.error {
                fail(error as NSError)
            }
        }
    }
    
}
