//
//  HomeViewController.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import AlamofireImage

struct Constants {
    static let posterBaseURL: String = "https://image.tmdb.org/t/p"
    
    struct Colors {
        static let navTopColor = UIColor(red: 45/255, green: 52/255, blue: 198/255, alpha: 1.0)
        static let navBottomColor = UIColor(red: 248/255, green: 68/255, blue: 81/255, alpha: 1.0)
        static let cellTextColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
    }
    
}

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var pullToRefresh: UIRefreshControl!
    
    fileprivate let moviePresenter = MoviePresenter(movieService: MovieService())
    fileprivate var moviesToDisplay = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        
        moviePresenter.attachViewProtocol(viewProtocol: self)
        refreshData()
    }
    
    fileprivate func setupContentView() {
        title = "Movies"
        
        navigationController?.navigationBar.setGradientBackground(colors: [Constants.Colors.navTopColor, Constants.Colors.navBottomColor])
        
        pullToRefresh = UIRefreshControl()
        //tableView.addSubview(pullToRefresh)
        tableView.refreshControl = pullToRefresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSForegroundColorAttributeName: Constants.Colors.cellTextColor])
        pullToRefresh.tintColor = Constants.Colors.navBottomColor
        pullToRefresh.addTarget(self, action: #selector(HomeViewController.refreshData), for: .valueChanged)
    }
    
    func refreshData() {
        moviePresenter.fetchMovies()
    }
    
    func fetchMoreMovies() {
        moviePresenter.fetchMoreMovies()
    }
    
    func fetchMoreMoviesIfNeeded() {
        let currentOffset = tableView.contentOffset.y;
        let maximumOffset = tableView.contentSize.height - tableView.frame.size.height;
        
        if (maximumOffset - currentOffset <= 110) { // double check if it is last row cell
            fetchMoreMovies()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIScrollViewDelegate
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !moviePresenter.isFetchingFailed() {
            fetchMoreMoviesIfNeeded()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        fetchMoreMoviesIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fetchMoreMoviesIfNeeded()
    }*/

}

extension HomeViewController: MovieViewProtocol {
    
    func startLoading() {
        pullToRefresh.beginRefreshing()
    }
    
    func finishLoading() {
        pullToRefresh.endRefreshing()
    }
    
    func setMovies(movies: [Movie]) {
        moviesToDisplay = movies
        tableView?.reloadData()
    }
    
    func setEmptyMovies() {
        
    }
    
    // MARK: Load More
    
    func startLoadingMore() {
        
    }
    
    func finishLoadingMore() {
        
    }
    
    func setMoreMovies(movies: [Movie]) {
        moviesToDisplay += movies
        tableView?.reloadData()
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = moviesToDisplay[indexPath.row]
        
        cell.movieTitleLabel?.text = movie.title
        cell.voteLavel?.text = "⭐️\(movie.voteAverage != nil ? String(movie.voteAverage!) : "0.0")"
        cell.popularityLabel?.text = " \(String(format: "%.1f", movie.popularity != nil ? movie.popularity! : "0.0")) "
        if movie.video {
            cell.playIconImageView.isHidden = false
        } else {
            cell.playIconImageView.isHidden = true
        }
        
        let defaultPosterPath = movie.defaultPosterPath()
        if defaultPosterPath == "" {
            cell.movieImageView.image = UIImage(named: "poster_placeholder")
        } else {
            cell.movieImageView.af_setImage(withURL: URL(string: defaultPosterPath)!, placeholderImage: UIImage(named: "poster_placeholder"))
        }
        
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == moviesToDisplay.count - 1 {
            fetchMoreMoviesIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row > moviesToDisplay.count - 1 {
            return
        }
        
        let movie = moviesToDisplay[indexPath.row]
        
        let movieDetailsViewController = storyboard!.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        navigationController?.pushViewController(movieDetailsViewController, animated: true)
    }
    
}

