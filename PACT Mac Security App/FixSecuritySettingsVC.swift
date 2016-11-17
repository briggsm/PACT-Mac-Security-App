//
//  FitIt3VC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FixSecuritySettingsVC: NSViewController {

    @IBOutlet weak var settingsStackView: NSStackView!
    @IBOutlet weak var fixAllBtn: NSButton!
    
    let settingsToQuery = ["screensaver5sec.sh", "screensaver10min.sh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Build the list of Security Settings for the Main GUI
        for settingToQuery in settingsToQuery {
            let aTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-a"])  // -a => Applicable given user's OS Version.
            if aTaskOutput == "true" {
                let dTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-d"])  // -d => Get Description
                
                // Setup Image
                let statusImgView = NSImageView(image: NSImage(named: "greyQM")!)
                statusImgView.identifier = settingToQuery

                // Setup Button
                let fixItBtn = NSButton(title: "Fix It!", target: self, action: #selector(fixItBtnClicked))
                fixItBtn.identifier = settingToQuery
                
                // Setup StackView & Add Image, Label, and Button
                let entryStackView = NSStackView()  // Default is Horizontal
                entryStackView.alignment = .centerY
                entryStackView.spacing = 10
                entryStackView.distribution = .gravityAreas

                entryStackView.addView(statusImgView, in: .leading)
                entryStackView.addView(NSTextField(labelWithString: dTaskOutput), in: .leading)
                entryStackView.addView(fixItBtn, in: .leading)
                
                // Add our entryStackView to the settingsStackView
                settingsStackView.addView(entryStackView, in: NSStackViewGravity.top)
            }
        }
        
        updateAllStatusImagesAndFixItBtns()
    }
    
    func getImgNameFor(pfString: String) -> String {
        if pfString == "pass" {
            return "greenCheck"
        } else if pfString == "fail" {
            return "redX"
        } else {
            // Uh oh, unknow state. Shouldn't get here.
            return "greyQM"
        }
    }
    
    func runTask(taskFilename: String, arguments: [String]) -> String {
        print("runTask: \(taskFilename), with arguments: \(arguments[0])")
        
        // Note: Running in Main thread because it's not going take long at all (if it does, something is majorly wrong).
        let settingNameArr = taskFilename.components(separatedBy: ".")
        guard let path = Bundle.main.path(forResource: settingNameArr[0], ofType:settingNameArr[1]) else {
            print("Unable to locate: \(taskFilename)")
            return "Unable to locate: \(taskFilename)"
        }
        
        var getDescriptionTask: Process!
        
        getDescriptionTask = Process()
        getDescriptionTask.launchPath = path
        getDescriptionTask.arguments = arguments
        
        let outputPipe = Pipe()
        getDescriptionTask.standardOutput = outputPipe
        
        getDescriptionTask.launch()
        getDescriptionTask.waitUntilExit()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var outputString = String(data: data, encoding: String.Encoding.utf8) ?? ""
        outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("  runTask output: \(outputString)")
        return outputString
    }
    
    func fixItBtnClicked(btn: NSButton) {
        let settingToQuery = btn.identifier ?? ""
        if !settingToQuery.isEmpty {
            _ = runTask(taskFilename: settingToQuery, arguments: ["-w"])  // -w => Write Setting
            updateAllStatusImagesAndFixItBtns()
        }
    }

    @IBAction func fixAllBtnClicked(_ sender: NSButton) {
        for settingToQuery in settingsToQuery {
            let aTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-a"])  // -a => Applicable given user's OS Version.
            if aTaskOutput == "true" {
                let pfTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-pf"])  // -pf => Return "pass" or "fail" security test
                if pfTaskOutput != "pass" {
                    _ = runTask(taskFilename: settingToQuery, arguments: ["-w"])  // -w => Write Setting
                }
            }
        }
        
        updateAllStatusImagesAndFixItBtns()
    }
    
    func updateAllStatusImagesAndFixItBtns() {
        var allSettingsFixed = true
        
        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView? , let fixItBtn = entryStackView.views.last as! NSButton? {
                let settingToQuery = statusImgView.identifier ?? ""
                if !settingToQuery.isEmpty {
                    let pfTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-pf"])  // -pf => Return "pass" or "fail" security test
                    
                    statusImgView.image = NSImage(named: getImgNameFor(pfString: pfTaskOutput))
                    fixItBtn.isHidden = pfTaskOutput == "pass"
                    
                    if pfTaskOutput != "pass" {
                        allSettingsFixed = false
                    }
                }
            }
        }
        
        if allSettingsFixed {
            fixAllBtn.isEnabled = false
        }
    }
}
