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
    
    var session:MCSession!
    var peerID:MCPeerID!
    var dataArray = [[String:AnyObject]]()
    var kbHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshChatList:", name: "MCDidReceiveData", object: nil)
        
        //notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameDidChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //gesture recognizer
        let recognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(recognizer)
        
        //UI
        self.title = self.peerID!.displayName
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
    
    func keyboardFrameDidChange(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        UIView.animateWithDuration(animationDuration, delay:0, options:.BeginFromCurrentState, animations: {
            
            //self.view.layoutIfNeeded()
            var newFrame = self.view.frame
            let keyboardFrameEnd = self.view.convertRect(keyboardScreenEndFrame, toView: nil)
            let keyboardFrameBegin = self.view.convertRect(keyboardScreenBeginFrame, toView: nil)
            
            var offset = (keyboardFrameBegin.origin.y - keyboardFrameEnd.origin.y)
            newFrame.origin.y -= offset
            
            self.view.frame = newFrame
            
        }, completion: nil)
    }
    
    // MARK: - Gesture
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        
        self.inputTF.resignFirstResponder()
    }
    
    // MARK: - Helpers
    
    func updateTableview(){
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            self.tblView.reloadData()
            
            if self.dataArray.count > 0 {
            
                var lastIndex = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
                self.tblView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        })
    }
    
    // MARK: - NSNotificationCenter
    
    func refreshChatList(notification:NSNotification) {
        
        let msgDictionary = notification.object as! [String: AnyObject]
        let peerIDName = msgDictionary["peerIDName"] as! String
        
        if peerIDName == self.peerID!.displayName {
        
            self.dataArray.append(msgDictionary)
            updateTableview()

            //clear counter
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("0", forKey: self.peerID.displayName+"counter")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func sendTapped(sender: AnyObject) {
        
        let trimmedInput = self.inputTF.text.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        let len = count(trimmedInput)
        
        if len > 0 {
        
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

                //refresh table
                self.tblView.reloadData()
                
                var lastIndex = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
                self.tblView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)

                self.inputTF.text = ""
            }
            
        } else {
        
            var alert = UIAlertController(title: "Invalid", message: "Please enter your text message", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            self.inputTF.text = ""
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
        let row = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChatCell
        
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
        print("peerID:\(peerIDName), dateString: \(dateString)")
        
        //display
        if self.session!.myPeerID.displayName == peerIDName {
        
            row.messageTF.textAlignment = .Right
            row.dateTF.textAlignment = .Right
            
            row.messageTF.textColor = UIColor.blueColor()
            row.messageTF.text = message
            
            row.dateTF.textColor = UIColor.grayColor()
            row.dateTF.text = dateString
        }
        else {
        
            row.messageTF.textAlignment = .Left
            row.dateTF.textAlignment = .Left
            
            row.messageTF.textColor = UIColor.greenColor()
            row.messageTF.text = message
            
            row.dateTF.textColor = UIColor.grayColor()
            row.dateTF.text = dateString
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
