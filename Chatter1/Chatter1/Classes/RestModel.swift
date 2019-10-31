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
        return .none
    }
}

// Model

class RestModel: NSObject {
    
    // Properties
    var items: [ResponseData] = []
    var completion: ((_ error: NSError?) -> Void)!
    
    subscript(index: Int, key: String) -> AnyObject? {
        return items[index][key]
    }
    
    override init() {
        super.init()
    }
    
    // App Group storage for WatchKit
    
    lazy var groupURL: NSURL = {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        let fileURL = groupURL?.appendingPathComponent(groupIdentiferPath)
        return fileURL! as NSURL
        }()
    
    func writeToSharedAppGroupData() {
        
        let fileCoord = NSFileCoordinator()
        fileCoord.coordinate(writingItemAt: groupURL as URL, options: NSFileCoordinator.WritingOptions.forMoving, error: nil) { (newURL) in
            var toSave: [AnyObject] = []
            for object in self.items {
                toSave.append(object.json)
            }
            
            let saveData = NSKeyedArchiver.archivedData(withRootObject: toSave) as NSData
            let success = saveData.write(to: newURL, atomically: true)
            
            if !success {
                print("error saving to app group storage")
            }
        }
    }
    
    // Public Methods
    
    func reload(query q: String, saveResultsToAppGroup: Bool? = false, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.completion = completion
        
        let api = SFRestAPI.sharedInstance()
        let request = api!.request(forQuery: q)
        
        api!.performSOQLQuery(q, fail: { error in
            
            self.completion(error)
            } as! SFRestFailBlock) { response in
                if let records = response?["records"] as? [AnyObject] {
                    let responseItems = records.map {ResponseData(json: $0)}
                    self.items = responseItems
                    if let shouldSave = saveResultsToAppGroup {
                        if shouldSave {
                            self.writeToSharedAppGroupData()
                        }
                    }
                }
                
                self.completion(nil)
        }
    }
}
