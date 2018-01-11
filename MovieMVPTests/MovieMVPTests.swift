//
//  MovieMVPTests.swift
//  MovieMVPTests
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import XCTest
@testable import MovieMVP

class MovieServiceMock: MovieService {
    fileprivate let movies: [Movie]
    
    init(movies: [Movie]) {
        self.movies = movies
    }
    
    override func fetch(done: @escaping ([Movie]) -> Void, fail: @escaping (NSError?) -> Void) {
        done(movies)
    }
    
}

class MovieViewProtocolMock : NSObject, MovieViewProtocol {
    var setMoviesCalled = false
    var setEmptyMoviesCalled = false
    
    func setMovies(movies: [Movie]) {
        setMoviesCalled = true
    }
    
    func setEmptyMovies() {
        setEmptyMoviesCalled = true
    }
    
    func startLoading() {
    }
    
    func finishLoading() {
    }
    
    // Load more
    
    func startLoadingMore() {
        
    }
    
    func finishLoadingMore() {
        
    }
    
    func setMoreMovies(movies: [Movie]) {
        
    }
    
}

class MovieMVPTests: XCTestCase {
    
    let emptyMoviesServiceMock = MovieServiceMock(movies: [Movie]())
    let moviesServiceMock = MovieServiceMock(movies: [
        Movie(rawData: [
            "id": 439468,
            "adult": false,
            "backdrop_path": "/eXgfPMRDR53Wuw6MWCL1oVOf38v.jpg",
            "original_language": "en",
            "original_title": "Puccini Gianni Schicchi",
            "overview": "",
            "popularity": 1.012058,
            "poster_path": "/cWWCWbsJa2t0FbQwsdQR27MRP3k.jpg",
            "release_date": "2015-02-04",
            "title": "Puccini Gianni Schicchi",
            "video": false,
            "vote_average": 0,
            "vote_count": 0
        ])
    ])
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldSetEmptyIfNoMovieAvailable() {
        // given
        let movieViewProtocolMock = MovieViewProtocolMock()
        let moviePresenterUnderTest = MoviePresenter(movieService: emptyMoviesServiceMock)
        moviePresenterUnderTest.attachViewProtocol(viewProtocol: movieViewProtocolMock)
        
        // when
        moviePresenterUnderTest.fetchMovies()
        
        // verify
        XCTAssertTrue(movieViewProtocolMock.setEmptyMoviesCalled)
    }
    
    func testShouldSetMovies() {
        // given
        let movieViewProtocolMock = MovieViewProtocolMock()
        let moviePresenterUnderTest = MoviePresenter(movieService: moviesServiceMock)
        moviePresenterUnderTest.attachViewProtocol(viewProtocol: movieViewProtocolMock)
        
        // when
        moviePresenterUnderTest.fetchMovies()
        
        // verify
        XCTAssertTrue(movieViewProtocolMock.setMoviesCalled)
    }
    
}
