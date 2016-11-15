//
//  FixItVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FixItVC: NSViewController {

    @IBOutlet weak var securitySettingsStackView: NSStackView!
    
    var horizStackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizStackView = NSStackView()
        horizStackView.orientation = NSUserInterfaceLayoutOrientation.horizontal
        //horizStackView.userInterfaceLayoutDirection = NSUserInterfaceLayoutDirection.leftToRight
        
        let btn1: NSButton = NSButton(title: "Click Me 1", target: nil, action: nil)
        let btn2: NSButton = NSButton(title: "Click Me 2", target: nil, action: nil)
        let btn10: NSButton = NSButton(title: "Click Me 10", target: nil, action: nil)
        
        //horizStackView.addSubview(btn1)
        horizStackView.addView(btn1, in: NSStackViewGravity.leading)
        horizStackView.addView(btn2, in: NSStackViewGravity.leading)
        
        
        //securitySettingsStackView.addSubview(horizStackView)
        securitySettingsStackView.addView(horizStackView, in: NSStackViewGravity.top)
        securitySettingsStackView.addView(btn10, in: NSStackViewGravity.top)
    }
    
    
    
}
