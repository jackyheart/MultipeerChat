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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let recognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.view.addGestureRecognizer(recognizer)

        // Do any additional setup after loading the view.
        self.displayNameTF.text = UIDevice.currentDevice().name
        self.title = "MultiPeer Chat"
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
        
        var movement = (up ? -(kbHeight - 150) : (kbHeight - 150))
        
        print("movement: \(movement)")
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
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
        
            if self.displayNameTF.text == "" {
                
                var alert = UIAlertController(title: "Invalid", message: "Please enter your display name", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                
                let controller = segue.destinationViewController as! ViewController
                controller.displayName = self.displayNameTF.text
            }
        }
    }
}
