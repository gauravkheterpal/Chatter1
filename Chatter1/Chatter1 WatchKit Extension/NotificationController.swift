//
//  NotificationController.swift
//  Chatter1 WatchKit Extension
//
//  Created by Bhavna Gupta on 03/08/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class NotificationController: WKUserNotificationInterfaceController {
    
    @IBOutlet weak var alertLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bodyLabel: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        
        print("Local : ", terminator: "")
        print(notification, terminator: "")
        completionHandler(.custom)
    }
    
    override func  didReceiveRemoteNotification(_ remoteNotification: [AnyHashable : Any], withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void)
 {
        
        print(remoteNotification, terminator: "")
        if let remoteaps:NSDictionary = remoteNotification["aps"] as? NSDictionary{
            if let remoteAlert:NSString = remoteaps["alert"] as? NSString{
                handleNotification(remoteAlert)
            }
        }
        completionHandler(WKUserNotificationInterfaceType.custom)
    }
    
    func handleNotification( _ alert : AnyObject? ){
        
        self.alertLabel!.setText(alert as? String)
        //self.bodyLabel!.setText("Successful")
        /*
        if let alert: AnyObject = alert, let remotetitle = alert["title"] as? String{
        println( "didReceiveRemoteNotification::remoteNotification.alert \(remotetitle)" )
        self.alertLabel!.setText(remotetitle);
        }
        if let alert: AnyObject = alert, let remotebody = alert["body"] as? String{
        //println( "didReceiveRemoteNotification::remoteNotification.alert \(remotetitle)" )
        self.bodyLabel!.setText(remotebody);
        }*/
    }
    
}
