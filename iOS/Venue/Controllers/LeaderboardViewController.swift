/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Displays the current leaders based on points from challenges
*/
class LeaderboardViewController: VenueUIViewController {
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    var viewModel: LeaderboardViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
     
        RACObserve(viewModel!, keyPath: "leaders").deliverOnMainThread().subscribeNext{ [unowned self] _ in
            self.leaderboardTableView.reloadData()
        }
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "challengesCompleted").subscribeNext({ [unowned self] _ in
            self.viewModel?.updateLeaderScore()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - TableView Methods

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.leaders.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LeaderboardTableViewCell
        
        viewModel!.setupLeaderboardCell(cell, row: indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let leaderboardDetailViewController = Utils.vcWithNameFromStoryboardWithName("LeaderboardDetailViewController", storyboardName: "Challenges") as? LeaderboardDetailViewController {
            
            if leaderboardDetailViewController.viewModel == nil {
                leaderboardDetailViewController.viewModel = LeaderboardDetailViewModel()
                let user = viewModel!.leaders[indexPath.row]
                leaderboardDetailViewController.viewModel?.user = user
            }
            navigationController?.pushViewController(leaderboardDetailViewController, animated: true)
        }
    }
    
}
