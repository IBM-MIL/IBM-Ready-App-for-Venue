/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// ViewController to handle navigation in people tab
class PeopleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destination = segue.destinationViewController as? PeopleListViewController {
            destination.delegate = self
        }
        
        if let destination = segue.destinationViewController as? PersonDetailsViewController {
            if let selectedUser = sender as? User {
                let destinationViewModel = PersonDetailsViewModel(person: selectedUser)
                destination.viewModel = destinationViewModel
            }
            
        }
    }

}

extension PeopleViewController: PeopleListDelegate {
    func didSelectRow(tableView: UITableView, indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PeopleTableViewCell {
            performSegueWithIdentifier("toPersonDetails", sender: cell.user)
        }
    }
    func additionalSetupForCell(cell: PeopleTableViewCell) {
        
    }
}
