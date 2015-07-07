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
    var kbHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshChatList:", name: "MCDidReceiveData", object: nil)
        
        //keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let recognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(recognizer)
        
        self.title = self.peerID?.displayName
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //retrieve chat history
        let defaults = NSUserDefaults.standardUserDefaults()
        
        /*
        if let chatData = defaults.objectForKey(self.peerID!.displayName) as? NSData {
            
            if let chatArray = NSKeyedUnarchiver.unarchiveObjectWithData(chatData) as? [[String:AnyObject]] {
                
                self.dataArray = chatArray
            }
        }
        */
        
        if let chatArray = defaults.objectForKey(self.peerID!.displayName) as? [[String:AnyObject]] {
        
            dataArray = chatArray
        }
        else {
        
            print("Chat is blank !")
        }
        
        //reload table
        updateTableview()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("session(chatVC): \(self.session)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification:NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                
                print("kbHeight: \(kbHeight)")
                
                animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        
        var movement = (up ? -(kbHeight) : (kbHeight))
        
        print("movement: \(movement)")
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    // MARK: - Gesture
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        
        self.inputTF.resignFirstResponder()
    }
    
    // MARK: - Helpers
    
    func updateTableview(){
    
        if self.dataArray.count > 0 {
       
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.tblView.reloadData()
                
                var lastIndex = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
                self.tblView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            })
        }
        
    }
    
    // MARK: - NSNotificationCenter
    
    func refreshChatList(notification:NSNotification) {
        
        let msgDictionary = notification.object as! [String: AnyObject]
        self.dataArray.append(msgDictionary)
    
        updateTableview()
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
            else {
                
                let date = NSDate()
                let msgDictionary = ["message":self.inputTF.text, "date":date, "peerIDName":self.session!.myPeerID.displayName]
                self.dataArray.append(msgDictionary)
                
                //save back to NSUserDefaults
                //let chatData = NSKeyedArchiver.archivedDataWithRootObject(self.dataArray)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.dataArray, forKey: self.peerID!.displayName)
                
                //dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.tblView.reloadData()
                    
                    var lastIndex = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
                    self.tblView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                //})
                
                self.inputTF.text = ""
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
     
        print("chatVC: count: \(self.dataArray.count)")
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("chatVC: cellForRowAtIdxPath")
        
        let cellIdentifier = "CellIdentifier"
        let row = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        //data
        let msgDictionary = self.dataArray[indexPath.row] as [String:AnyObject]
        print(msgDictionary)
        
        let message = msgDictionary["message"] as! String
        let date = msgDictionary["date"] as! NSDate
        let peerIDName = msgDictionary["peerIDName"] as! String
        
        //formatter
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let dateString = formatter.stringFromDate(date)
        print("dateString: \(dateString)")
        
        //display
        if self.session!.myPeerID.displayName == peerIDName {
        
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
