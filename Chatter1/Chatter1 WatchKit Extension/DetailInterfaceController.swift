//
//  DetailInterfaceController.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 30/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import WatchKit
import Foundation

class DetailInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var postLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    
    var authorId: String! // used upon reply
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let data = context as? [String: AnyObject] {
            
            if let createdBy: AnyObject = data["CreatedBy"] {
                
                if let author = createdBy["Name"] as? String {
                    authorLabel.setText("\(author)")
                }
                
                if let createdById = createdBy["Id"] as? String {
                    authorId = createdById
                }
            }
            
            if let text = data["Body"] as? String {
                postLabel.setText(text)
            }
        }
    }
    
    @IBAction func replyPressed() {
        
        let suggestions = ["Thanks for the post!", "Canned reply"]
        
        presentTextInputControllerWithSuggestions(suggestions,
            allowedInputMode: .AllowEmoji, completion: { selections in
                
                if selections != nil && selections.count > 0 {
                    // send the request out through the parent app...
                    let bodyText = selections[0] as? String
                    var userInfo = ["body": bodyText,
                        "parentId": self.authorId]
                    
                    DetailInterfaceController.openParentApplication(userInfo) {
                        (reply:[NSObject : AnyObject]!, error: NSError!) -> Void in
                        
                        println("reply from parent: \(reply) error: \(error)")
                    }
                }
        })
    }
    
}