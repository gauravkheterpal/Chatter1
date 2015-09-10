//
//  ChatterFeedTableViewController.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

class ChatterFeedTableViewController: UITableViewController {
    
    
    let model = RestModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTable()
    }
    
    func refreshTable() {
        
        let query = "SELECT Id,CreatedBy.Name,CreatedBy.Id,Body,CreatedDate FROM FeedItem WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 100"
        
        model.reload(query: query,
        saveResultsToAppGroup: true, completion: { error in
        
        dispatch_async(dispatch_get_main_queue()) { _ in
        self.tableView.reloadData()
        }
        })
    }
    
    // MARK: - UITableViewDatasource Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let text = model[indexPath.row, "Body"] as? String {
        
            let attrString:NSAttributedString? = NSAttributedString(string: text, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14.0)])
            let rect:CGRect = attrString!.boundingRectWithSize(CGSizeMake(300.0,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context:nil )
            let requredSize:CGRect = rect
            return requredSize.height+30
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) 
        if let text = model[indexPath.row, "Body"] as? String {
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFontOfSize(14)
            cell.textLabel!.text = text
            
        }
        cell.imageView?.image = UIImage(named:"chatter_icon")
        
        return cell
    }
    
    /*!
    This action is called when user taps "Logout" bar button item to logout user.
    @param sender -> the event sender
    */
    @IBAction func logout(sender: AnyObject) {
        // Call SFAuthenticationManager to logout user
        SFAuthenticationManager.sharedManager().logout()
    }
}
