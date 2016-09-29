//
//  ChatterFeedTableViewController.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//
import WatchConnectivity
import WatchKit
import Foundation

class ChatterFeedTableViewController: UITableViewController,WCSessionDelegate {
  
    let model = RestModel()
    var watchSession = WCSession.default()

    @IBOutlet weak var tableRefreshControl: UIRefreshControl!
    
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    @IBAction func refreshView(_ sender: AnyObject) {
        refreshTable()
        self.tableRefreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.color = UIColor .black
        indicator.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)
        indicator.startAnimating()
        refreshTable()
        startWCsession()
    }

    func startWCsession() {
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @available(iOS 9.3, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    func sessionDidDeactivate(_ session: WCSession){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: @escaping ([String : AnyObject]) -> Void) {
        if message["body"] as! String == "" {
            let request: [String: [AnyObject]] = ["feedcontent": self.feedData()]
            replyHandler (request as [String : AnyObject])
        }
        else {
            let parentId = message["parentId"] as! NSString
            let body = message["body"] as! NSString
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendReply(body as String! ,forParentId : parentId as String! , replyHandler: { (result) in
                let reply : [String : AnyObject] = ["reply" : result["response"]! as AnyObject]
                replyHandler(reply)
            })
        }
    }
    
    lazy var groupURL: URL = {
        let groupIdentifier = "group.metacube.mobile.chatter1"
        let groupIdentiferPath = "posts.bin"
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        let fileURL = try! groupURL?.appendingPathComponent(groupIdentiferPath)
        return fileURL!
    }()
    
    func feedData() -> [AnyObject] {
        let fileCoord = NSFileCoordinator()
        var feedData : [AnyObject] = []
        fileCoord.coordinate(readingItemAt: groupURL, options: [], error: nil) { (newURL :URL) -> Void in
            if let savedData = try? Data(contentsOf: newURL, options: []) {
                //if let savedData = try? NSData(contentsOf: newURL, options: NSData.ReadingOptions.mappedIfSafe, err) {
                if let data = NSKeyedUnarchiver.unarchiveObject(with: savedData as Data) as? [AnyObject]{
                    feedData = data
                    }
                }
            }
        return feedData
        }
    
    func refreshTable() {
          let query = "SELECT Id,CreatedBy.Name,CreatedBy.Id,Body,CreatedDate FROM FeedItem WHERE Type = 'TextPost' and CreatedById != '\(SFUserAccountManager.sharedInstance().activeUserIdentity.userId!)' ORDER BY CreatedDate DESC LIMIT 100"
        model.reload(query: query,
        saveResultsToAppGroup: true, completion: { error in
        DispatchQueue.main.async { _ in
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) 
        if let text = model[(indexPath as NSIndexPath).row, "Body"] as? String {
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.textLabel!.text = text
        }
        cell.imageView?.image = UIImage(named:"chatter_icon")
        cell.imageView?.isUserInteractionEnabled = false

        DispatchQueue.main.async {
                self.indicator.stopAnimating()
        }
        return cell
    }

    /*!
    This action is called when user taps "Logout" bar button item to logout user.
    @param sender -> the event sender
    */
    @IBAction func logout(_ sender: AnyObject) {
        // Call SFAuthenticationManager to logout user
        SFAuthenticationManager.shared().logout()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.handleSdkManagerLogout()
    }
}
