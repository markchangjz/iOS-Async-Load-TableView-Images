import UIKit

struct MovieInfo {
    var movieID: Int!
    var title: String!
    var category: String!
    var year: Int!
    var movieURL: String!
    var coverURL: String!
    var watched: Bool!
    var likes: Int!
}

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: IBOutlet Properties
    @IBOutlet weak var tblMovies: UITableView!
    
    
    // MARK: Custom Properties
    
    var movies: [MovieInfo]!
    
    var selectedMovieIndex: Int!
	
	var downloadMovieIcons = [String: UIImage]()
	
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblMovies.delegate = self
        tblMovies.dataSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		movies = DBManager.shared.loadMovies()
		
		tblMovies.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "idSegueMovieDetails" {
                let movieDetailsViewController = segue.destination as! MovieDetailsViewController
				movieDetailsViewController.movieID = movies[selectedMovieIndex].movieID
            }
        }
    }
	
    
	// MARK: - Load Image
	
	func startIconDownload(withMovieInfo movie: MovieInfo, forIndexPath indexPath: IndexPath) {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
		let session = URLSession(configuration: sessionConfiguration)
		let task = session.dataTask(with: URL(string: movie.coverURL)!) { (imageData, response, error) in
			if let data = imageData {
				DispatchQueue.main.async {
					self.downloadMovieIcons[movie.title] = UIImage(data: data)

					let cell = self.tblMovies.cellForRow(at: indexPath)
					cell?.imageView?.image = UIImage(data: data)
					
					let transition = CATransition()
					transition.duration = 0.2
					transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
					transition.type = kCATransitionFade;
					cell?.imageView?.layer.add(transition, forKey: nil)
					
					cell?.layoutSubviews()
				}
			}
		}
		task.resume()
	}

	
    // MARK: UITableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (movies != nil) ? movies.count : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let currentMovie = movies[indexPath.row]
		
		
		cell.textLabel?.text = currentMovie.title
		cell.imageView?.contentMode = .scaleAspectFit
		
		if self.downloadMovieIcons[currentMovie.title] == nil {
			startIconDownload(withMovieInfo: currentMovie, forIndexPath: indexPath)
			cell.imageView?.image = UIImage(named: "movie_default")
		}
		else {
			cell.imageView?.image = self.downloadMovieIcons[currentMovie.title]
		}
		
        return cell
    }
	
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieIndex = indexPath.row
        performSegue(withIdentifier: "idSegueMovieDetails", sender: nil)
    }
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if DBManager.shared.deleteMovie(withID: movies[indexPath.row].movieID) {
				movies.remove(at: indexPath.row)
				tblMovies.reloadData()
			}
		}
	}
}
