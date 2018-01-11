//
//  MoviePresenter.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation

protocol MovieViewProtocol: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setMovies(movies: [Movie])
    func setEmptyMovies()
    
    // Load more
    func startLoadingMore()
    func finishLoadingMore()
    func setMoreMovies(movies: [Movie])
}

class MoviePresenter {
    private let movieService: MovieService
    weak private var movieViewProtocol: MovieViewProtocol?
    
    init (movieService: MovieService) {
        self.movieService = movieService
    }
    
    func attachViewProtocol(viewProtocol: MovieViewProtocol) {
        movieViewProtocol = viewProtocol
    }
    
    func detachViewProtocol() {
        movieViewProtocol = nil
    }
    
    func isFetchingFailed() -> Bool {
        return movieService.failed
    }
    
    func fetchMovies() {
        self.movieViewProtocol?.startLoading()
        
        movieService.fetch(done: { (movies) in
            self.movieViewProtocol?.finishLoading()
            if movies.count == 0 {
                self.movieViewProtocol?.setEmptyMovies()
            } else {
                self.movieViewProtocol?.setMovies(movies: movies)
            }
        }) { (error) in
            self.movieViewProtocol?.finishLoading()
            if let err = error {
                print(err)
            }
            self.movieViewProtocol?.setEmptyMovies()
        }
    }
    
    func fetchMoreMovies() {
        if !movieService.done {
            return
        }
        
        movieService.fetchMore(done: { (movies) in
            self.movieViewProtocol?.finishLoading()
            self.movieViewProtocol?.setMoreMovies(movies: movies)
        }) { (error) in
            self.movieViewProtocol?.finishLoading()
            if let err = error {
                print(err)
            }
        }
    }
}
