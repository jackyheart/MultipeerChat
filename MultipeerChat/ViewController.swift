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
    
    var peerID:MCPeerID?
    var session:MCSession?
    var browser:MCBrowserViewController?
    var advertiser:MCAdvertiserAssistant?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .Required)
        self.session?.delegate = self
        self.advertiser = MCAdvertiserAssistant(serviceType: kServiceType, discoveryInfo: nil, session: self.session)
        self.browser = MCBrowserViewController(serviceType: kServiceType, session: self.session)
        self.browser?.delegate = self
        
        self.advertiser?.start()//start advertising (by default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBActions
    
    @IBAction func discoveredChanged(sender: AnyObject) {
        
        let toggle = sender as! UISwitch
        
        if(toggle.on) {
            self.advertiser?.start()
        } else {
            self.advertiser?.stop()
        }
    }
    
    @IBAction func browseNearby(sender: AnyObject) {
    
        self.presentViewController(self.browser!, animated: true, completion: nil)
    }
    
    @IBAction func disconnectTapped(sender: AnyObject) {
    
        self.session?.disconnect()
        self.tblView.reloadData()
    }
    
    //MARK: - MCSessionDelegate
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        
        return certificateHandler(true)
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        print("myPeerID: \(self.session?.myPeerID)")
        print("peerID: \(peerID)")
        
        switch state {
            
        case .Connecting:
            println("Connecting..")
            
        case .Connected:
            println("Connected..")
            self.tblView.reloadData()
            
        case .NotConnected:
            println("Not Connected..")
            
        default:
            break;
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        println("received data from peer: \(peerID)")
        
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    //MARK: - MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        self.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.session?.connectedPeers.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        let row = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        return row
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueChat" {
        
            if let selIdxPath = self.tblView.indexPathForSelectedRow() {
            
                let selPeerID = self.session?.connectedPeers[selIdxPath.row] as! MCPeerID
                let controller = segue.destinationViewController as! ChatViewController
                controller.session = self.session
                controller.peerID = selPeerID
                
            }//end if
        }//end if
    }
}

