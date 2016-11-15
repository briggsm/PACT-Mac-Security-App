//
//  FitIt3VC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FitIt3VC: NSViewController {

    @IBOutlet weak var settingsStackView: NSStackView!
    
    //var entryStackView: NSStackView!
    let settingsToQuery = ["screensaver5sec.sh", "screensaver10min.sh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for settingToQuery in settingsToQuery {

            
            let dTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-d"])  // -d => Get Description
            
            let entryStackView = NSStackView()  // Default is Horizontal
            entryStackView.alignment = .centerY
            entryStackView.spacing = 10
            entryStackView.distribution = .gravityAreas
            //entryStackView.translatesAutoresizingMaskIntoConstraints = false

            
            
            let pfTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-pf"])  // -pf => Return "pass" or "fail" security test
            
            // Setup Image
            var imgName = "greyQM"
            if pfTaskOutput == "pass" {
                imgName = "greenCheck"
            } else if pfTaskOutput == "fail" {
                imgName = "redX"
            } else {
                // Uh oh, unknow state. Shouldn't get here.
                imgName = "greyQM"
            }
            let statusImgView = NSImageView(image: NSImage(named: imgName)!)

            // Setup Button
            let fixItBtn = NSButton(title: "Fix It!", target: self, action: #selector(fixSecuritySetting))
            fixItBtn.identifier = settingToQuery
            fixItBtn.isHidden = pfTaskOutput == "pass"
            
            // Add Image, Label, and Button to Stack View
            entryStackView.addView(statusImgView, in: .leading)
            entryStackView.addView(NSTextField(labelWithString: dTaskOutput), in: .leading)
            entryStackView.addView(fixItBtn, in: .leading)
            
            settingsStackView.addView(entryStackView, in: NSStackViewGravity.top)
        }
    }
    
    func runTask(taskFilename: String, arguments: [String]) -> String {
        // Note: Running in Main thread because it's not going take long at all (if it does, something is majorly wrong).
        let settingNameArr = taskFilename.components(separatedBy: ".")
        guard let path = Bundle.main.path(forResource: settingNameArr[0], ofType:settingNameArr[1]) else {
            print("Unable to locate: \(taskFilename)")
            return "Unable to locate: \(taskFilename)"
        }
        
        var getDescriptionTask: Process!
        
        getDescriptionTask = Process()
        getDescriptionTask.launchPath = path
        getDescriptionTask.arguments = arguments  // -d => Get Description, -r => Read Setting, -w => Write Setting
        
        /*
         lsTask.terminationHandler = {
         
         task in
         DispatchQueue.main.async(execute: {
         self.executeBtn.isEnabled = true
         self.spinner.stopAnimation(self)
         //self.isRunning = false
         })
         
         }
         */
        
        let outputPipe = Pipe()
        getDescriptionTask.standardOutput = outputPipe
        
        getDescriptionTask.launch()
        getDescriptionTask.waitUntilExit()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var outputString = String(data: data, encoding: String.Encoding.utf8) ?? ""
        outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return outputString
    }
    
    func fixSecuritySetting(btn: NSButton) {
        
        //print ("test")
        let settingToQuery = btn.identifier ?? ""
        //print("btn: \(btn.title): \(btnIdStr)")
        
        //let outputString = runTask(taskFilename: settingToQuery, arguments: ["-w"])  // -w => Write Setting
        _ = runTask(taskFilename: settingToQuery, arguments: ["-w"])  // -w => Write Setting
        
        // TODO - Read in this Setting again to make sure it now passes the test
        
        
    }
}

/*
extension NSButton {
    var _tagString: String
    
    var tagString: String {
        set {
            _tagString = newValue
        } get {
            return _tagString
        }
    }
}
 */
