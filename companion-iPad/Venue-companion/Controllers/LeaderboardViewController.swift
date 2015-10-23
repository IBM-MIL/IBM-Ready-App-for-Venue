/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var welcomeHeight: NSLayoutConstraint!
    
    let leaderboard = ApplicationDataManager.sharedInstance.globalLeaderboard
    var sorted: [String] = []
    var userIndex = 0
    
    var deviceNear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.bluetoothManager.leaderboardController = self
        }
        welcomeHeight.constant = 115 + 30
        // Do any additional setup after loading the view.
        sorted = Array(leaderboard.keys).sort({self.leaderboard[$0] > self.leaderboard[$1]})
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineUserIndex() {
        guard let currentUser = ApplicationDataManager.sharedInstance.currentUser else {
            return
        }
        
        var i = 0
        for name in sorted {
            if name == currentUser.name {
                userIndex = i
            }
            i++
        }
        
        if userIndex < 3 {
            userIndex = 3
        } else if userIndex > sorted.count - 4 {
            userIndex = sorted.count - 4
        }
        
        leaderboardTable.reloadData()
    }

}

extension LeaderboardViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if deviceNear{
            return 2
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if deviceNear {
            if section == 0 {
                return 3
            }
            return 7
        }
        return 10
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 34))
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        let label = UILabel(frame: CGRectMake(20, -3, tableView.frame.width-20, 34))
        label.textColor = UIColor(red: 123/255, green: 158/255, blue: 46/255, alpha: 1.0)
        label.font = UIFont.boldSystemFontOfSize(15.0)
        
        if section == 0 {
            label.text = "BRICKLAND'S BEST"
        } else {
            label.text = "YOUR COMPETITION"
        }
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("parkScoreCell") as? ScoreTableViewCell {
            
            var index: Int!
            if indexPath.section == 0 {
                index = 0 + indexPath.row
            } else {
                index = userIndex - 3 + indexPath.row
            }
            
            if let score = leaderboard[sorted[index]] {
                cell.numberLabel.text = "\(index + 1)"
                cell.nameLabel.text = sorted[index]
                cell.scoreLabel.text = "\(score) PTS"
            }
            
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let currentUser = ApplicationDataManager.sharedInstance.currentUser else {
            cell.backgroundColor = UIColor.whiteColor()
            return
        }
        
        if let cell = cell as? ScoreTableViewCell {
            if cell.nameLabel.text == currentUser.name {
                cell.nameLabel.text = "You"
                cell.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
}

extension LeaderboardViewController: UITableViewDelegate {
    
}