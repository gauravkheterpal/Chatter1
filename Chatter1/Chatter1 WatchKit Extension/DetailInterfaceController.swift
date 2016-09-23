//
//  DetailInterfaceController.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 30/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class DetailInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var session = WCSession.default()

    @IBOutlet weak var postLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    
    var authorId: String! // used upon reply
    var feedId : String!
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let data = context as? [String: AnyObject] {
            if let createdBy: [String : Any] = data["CreatedBy"] as! [String : Any]? {
                if let author = createdBy["Name"] as? String {
                    authorLabel.setText("\(author)")
                }
                if let createdById = createdBy["Id"] as? String {
                    authorId = createdById
                }
            }
            feedId = data["Id"] as? String
            if let text = data["Body"] as? String {
                postLabel.setText(text)
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
   
    @IBAction func replyPressed() {
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
        let suggestions = ["Thanks for the post!", "canned reply"]
        if WCSession.default().isReachable == true {
            presentTextInputController(withSuggestions: suggestions,
                                       allowedInputMode: .allowEmoji, completion: { selections in
                                        if selections != nil && selections!.count > 0 {
                                            // send the request out through the parent app...
                                            let bodyText = (selections?[0])! as AnyObject
                                            let parentID = self.feedId as String
                                            let userInfo = ["body": bodyText as AnyObject,
                                                            "parentId": self.feedId] as [String : Any]
                                            self.session.sendMessage(userInfo, replyHandler: { (result) in
                                                }, errorHandler: { (NSError) in
                                                    print("error in error handler.....")
                                            })
                                        }
            })
        }
    }
}
