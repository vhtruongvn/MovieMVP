//
//  MovieDetailsViewController.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftWebVC

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var voteLavel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var playIconImageView: UIImageView!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentView()
        
        // custom loading popup
        let alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertController.view.addSubview(spinnerIndicator)
        present(alertController, animated: false, completion: nil)
        
        // load movie details data
        movie.fetchMovieDetails(done: { (movie) in
            DispatchQueue.main.async {
                alertController.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        }) { (error) in
            if let err = error {
                DispatchQueue.main.async {
                    alertController.dismiss(animated: false, completion: {
                        self.showAlert("Oops", message: err.localizedDescription)
                    })
                }
            }
        }
    }
    
    fileprivate func setupContentView() {
        title = "Details"
        
        movieTitleLabel.text = movie.title
        voteLavel.text = "⭐️\(movie.voteAverage != nil ? String(movie.voteAverage!) : "0.0")"
        popularityLabel.text = " \(String(format: "%.1f", movie.popularity != nil ? movie.popularity! : "0.0")) "
        if movie.video {
            playIconImageView.isHidden = false
        } else {
            playIconImageView.isHidden = true
        }
        
        let defaultPosterPath = movie.defaultPosterPath()
        if defaultPosterPath == "" {
            movieImageView.image = UIImage(named: "poster_placeholder")
        } else {
            movieImageView.af_setImage(withURL: URL(string: defaultPosterPath)!, placeholderImage: UIImage(named: "poster_placeholder"))
        }
    }
    
    fileprivate func showAlert(_ title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    
    @IBAction func bookButtonTapped(_ sender: AnyObject) {
        let webVC = SwiftWebVC(urlString: "http://www.cathaycineplexes.com.sg/")
        webVC.delegate = self
        navigationController?.pushViewController(webVC, animated: true)
    }

}

extension MovieDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieInfoCell", for: indexPath) as! MovieInfoCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel?.text = "Synopsis"
            cell.contentLabel.text = movie.overview
            break
        case 1:
            cell.titleLabel?.text = "Genres"
            cell.contentLabel.text = movie.genres?.joined(separator: ", ")
            break
        case 2:
            cell.titleLabel?.text = "Language"
            cell.contentLabel.text = movie.spokenLang?.joined(separator: ", ")
            break
        case 3:
            cell.titleLabel?.text = "Duration"
            cell.contentLabel.text = movie.formatedDuration()
            break
        default:
            break
        }
        
        return cell
    }
    
}

extension MovieDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension MovieDetailsViewController: SwiftWebVCDelegate {
    
    func didStartLoading() {
        print("Started loading.")
    }
    
    func didFinishLoading(success: Bool) {
        print("Finished loading. Success: \(success).")
    }
    
}
