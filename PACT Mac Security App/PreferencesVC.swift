//
//  PreferencesVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/11/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class PreferencesVC: NSViewController {

    @IBOutlet weak var saveToFolderTF: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let saveToFolderDefault = UserDefaults.standard.string(forKey: "saveToFolder") {
            saveToFolderTF.stringValue = saveToFolderDefault
        } else {
            saveToFolderTF.stringValue = "/tmp"
        }
        
    }
    
    @IBAction func browseBtnClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a Directory"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        if (openPanel.runModal() == NSModalResponseOK) {
            //self.saveToFolderTF.stringValue = openPanel.urls[0].absoluteString
            self.saveToFolderTF.stringValue = openPanel.urls[0].path
        }
        
//        openPanel.begin { (result) -> Void in
//            if result == NSFileHandlingPanelOKButton {
//                //Do what you will
//                //If there's only one URL, surely 'openPanel.URL'
//                //but otherwise a for loop works
//                self.saveToFolderTF.stringValue = openPanel.urls[0].absoluteString
//            }
//        }
        
        
//      let saveToFolder = saveToFolderTF.stringValue
//      UserDefaults.standard.setValue(saveToFolder, forKey: "saveToFolder")
        UserDefaults.standard.setValue(saveToFolderTF.stringValue, forKey: "saveToFolder")
        

    }
    
    
}
