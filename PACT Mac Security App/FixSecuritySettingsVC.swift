//
//  FixSecuritySettingsVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

struct SettingMeta {
    var settingDescription: String
    var runPfUser: RunScriptAs
    var runWUser: RunScriptAs
}

enum RunScriptAs {
    case User
    case Root
}

enum RunScriptOnThread {
    case Main
    case Bg
}

class FixSecuritySettingsVC: NSViewController {

    var scriptsDirPath: String = ""
    var scriptsToQuery = [String]()
    
    @IBOutlet weak var settingsStackView: NSStackView!
    @IBOutlet weak var quitBtn: NSButton!
    @IBOutlet weak var fixAllBtn: NSButton!
    
    
    var settingMetaDict = [String : SettingMeta]()
    
    var statusImgViewDict = [String : NSImageView]()
    var fixItBtnDict = [String : NSButton]()
    
    override func loadView() {
        // Adding this function so older OS's (eg <=10.9) can still call our viewDidLoad() function
        // Seems this function is called for older OS's (eg 10.9) and newer ones as well (eg. 10.12)
        
        // Output Timestamp
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd HH:mm:ss"
        let timestamp = df.string(from: d)
        printLog(str: "=====================")
        printLog(str: "[" + timestamp + "]")
        printLog(str: "=====================")

        printLog(str: "loadView()")
        super.loadView()
        
        if floor(NSAppKitVersionNumber) <= Double(NSAppKitVersionNumber10_9) {  // This check is necessary, because even in 10.12 loadView() is called.
            printLog(str: "  calling self.viewDidLoad() from loadView()")
            self.viewDidLoad() // call viewDidLoad (added in 10.10)
        }
    }
    
    override func viewDidLoad() {
        printLog(str: "viewDidLoad()")
        if #available(OSX 10.10, *) {
            printLog(str: "  super.viewDidLoad()")
            super.viewDidLoad()
        } else {
            printLog(str: "  NOT calling super.viewDidLoad() [because 10.9 or lower is being used.")
            // No need to do anything here because 10.9 and older will have went through the loadView() function & that calls super.loadView()
        }
        
        // Delay a bit, THEN initEverything, so we can see the animation in the GUI.
        // Also makes it so Winodw is ALWAYS on top of other apps when starting the app.
        let deadlineTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.initEverything()
        }
    }
    
    func initEverything() {
        // Ask user their language preference
        performSegue(withIdentifier: "LanguageChooserVC", sender: self)
        
        // Change current directory to script's dir for rest of App's lifetime
        changeCurrentDirToScriptsDir()
        
        // Find all scripts/settings we need to query
        setupScriptsToQueryArray()
        
        // Re-center the window on the screen
        self.view.window?.center()
        
        // Add (Version Number) to title of Main GUI's Window
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let appVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
        self.view.window?.title = "\(appName) (v\(appVersion))"
        
        // Build the list of Security Settings for the Main GUI
        let outputHandler: ([String : String]) -> (Void) = { outputDict in
            for (script, output) in outputDict {
                if output != "" {
                    let settingMetaArr = output.components(separatedBy: "||")
                    
                    // Sanity Checks
                    guard settingMetaArr.count == 3 else {
                        self.printLog(str: "settingMetaArr.count (\(settingMetaArr.count)) is not equal to 3! Failing. Format for -settingMeta is e.g.: desc||user||root")
                        continue  // to next iteration of for loop
                    }
                    guard settingMetaArr[1] == "root" || settingMetaArr[1] == "user" else {
                        continue  // to next iteration of for loop
                    }
                    guard settingMetaArr[2] == "root" || settingMetaArr[2] == "user" else {
                        continue  // to next iteration of for loop
                    }
                    
                    // Add to dictionary
                    self.settingMetaDict[script] = SettingMeta(settingDescription: settingMetaArr[0], runPfUser: settingMetaArr[1] == "root" ? .Root : .User, runWUser: settingMetaArr[2] == "root" ? .Root : .User)
                }
            }
        }
        run(scripts: scriptsToQuery, allAtOnce: false, withArgs: ["-settingMeta \(getCurrLangIso())"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
        //run(scripts: scriptsToQuery, allAtOnce: true, withArgs: ["-settingMeta \(getCurrLangIso())"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
        
        for scriptToQuery in scriptsToQuery {
            if let settingMeta = settingMetaDict[scriptToQuery] {
                // Setup Status Image
                var statusImgView:NSImageView
                if #available(OSX 10.12, *) {
                    statusImgView = NSImageView(image: NSImage(named: "greyQM")!)
                } else {
                    // Fallback on earlier versions
                    statusImgView = NSImageView()
                    statusImgView.image = NSImage(named: "greyQM")
                    statusImgView.translatesAutoresizingMaskIntoConstraints = false  // NSStackView bug for 10.9 & 10.10
                }
                statusImgView.identifier = scriptToQuery
                statusImgViewDict[scriptToQuery] = statusImgView
                
                // Setup Setting Description Label
                var settingDescLabel:NSTextField
                if #available(OSX 10.12, *) {
                    settingDescLabel = NSTextField(labelWithString: settingMeta.settingDescription)
                } else {
                    // Fallback on earlier versions
                    settingDescLabel = NSTextField()
                    settingDescLabel.stringValue = settingMeta.settingDescription
                    settingDescLabel.isEditable = false
                    settingDescLabel.isSelectable = false
                    settingDescLabel.isBezeled = false
                    settingDescLabel.backgroundColor = NSColor.clear
                    settingDescLabel.translatesAutoresizingMaskIntoConstraints = false  // NSStackView bug for 10.9 & 10.10
                }
                
                // Setup FixIt Button
                var fixItBtn: NSButton
                if #available(OSX 10.12, *) {
                    fixItBtn = NSButton(title: NSLocalizedString("Fix It!", comment: "button text"), target: self, action: #selector(fixItBtnClicked))
                } else {
                    // Fallback on earlier versions
                    fixItBtn = NSButton()
                    fixItBtn.title = NSLocalizedString("Fix It!", comment: "button text")
                    fixItBtn.target = self
                    fixItBtn.action = #selector(fixItBtnClicked)
                    fixItBtn.bezelStyle = NSBezelStyle.rounded
                    fixItBtn.font = NSFont.systemFont(ofSize: 13.0)
                    fixItBtn.translatesAutoresizingMaskIntoConstraints = false  // NSStackView bug for 10.9 & 10.10
                }
                fixItBtn.identifier = scriptToQuery
                fixItBtnDict[scriptToQuery] = fixItBtn
                
                // Create Entry StackView
                let entryStackView = NSStackView()  // Default is Horizontal
                entryStackView.alignment = .centerY
                entryStackView.spacing = 10
                entryStackView.translatesAutoresizingMaskIntoConstraints = false  // NSStackView bug for 10.9 & 10.10
                
                // Add Image, Label, and Button to StackView
                entryStackView.addView(statusImgView, in: .leading)
                entryStackView.addView(settingDescLabel, in: .leading)
                entryStackView.addView(fixItBtn, in: .leading)
                
                // Add our entryStackView to the settingsStackView
                settingsStackView.addView(entryStackView, in: NSStackViewGravity.top)
                
                // Re-center the window on the screen
                self.view.window?.center()
            }
        }
        
        // Update all Status Images & FixIt Button visibilities.
        updateAllStatusImagesAndFixItBtns()
        
        // Focus: Quit Button (spacebar), FixAll Button (Return key)
        self.view.window?.makeFirstResponder(quitBtn)
        fixAllBtn.keyEquivalent = "\r"
    }
    
    @IBAction func quitBtnClicked(_ sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
    
    func getImgNameFor(pfString: String) -> String {
        if pfString == "pass" {
            return "greenCheck"
        } else if pfString == "fail" {
            return "redX"
        } else {
            // Unknow state. Shouldn't get here.
            return "greyQM"
        }
    }
    
    func fixItBtnClicked(btn: NSButton) {
        let scriptToQuery = btn.identifier ?? ""
        if !scriptToQuery.isEmpty {
            if let settingMeta = settingMetaDict[scriptToQuery] {
                if settingMeta.runWUser == .Root {
                    run(scripts: [scriptToQuery], allAtOnce: true, withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
                } else {  // .User
                    run(scripts: [scriptToQuery], allAtOnce: false, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
                }
                updateAllStatusImagesAndFixItBtns()
            }
        }
    }

    @IBAction func fixAllBtnClicked(_ sender: NSButton) {
        // Build list of all scripts which need to be queried
        var allScriptsToQueryAsRootArr = [String]()
        var allScriptsToQueryAsUserArr = [String]()
        
        for script in scriptsToQuery {
            if let settingMeta = settingMetaDict[script], let statusImgView = statusImgViewDict[script], let imgName = statusImgView.image?.name() {
                if imgName != "greenCheck" {
                    if settingMeta.runWUser == .Root {
                        allScriptsToQueryAsRootArr.append(script)
                    } else {  // .User
                        allScriptsToQueryAsUserArr.append(script)
                    }
                }
            }
        }

        if allScriptsToQueryAsUserArr.count > 0 {
            run(scripts: allScriptsToQueryAsUserArr, allAtOnce: true, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
            //run(scripts: allScriptsToQueryAsUserArr, allAtOnce: false, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
        }

        if allScriptsToQueryAsRootArr.count > 0 {
            run(scripts: allScriptsToQueryAsRootArr, allAtOnce: true, withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
        }
        
        updateAllStatusImagesAndFixItBtns()
    }

    func updateAllStatusImagesAndFixItBtns() {
        // Build list of all scripts which need to be queried
        var allScriptsToQueryAsRootArr = [String]()
        var allScriptsToQueryAsUserArr = [String]()
        
        for script in scriptsToQuery {
            if let settingMeta = settingMetaDict[script] {
                if settingMeta.runPfUser == .Root {
                    allScriptsToQueryAsRootArr.append(script)
                } else {  // .User
                    allScriptsToQueryAsUserArr.append(script)
                }
            }
        }
        
        let outputHandler: ([String : String]) -> (Void) = { outputDict in
            for (script, output) in outputDict {
                if output != "" {
                    // Update statusImageView & fixItBtn
                    if let statusImgView = self.statusImgViewDict[script], let fixItBtn = self.fixItBtnDict[script] {
                        statusImgView.image = NSImage(named: self.getImgNameFor(pfString: output))
                        fixItBtn.isHidden = output == "pass"
                    }
                }
            }
        }
        if allScriptsToQueryAsUserArr.count > 0 {
            run(scripts: allScriptsToQueryAsUserArr, allAtOnce: false, withArgs: ["-pf"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
            //run(scripts: allScriptsToQueryAsUserArr, allAtOnce: true, withArgs: ["-pf"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
        }
        if allScriptsToQueryAsRootArr.count > 0 {
            run(scripts: allScriptsToQueryAsRootArr, allAtOnce: true, withArgs: ["-pf"], asUser: .Root, onThread: .Main, withOutputHandler: outputHandler)
        }
    }
    
    func getCurrLangIso() -> String {
        let currLangArr = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
        return currLangArr[0]
    }
    
    func printLog(str: String) {
        printLog(str: str, terminator: "\n")
    }

    func printLog(str: String, terminator: String) {
    
        // First tidy-up str a bit
        var prettyStr = str.replacingOccurrences(of: "\r\n", with: "\n") // just incase
        prettyStr = prettyStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
        
        // Normal print
        print(prettyStr, terminator: terminator)
        
        // Print to log file
        if let cachesDirUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let logFilePathUrl = cachesDirUrl.appendingPathComponent("security-fixer-upper-log.txt")
            let logData = (prettyStr + terminator).data(using: .utf8, allowLossyConversion: false)!

            if FileManager.default.fileExists(atPath: logFilePathUrl.path) {
                do {
                    let logFileHandle = try FileHandle(forWritingTo: logFilePathUrl)
                    logFileHandle.seekToEndOfFile()
                    logFileHandle.write(logData)
                    logFileHandle.closeFile()
                } catch {
                    print("Unable to write to existing log file, at this path: \(logFilePathUrl.path)")
                }
            } else {
                do {
                    try logData.write(to: logFilePathUrl)
                } catch {
                    print("Can't write to new log file, at this path: \(logFilePathUrl.path)")
                }
            }
        }
    }
    
    func changeCurrentDirToScriptsDir() {
        guard let runScriptsPath = Bundle.main.path(forResource: "Scripts/runScripts", ofType:"sh") else {
            printLog(str: "\n  Unable to locate: Scripts/runScripts.sh!")
            return
        }
        
        scriptsDirPath = String(runScriptsPath.characters.dropLast(13))  // drop off: "runScripts.sh"
        if FileManager.default.changeCurrentDirectoryPath(scriptsDirPath) {
            //printLog(str: "success changing dir to: \(scriptsDirPath)")
        } else {
            printLog(str: "failure changing dir to: \(scriptsDirPath)")
        }
    }
    
    func setupScriptsToQueryArray() {
        do {
            var scriptsDirContents = try FileManager.default.contentsOfDirectory(atPath: scriptsDirPath)

            // Remove "runScripts.sh" from the list of scripts.
            if let index = scriptsDirContents.index(of: "runScripts.sh") {
                scriptsDirContents.remove(at: index)
            }

            scriptsToQuery = scriptsDirContents
        } catch {
            printLog(str: "Cannot get contents of Scripts dir: \(scriptsDirPath)")
            scriptsToQuery = []
        }
    }
    
    func run(scripts: [String], allAtOnce: Bool, withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withOutputHandler: ((_ outputDict: [String : String]) -> Void)?) {
        // Notes:
        //  If user is "Root", then "allAtOnce" is treated as TRUE, no matter what it's passed in value (because we never want to ask user their PW more than is necessary)
        
        printLog(str: "runScripts: \(scripts), allAtOnce: \(allAtOnce), withArgs: \(withArgs), asUser: \(asUser), onThread: \(onThread)")
        var outputDict = [String : String]()
        
        if asUser == .Root {
            // Write AppleScript
            let allScriptsStr = scripts.joined(separator: " ")
            let argsStr = withArgs.joined(separator: " ")
            let appleScriptStr = "do shell script \"./runScripts.sh '\(argsStr)' \(allScriptsStr)\" with administrator privileges"
            printLog(str: "appleScriptStr: \(appleScriptStr)")
            
            var asError: NSDictionary?
            if let asObject = NSAppleScript(source: appleScriptStr) {
                
                if onThread == .Bg {
                    let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                    taskQueue.async {
                        // Run AppleScript
                        let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
                        self.printLog(str: " [asOutput(root,allAtOnce!,Bg): \(asOutput.stringValue)]")

                        if let outputHandler = withOutputHandler {
                            // Parse & Handle AppleScript output
                            let asOutputArr = self.parseAppleScript(asOutput: asOutput, asError: asError)
                            
                            guard asOutputArr.count == scripts.count else {
                                self.printLog(str: "*ERROR: asOutputArray.count (\(asOutputArr.count)) is not equal to scripts.count (\(scripts.count))")
                                self.printLog(str: "*  asOutputArr: \(asOutputArr)")
                                return
                            }
                            
                            var idx = 0
                            for script in scripts {
                                outputDict[script] = asOutputArr[idx]
                                idx += 1
                            }
                            
                            outputHandler(outputDict)
                        }
                    }
                } else {  // .Main
                    // Run AppleScript
                    let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
                    printLog(str: " [asOutput(root,allAtOnce!,Main): \(asOutput.stringValue ?? "")]")
                    if let outputHandler = withOutputHandler {
                        // Parse & Handle AppleScript output
                        let asOutputArr = self.parseAppleScript(asOutput: asOutput, asError: asError)
                        
                        guard asOutputArr.count == scripts.count else {
                            self.printLog(str: "*ERROR: asOutputArray.count (\(asOutputArr.count)) is not equal to scripts.count (\(scripts.count))")
                            self.printLog(str: "*  asOutputArr: \(asOutputArr)")
                            return
                        }
                        
                        var idx = 0
                        for script in scripts {
                            outputDict[script] = asOutputArr[idx]
                            idx += 1
                        }
                        
                        outputHandler(outputDict)
                    }
                }
            }
        } else {  // .User
            if allAtOnce {
                var allArgs = [String]()
                let withArgsStr = withArgs.joined(separator: " ")
                allArgs.append(withArgsStr)
                allArgs.append(contentsOf: scripts)
                
                guard let path = Bundle.main.path(forResource: "Scripts/" + "runScripts", ofType:"sh") else {
                    printLog(str: "\n  Unable to locate: runScripts.sh!")
                    return
                }
                
                // Init outputPipe
                let outputPipe = Pipe()
                
                // Setup & Launch our process
                let ps: Process = Process()
                ps.launchPath = path
                ps.arguments = allArgs
                ps.standardOutput = outputPipe
                
                if onThread == .Bg {
                    // Setup & Launch our process Asynchronously
                    let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                    
                    taskQueue.async {
                        ps.launch()
                        ps.waitUntilExit()
                        
                        // Read everything the outputPipe captured from stdout
                        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        var outputStr = String(data: data, encoding: String.Encoding.utf8) ?? ""
                        outputStr = outputStr.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Return the output
                        self.printLog(str: " [output(user,allAtOnce,Bg): \(outputStr)]")
                        if let outputHandler = withOutputHandler {
                            let outputArr = outputStr.components(separatedBy: "\n")
                            
                            guard outputArr.count == scripts.count else {
                                self.printLog(str: "*ERROR: outputArray.count (\(outputArr.count)) is not equal to scripts.count (\(scripts.count))")
                                self.printLog(str: "*  outputArr: \(outputArr)")
                                return
                            }
                            
                            var idx = 0
                            for script in scripts {
                                outputDict[script] = outputArr[idx]
                                idx += 1
                            }
                        
                            outputHandler(outputDict)
                        }
                    }
                } else {  // .Main
                    ps.launch()
                    ps.waitUntilExit()
                    
                    // Read everything the outputPipe captured from stdout
                    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    var outputStr = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    outputStr = outputStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    printLog(str: " [output(user,allAtOnce,Main): \(outputStr)]")
                    
                    if let outputHandler = withOutputHandler {
                        let outputArr = outputStr.components(separatedBy: "\n")
                        
                        guard outputArr.count == scripts.count else {
                            printLog(str: "*ERROR: outputArray.count (\(outputArr.count)) is not equal to scripts.count (\(scripts.count))")
                            printLog(str: "*  outputArr: \(outputArr)")
                            return
                        }
                        
                        var idx = 0
                        for script in scripts {
                            outputDict[script] = outputArr[idx]
                            idx += 1
                        }
                    
                        outputHandler(outputDict)
                    }
                }
            } else {  // One at a time
                for script in scripts {
                    let scriptArr = script.components(separatedBy: ".")
                    guard let path = Bundle.main.path(forResource: "Scripts/" + scriptArr[0], ofType:scriptArr[1]) else {
                        printLog(str: "\n  Unable to locate: \(script)!")
                        return
                    }
                    
                    // .User
                    // Init outputPipe
                    let outputPipe = Pipe()
                    
                    // Setup & Launch our process
                    let ps: Process = Process()
                    ps.launchPath = path
                    ps.arguments = withArgs
                    ps.standardOutput = outputPipe
                    
                    if onThread == .Bg {
                        // Setup & Launch our process Asynchronously
                        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                        
                        taskQueue.async {
                            ps.launch()
                            ps.waitUntilExit()
                            
                            // Read everything the outputPipe captured from stdout
                            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                            var outputString = String(data: data, encoding: String.Encoding.utf8) ?? ""
                            outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Return the output
                            self.printLog(str: " [output(user,oneAtATime,Bg): \(outputString)]")
                            
                            if let outputHandler = withOutputHandler {
                                outputDict[script] = outputString
                                outputHandler(outputDict)
                            }
                        }
                    } else {  // .Main
                        ps.launch()
                        ps.waitUntilExit()
                        
                        // Read everything the outputPipe captured from stdout
                        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        var outputString = String(data: data, encoding: String.Encoding.utf8) ?? ""
                        outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Return the output
                        printLog(str: " [output(user,oneAtATime,Main): \(outputString)]")
                        if let outputHandler = withOutputHandler {
                            var currOutputDict = [String : String]()
                            currOutputDict[script] = outputString
                            outputHandler(currOutputDict)
                        }
                    }
                }
            }
        }
    }
    
    func parseAppleScript(asOutput: NSAppleEventDescriptor, asError: NSDictionary?) -> [String] {
        if let err = asError {
            printLog(str: "AppleScript Error: \(err)")
            return []
        } else {
            // First tidy-up str a bit
            if let asOutputRaw = asOutput.stringValue {
                var asOutputStr = asOutputRaw.replacingOccurrences(of: "\r\n", with: "\n") // just incase
                asOutputStr = asOutputStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
                let asOutputArr = asOutputStr.components(separatedBy: "\n")
                return asOutputArr
            }
        }
        
        return [""]
    }
}
