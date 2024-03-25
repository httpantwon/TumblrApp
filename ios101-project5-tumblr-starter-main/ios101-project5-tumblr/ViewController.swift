//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    

/* This method creates a table view, and tells the table view how many rows we want and now that we have Tumblr blog posts to show, we want as many rows as we have blogs. To get that number, we can access the 'count' property on the blogs array */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Returns the number of rows for the table
        return posts.count
    }
    
    // Method where we create, configure, and return a table view cell for use in the given row of the table view. Now that we have posts to display, we can use the row (indexPath.row) to index into our posts array to fetch the movie associated with the current row. Then we can access the properties of the post to configure the cell. In this case, we'll set the text for the tableView cell's built in text label with the post's title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a reusable cell
        // Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table. This helps optimize table view performance as the app only needs to create enough cells to fill the screen and reuse cells that scroll off the screen instead of creating new ones.
        // The identifier references the identifier you set for the cell previously in the storyboard.
        // The `dequeueReusableCell` method returns a regular `UITableViewCell`, so we must cast it as our custom cell (i.e., `as! BlogCell`) to access the custom properties you added to the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! BlogCell
        
        // Get the post associated table view row
        let post = posts[indexPath.row]
        
        // Configure the cell (i.e., update UI elements like labels, image views, etc.)
    
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            
            // Load the photo in the image view via Nuke library...
            Nuke.loadImage(with: url, into: cell.posterImageView)
        }
        
        // Set the post's summary for the title
        cell.titleLabel.text = post.summary
        
        return cell
    }
    
    // TODO: Add table view outlet
    @IBOutlet weak var tableView: UITableView!
    
    // TODO: Add property to store fetched posts array
    // A property to store the posts we fetch
    private var posts: [Post] = []
    
    @objc func refreshData(_ sender: Any) {
        // 4. Implement refresh action
        fetchPosts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Extra functions
        tableView.dataSource = self
        
        // 1. Create refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // 2. Configure Refresh Control
        refreshControl.tintColor = UIColor.gray
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
                
        // 3. Attach Refresh Control to Table View
        tableView.refreshControl = refreshControl

        fetchPosts()
    }

    // Fetches a list of blog posts from the Tumblr API
    func fetchPosts() {
        // URL for the Retrieve Published Posts
        let url = URL(string: "https://api.tumblr.com/v2/blog/hungoverowls/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        
        // Creates the URL Session to execute a network request given the above url in order to fetch our blog data.
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            // Check for server errors. Makes sure the response is within the `200-299` range (the standard range for a successful response)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }
            
            // Check for data
            guard let data = data else {
                print("❌ Data is NIL")
                return
            }
            
            // The JSONDecoder's decode function can throw an error. To handle any errors we can wrap it in a `do catch` block.
            do {
                // Decode the JSON data into our custom `Blog` model.
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                                
                DispatchQueue.main.async { [weak self] in
                    // Access the array of posts
                    let posts = blog.response.posts

                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    // TODO: Store posts in the `movies` property on the view controller
                    self?.posts = posts
                    self?.tableView.reloadData()
                    print("🍏 Fetched and stored \(posts.count) posts")
                    
                    // End refreshing here
                    self?.tableView.refreshControl?.endRefreshing()
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
