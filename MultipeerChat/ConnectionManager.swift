//
//  ConnectionManager.swift
//  MultipeerChat
//
//  Created by Jacky on 7/2/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit
import MultipeerConnectivity
//import Foundation

class ConnectionManager: NSObject, MCSessionDelegate {
   
    static let sharedInstance = ConnectionManager()
    
    var peerID:MCPeerID?
    var session:MCSession?
    var browser:MCBrowserViewController?
    var advertiser:MCAdvertiserAssistant?
    
    override init() {
        super.init()
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .Required)
        self.session?.delegate = self
        self.browser = MCBrowserViewController(serviceType: kServiceType, session: self.session)
    }
    
    func advertiseDiscovery(shouldAdvertise: Bool) {
    
        //start advertising
        self.advertiser = MCAdvertiserAssistant(serviceType: kServiceType, discoveryInfo: nil, session: self.session)
        self.advertiser?.start()
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

                let userInfo:Dictionary = ["peerID":peerID]
                NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: userInfo)
                
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
}
