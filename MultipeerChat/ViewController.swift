//
//  ViewController.swift
//  MultipeerChat
//
//  Created by Jacky Tjoa on 1/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant!
    var displayName:String!
    var activityIndicator:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //session
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .Required)
        self.session.delegate = self
        self.advertiser = MCAdvertiserAssistant(serviceType: kServiceType, discoveryInfo: nil, session: self.session)
        self.browser = MCBrowserViewController(serviceType: kServiceType, session: self.session)
        self.browser.delegate = self
        
        self.advertiser.start()//start advertising (by default)
        
        //activity indicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.activityIndicator)
        
        //title
        self.title = displayName
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTableview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers

    func updateTableview(){
        
        if(self.session.connectedPeers.count > 0) {
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.tblView.reloadData()
                
                var lastIndex = NSIndexPath(forRow: self.session.connectedPeers.count - 1, inSection: 0)
                self.tblView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            })
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func discoveredChanged(sender: AnyObject) {
        
        let toggle = sender as! UISwitch
        
        if(toggle.on) {
            self.advertiser.start()
        } else {
            self.advertiser.stop()
        }
    }
    
    @IBAction func browseNearby(sender: AnyObject) {
    
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    @IBAction func disconnectTapped(sender: AnyObject) {
    
        self.session.disconnect()
        updateTableview()
    }
    
    //MARK: - MCSessionDelegate
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        
        return certificateHandler(true)
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        print("myPeerID: \(self.session.myPeerID)")
        print("peerID: \(peerID)")
        
        switch state {
            
        case .Connecting:
            println("Connecting..")
            
        case .Connected:
            println("Connected..")
            self.activityIndicator.startAnimating()
            updateTableview()

        case .NotConnected:
            println("Not Connected..")
            let appDomain = NSBundle.mainBundle().bundleIdentifier!
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
            self.activityIndicator.startAnimating()
            updateTableview()
            
        default:
            break;
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        //data
        println("received data from peer: \(peerID)")
        let message = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        print("received message: \(message)\\n")
        
        //message data
        let defaults = NSUserDefaults.standardUserDefaults()
        let date = NSDate()
        let msgDictionary = ["message":message, "date":date, "peerIDName":peerID.displayName]
        
        //retrieve chat history
        var chatArray = defaults.objectForKey(peerID.displayName) as? [[String:AnyObject]]
        var newMessagesInt = 0//keep track of new messages count
        
        var tmpArray:[[String:AnyObject]] = []
        
        if chatArray == nil {
        
            //first initalization
            tmpArray = [msgDictionary]
            newMessagesInt = 1
        }
        else
        {
            //retrieve count from UserDefaults
            var newMessagesStr = defaults.objectForKey(peerID.displayName+"counter") as! String
            newMessagesInt = newMessagesStr.toInt()!
            
            //track new messages
            newMessagesInt++
            
            tmpArray = chatArray!
            tmpArray.append(msgDictionary)
        }
        
        //save back to NSUserDefaults
        //let chatData = NSKeyedArchiver.archivedDataWithRootObject(tmpArray)
        defaults.setObject(tmpArray, forKey: peerID.displayName)
        defaults.setObject(String(newMessagesInt), forKey: peerID.displayName+"counter")
        
        //Notify data received
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidReceiveData", object: msgDictionary)
        
        //local notifications
        var notification = UILocalNotification()
        notification.alertBody = "\(peerID.displayName) sent you a message"
        notification.fireDate = NSDate()
        notification.applicationIconBadgeNumber = newMessagesInt
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //update peer list
        updateTableview()
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    //MARK: - MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        self.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.activityIndicator.stopAnimating()
        
        print("count: \(self.session.connectedPeers.count)")
        return self.session.connectedPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        let row = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PeerCell
        
        let peerID = self.session.connectedPeers[indexPath.row] as! MCPeerID
        row.textLabel?.text = peerID.displayName
        row.detailTextLabel?.text = peerID.description
        
        print("\\ncellForRow peerID: \(peerID)")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var newMsgCountStr = defaults.objectForKey(peerID.displayName+"counter") as? String
        print("newMessagesCountStr:\(newMsgCountStr)")
        row.counterLbl.layer.cornerRadius = row.counterLbl.bounds.width * 0.5
        row.counterLbl.backgroundColor = UIColor.blueColor()
        
        if let msgCount = newMsgCountStr {
        
            let counter = msgCount.toInt()
            
            if(counter == 0) {
            
                row.counterLbl.hidden = true
                
            } else {
            
                row.counterLbl.hidden = false
                row.counterLbl.text = msgCount
            }
        }//end if
        
        return row
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueChat" {
        
            if let selIdxPath = self.tblView.indexPathForSelectedRow() {
                
                //pass data
                let selPeerID = self.session.connectedPeers[selIdxPath.row] as! MCPeerID
                let controller = segue.destinationViewController as! ChatViewController
                controller.session = self.session
                controller.peerID = selPeerID
                
                //reset new message counter to 0
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject("0", forKey: selPeerID.displayName+"counter")
                
                //deselect row
                self.tblView.deselectRowAtIndexPath(selIdxPath, animated: true)
                
            }//end if
        }//end if
    }
}

