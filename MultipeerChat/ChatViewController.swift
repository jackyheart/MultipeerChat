//
//  ChatViewController.swift
//  MultipeerChat
//
//  Created by Jacky Tjoa on 2/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var inputTF: UITextField!
    
    var session:MCSession?
    var peerID:MCPeerID?
    var dataArray = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshChatList:", name: "MCDidReceiveData", object: nil)
        
        self.title = self.peerID?.displayName
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //retrieve chat history
        let defaults = NSUserDefaults.standardUserDefaults()
        var chatArray = defaults.objectForKey(self.peerID!.displayName) as? [[String:AnyObject]]
        
        if chatArray != nil {
            
            dataArray = chatArray!
        }
        else
        {
            print("Chat is blank !")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("session(chatVC): \(self.session)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Business Logic
    
    func refreshChatList(notification:NSNotification) {
        
        let msgDictionary = notification.object as! [String: AnyObject]
        self.dataArray.append(msgDictionary)
    
        self.tblView.reloadData()
    }
    
    // MARK: - IBActions
    
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        let row = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        //data
        let msgDictionary = self.dataArray[indexPath.row] as [String:AnyObject]
        print(msgDictionary)
        
        let message = msgDictionary["message"] as! String
        let date = msgDictionary["date"] as! NSDate
        let peerID = msgDictionary["peerID"] as! MCPeerID
        
        //formatter
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let dateString = formatter.stringFromDate(date)
        
        //display
        if self.session?.myPeerID == peerID {
        
            row.textLabel?.textAlignment = .Right
            row.detailTextLabel?.textAlignment = .Right
            
            row.textLabel?.text = message
            row.detailTextLabel?.text = dateString
        }
        else {
        
            row.textLabel?.textAlignment = .Left
            row.detailTextLabel?.textAlignment = .Left
            
            row.textLabel?.text = message
            row.detailTextLabel?.text = dateString
        }
        
        return row
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
