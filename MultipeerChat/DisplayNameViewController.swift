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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.displayNameTF.text = UIDevice.currentDevice().name
        self.title = "MultiPeer Chat"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
