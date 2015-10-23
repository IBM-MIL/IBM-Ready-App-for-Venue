/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class GroupsViewController: UIViewController {
    
    var leaderboard: [String: Int] = [:]
    var sorted: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for user in ApplicationDataManager.sharedInstance.users {
            leaderboard[user.name] = user.score
        }
        sorted = Array(leaderboard.keys).sort({self.leaderboard[$0] > self.leaderboard[$1]})
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GroupsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? ScoreTableViewCell {
            cell.numberLabel.text = "\(indexPath.row + 1)"
            
            if let score = leaderboard[sorted[indexPath.row]] {
                cell.nameLabel.text = sorted[indexPath.row]
                cell.scoreLabel.text = "\(score)"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}

extension GroupsViewController: UITableViewDelegate {
    
}
