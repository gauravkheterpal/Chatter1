//
//  RestModel.swift
//  Chatter1
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.


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

class RestModel: NSObject{
    
    // Properties
    var items: [ResponseData] = []
    var completion: ((_ error: Error?) -> Void)!
    
    
    subscript(index: Int, key: String) -> AnyObject? {
        return items[index][key]
    }
    
    override init() {
        super.init()
    }
    
    // App Group storage for WatchKit
    
    lazy var groupURL: URL = {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        let fileURL = try! groupURL?.appendingPathComponent(groupIdentiferPath)
        return fileURL!
    }()
    
    
    func writeToSharedAppGroupData() {
        
        let fileCoord = NSFileCoordinator()
        fileCoord.coordinate(writingItemAt: groupURL, options: [], error: nil) { ( newURL :URL) -> Void in
            var toSave: [AnyObject] = []
            for object in self.items {
                toSave.append(object.json)
            }
            let saveData = NSKeyedArchiver.archivedData(withRootObject: toSave)
            let success = (try? saveData.write(to: newURL, options: [])) != nil
            if !success {
                print("error saving to app group storage")
            }
        }
    }
    
    // Public Methods
    func reload(query q: String, saveResultsToAppGroup: Bool? = false, completion: @escaping (_ error: Error?) -> Void) {
        self.completion = completion
        let api = SFRestAPI.sharedInstance()
        let request = api?.request(forQuery: q)

        api?.performSOQLQuery(q, fail: { error in
            print("query: \(q) failed with error: \(error)")
            completion(error)
        })     { response in
            if let records = response?["records"] as? [AnyObject] {
                let responseItems = records.map {ResponseData(json: $0)}
                self.items = responseItems
                if let shouldSave = saveResultsToAppGroup {
                    if shouldSave {
                        self.writeToSharedAppGroupData()
                    }
                }
            }
            completion (.none)
        }
    }
}
