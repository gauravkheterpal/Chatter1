//
//  RestModel.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

let groupIdentifier = "group.metacube.mobile.chatter1"
let groupIdentiferPath = "posts.bin"

// Simple model object for responses

struct ResponseData {
    
    var json: AnyObject
    
    subscript(key: String) -> AnyObject? {
        if let data = json as? [String: AnyObject] {
            return data[key]
        }
        return .None
    }
}

// Model

class RestModel: NSObject {
    
    // Properties
    var items: [ResponseData] = []
    var completion: ((error: NSError!) -> Void)!
    
    subscript(index: Int, key: String) -> AnyObject? {
        return items[index][key]
    }
    
    override init() {
        super.init()
    }
    
    // App Group storage for WatchKit
    
    lazy var groupURL: NSURL = {
        let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupIdentifier)
        let fileURL = groupURL?.URLByAppendingPathComponent(groupIdentiferPath)
        return fileURL!
        }()
    
    func writeToSharedAppGroupData() {
        
        let fileCoord = NSFileCoordinator()
        fileCoord.coordinateWritingItemAtURL(groupURL, options: [], error: nil) { ( newURL :NSURL) -> Void in
            
            var toSave: [AnyObject] = []
            for object in self.items {
                toSave.append(object.json)
            }
            
            let saveData = NSKeyedArchiver.archivedDataWithRootObject(toSave)
            let success = saveData.writeToURL(newURL, atomically: true)
            
            if !success {
                print("error saving to app group storage")
            }
        }
    }
    
    // Public Methods
    
    func reload(query q: String, saveResultsToAppGroup: Bool? = false, completion: (error: NSError!) -> Void) {
        
        self.completion = completion
        
        let api = SFRestAPI.sharedInstance()
        _ = api.requestForQuery(q)
        
        api.performSOQLQuery(q, failBlock: { error in
            
            print("query: \(q) failed with error: \(error)")
            
            self.completion(error: error)
            }) { response in
                if let records = response["records"] as? [AnyObject] {
                    let responseItems = records.map {ResponseData(json: $0)}
                    self.items = responseItems
                    if let shouldSave = saveResultsToAppGroup {
                        if shouldSave {
                            self.writeToSharedAppGroupData()
                        }
                    }
                }
                
                self.completion(error: .None)
        }
    }
}
