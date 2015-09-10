//
//  InterfaceController.swift
//  Chatter1 WatchKit Extension
//
//  Created by Bhavna Gupta on 30/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import WatchKit
import Foundation

let groupIdentifier = "group.metacube.mobile.chatter1"
let groupIdentifierPath = "posts.bin"


class ChatterFeedRow: NSObject {
    
    
    @IBOutlet weak var rowText: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    var rowData: [AnyObject]?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
    }
    
    override init() {
        super.init()
        configureTable()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return rowData![rowIndex]
    }
    
    func configureTable() {
        
        // Access group storage
        let fileCoordinator = NSFileCoordinator()
        let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupIdentifier)
        let fileURL = groupURL?.URLByAppendingPathComponent(groupIdentifierPath)
        
        fileCoordinator.coordinateReadingItemAtURL(fileURL!, options: [], error: nil) { (newURL :NSURL) -> Void in
            
            if let savedData = NSData(contentsOfURL: newURL) {
                
                if let data = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? [AnyObject] {
                    
                    self.rowData = data
                    self.table.setNumberOfRows(data.count, withRowType: "chatterFeedRow")
                    
                    for (index, postData) in data.enumerate() {
                        if let row = self.table.rowControllerAtIndex(index) as? ChatterFeedRow {
                            let obj = postData as! [String: AnyObject]
                            let display = obj["Body"] as! String
                            print(display, terminator: "")
                            row.rowText.setText(display)
                        }
                    }
                }
            }
        }
    }
    
    
}
