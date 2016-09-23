//
//  InterfaceController.swift
//  Chatter1 WatchKit Extension
//
//  Created by Bhavna Gupta on 30/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ChatterFeedRow: NSObject {
    @IBOutlet weak var rowText: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var watchSession = WCSession.default()
    var feeds : [String] = []
    var feedData : [AnyObject] = []
    var feedDataArray  : [AnyObject] = []
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    var rowData: [AnyObject]?
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    private func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]){
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override init() {
        super.init()
    }
    
    override func willActivate() {
        super.willActivate()
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            // Add self as a delegate of the session so we can handle messages
            watchSession.delegate = self
            if #available(watchOSApplicationExtension 2.2, *) {
                if watchSession.activationState != WCSessionActivationState.activated {
                    watchSession.activate()
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return rowData![rowIndex]
    }
    
    @IBAction func refreshFeeds() {
        let userInfo : [String : String] = ["body": "",
                        "parentId": ""]
        self.watchSession.sendMessage(userInfo, replyHandler: { (result) in
            self.feedData = result["feedcontent"] as! [AnyObject]
            for (_,postData) in self.feedData.enumerated() {
                let obj = postData as! [String: AnyObject]
                let display = obj["Body"] as! String
                self.feeds.append(display)
                self.feedDataArray.append(postData)
            }
            self.rowData = self.feeds as [AnyObject]?
            self.table.setNumberOfRows(self.feeds.count, withRowType: "chatterFeedRow")
            for (index, data) in self.feeds.enumerated() {
                let row = self.table.rowController(at: index) as! ChatterFeedRow
                row.rowText.setText(data)
            }
            self.feeds = []
            }, errorHandler: { (NSError) in
                print("error in error handler.....")
        })
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "DetailInterfaceController", context: self.feedDataArray[rowIndex])
    }
    
}
