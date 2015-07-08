//
//  DisplayNameViewController.swift
//  MultipeerChat
//
//  Created by Jacky Tjoa on 4/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit

class DisplayNameViewController: UIViewController {
    
    @IBOutlet weak var displayNameTF: UITextField!
    var kbHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameDidChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //gesture recognizer
        let recognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(recognizer)
        
        //UI
        self.displayNameTF.text = UIDevice.currentDevice().name
        self.title = "MultiPeer Chat"
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
            
            if(abs(offset) > 100.0) {
                
                //if not quicktype, hardcode the offset
                offset = offset > 0 ? 100.0 : -100
            }
            newFrame.origin.y -= offset
            
            self.view.frame = newFrame
            
        }, completion: nil)
    }
    
    // MARK: - Gesture
    
    func handleTap(recognizer:UITapGestureRecognizer) {
    
        self.displayNameTF.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueMain" {
            
            let trimmedInput = self.displayNameTF.text.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            let len = count(trimmedInput)
        
            if len == 0 {
                
                var alert = UIAlertController(title: "Invalid", message: "Please enter your display name", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.displayNameTF.text = ""
            }
            else {
                
                let controller = segue.destinationViewController as! ViewController
                controller.displayName = self.displayNameTF.text
            }
        }
    }
}
