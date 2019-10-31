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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
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
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return rowData![rowIndex]
    }
    
    func configureTable() {
        
        // Access group storage
        let fileCoordinator = NSFileCoordinator()
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        let fileURL = groupURL?.appendingPathComponent(groupIdentifierPath)
        
        fileCoordinator.coordinate(readingItemAt: fileURL!, options: NSFileCoordinator.ReadingOptions.withoutChanges, error: nil) { (newURL) in
            
            if let savedData = NSData(contentsOf: newURL) {
                if let data = NSKeyedUnarchiver.unarchiveObject(with: savedData as Data) as? [AnyObject] {
                    
                    self.rowData = data
                    self.table.setNumberOfRows(data.count, withRowType: "chatterFeedRow")
                    
                    for (index, postData) in data.enumerated() {
                        if let row = self.table.rowController(at: index) as? ChatterFeedRow {
                            let obj = postData as! [String: AnyObject]
                            let display = obj["Body"] as! String
                            print(display)
                            row.rowText.setText(display)
                        }
                    }
                }
            }
        }
    }
    
    
}
