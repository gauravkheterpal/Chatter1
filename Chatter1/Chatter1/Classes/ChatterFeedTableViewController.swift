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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - UITableViewDatasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let text = model[indexPath.row, "Body"] as? String {
            
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]
            let attrString:NSAttributedString? = NSAttributedString(string: text, attributes: attributes)
            var rect:CGRect = attrString!.boundingRect(with: CGSize(width: 300.0, height: CGFloat.greatestFiniteMagnitude) , options: NSStringDrawingOptions.usesLineFragmentOrigin, context:nil )
            var requredSize:CGRect = rect
            return requredSize.height+30
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! UITableViewCell
        if let text = model[indexPath.row, "Body"] as? String {
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
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
        SFAuthenticationManager.shared().logout()
    }
}
