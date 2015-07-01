//
//  ViewController.swift
//  MultipeerChat
//
//  Created by Jacky Tjoa on 1/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {

    var peerID:MCPeerID? = nil
    var session:MCSession? = nil
    var browserVC:MCBrowserViewController? = nil
    var advAssistant:MCAdvertiserAssistant? = nil
    
    let kServiceType = "multi-peer-chat"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.peerID = MCPeerID(displayName: "MyName")
        self.session = MCSession(peer: self.peerID)
        self.session?.delegate = self
        
        //start advertising
        
        /*
        Service Type name:
        - Must be 1–15 characters long
        - Can contain only ASCII lowercase letters, numbers, and hyphens.
        */
        
        self.advAssistant = MCAdvertiserAssistant(serviceType: kServiceType, discoveryInfo: nil, session: self.session)
        self.advAssistant?.start()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.browserVC = MCBrowserViewController(serviceType: kServiceType, session: self.session)
        self.browserVC?.delegate = self
        self.presentViewController(self.browserVC!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MCBrowserViewControllerDelegate
    
    func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) -> Bool {
        
        return true
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.browserVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        self.browserVC?.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: - MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        println("myPeerID: \(self.session?.myPeerID)")
        println("peerID: \(peerID)")
        
        switch state {
        
        case .Connecting:
            println("Connecting..")
            
        case .Connected:
            println("Connected..")
            
        case .NotConnected:
            println("Not Connected..")
            
        default:
            break;
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        println("received data from peer: \(peerID)")
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        
    }
}

