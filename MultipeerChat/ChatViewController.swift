//
//  ChatViewController.swift
//  MultipeerChat
//
//  Created by Jacky Tjoa on 2/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputTF: UITextField!
    
    var session:MCSession?
    var peerID:MCPeerID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.peerID?.displayName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("session(chatVC): \(self.session)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendTapped(sender: AnyObject) {
        
        //let trimmedInput = self.inputTF.text.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        
        if self.inputTF.text != "" {
        
            var error:NSError?
            
            let data = self.inputTF.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            let peerArray = NSArray(object: self.peerID!)
            
            if !self.session!.sendData(data, toPeers: peerArray as [AnyObject], withMode: MCSessionSendDataMode.Reliable, error: &error) {
                
                print("error: \(error?.localizedDescription)")
            }
            
        } else {
        
            var alert = UIAlertController(title: "Invalid", message: "Please enter your text message", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
