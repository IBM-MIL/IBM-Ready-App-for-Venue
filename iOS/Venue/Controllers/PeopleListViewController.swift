/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

// MARK: - PeopleListDelegate Declaration
@objc protocol PeopleListDelegate {
    func didSelectRow(tableView: UITableView, indexPath: NSIndexPath)
    optional func additionalSetupForCell(cell: PeopleTableViewCell)
}

/// ViewController for displaying list of users with search bar
class PeopleListViewController: UIViewController {
    var viewModel = PeopleListViewModel()
    weak var delegate: PeopleListDelegate?

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchTextField.rac_textSignal().subscribeNext({[unowned self](text: AnyObject!) -> Void in
            self.viewModel.filterPeople(text as! String)
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UITableView & UIScrollView Methods
extension PeopleListViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.displayedUserSections.count
    }
    
    /**
    Create header for the last name inital
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = CGRectMake(0, 0, tableView.frame.width, 28)
        let headerView = UIView(frame: headerFrame)
        headerView.backgroundColor = UIColor.venueBabyBlue()
        
        let labelFrame = CGRectMake(20, 0, headerView.frame.width - 20, headerView.frame.height)
        let headerLabel = UILabel(frame: labelFrame)
        headerLabel.textColor = UIColor.venueDarkGray()
        headerLabel.font = UIFont.systemFontOfSize(12.0)
        headerLabel.text = String(viewModel.displayedUserSections[section].key)
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedUserSections[section].users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("peopleCell") as? PeopleTableViewCell {
            
            viewModel.setUpPersonCell(cell, indexPath: indexPath)
            
            if let delegate = self.delegate {
                delegate.additionalSetupForCell?(cell)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if let delegate = self.delegate {
                delegate.didSelectRow(tableView, indexPath: indexPath)
            }
        
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
