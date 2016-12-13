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

    // MARK: Scripts
    var scriptsDirPath: String = ""
    var scriptsToQuery = [String]()
    
    // MARK: Dictionaries
    var settingMetaDict = [String : SettingMeta]()
    var statusImgViewDict = [String : NSImageView]()
    var fixItBtnDict = [String : NSButton]()
    
    // MARK: Outlets
    @IBOutlet weak var settingsStackView: NSStackView!
    @IBOutlet weak var quitBtn: NSButton!
    @IBOutlet weak var fixAllBtn: NSButton!
    
    // MARK: - Initial Loading Functions
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
                        self.printLog(str: "ERROR: settingMeta[1] is not equal to 'root' or 'user'!")
                        continue  // to next iteration of for loop
                    }
                    guard settingMetaArr[2] == "root" || settingMetaArr[2] == "user" else {
                        self.printLog(str: "ERROR: settingMeta[2] is not equal to 'root' or 'user'!")
                        continue  // to next iteration of for loop
                    }
                    
                    // Add to dictionary
                    self.settingMetaDict[script] = SettingMeta(settingDescription: settingMetaArr[0], runPfUser: settingMetaArr[1] == "root" ? .Root : .User, runWUser: settingMetaArr[2] == "root" ? .Root : .User)
                }
            }
        }
        run(theseScripts: scriptsToQuery, withArgs: ["-settingMeta \(getCurrLangIso())"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
        
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
        refreshAllGuiViews()
        
        // Focus: Quit Button (spacebar), FixAll Button (Return key)
        self.view.window?.makeFirstResponder(quitBtn)
        fixAllBtn.keyEquivalent = "\r"
    }
    
    // MARK: IB Actions
    @IBAction func quitBtnClicked(_ sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
    
    func fixItBtnClicked(btn: NSButton) {
        let scriptToQuery = btn.identifier ?? ""
        if !scriptToQuery.isEmpty {
            if let settingMeta = settingMetaDict[scriptToQuery] {
                if settingMeta.runWUser == .Root {
                    run(theseScripts: [scriptToQuery], withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
                } else {  // .User
                    run(theseScripts: [scriptToQuery], withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
                }
                refreshAllGuiViews()
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
            run(theseScripts: allScriptsToQueryAsUserArr, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
            refreshAllGuiViews()  // do it here, so we can visually see the change before the Root PW dialog box pops up.
        }

        if allScriptsToQueryAsRootArr.count > 0 {
            run(theseScripts: allScriptsToQueryAsRootArr, withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
            refreshAllGuiViews()
        }
    }

    // MARK: Run Scripts
    // Note: This is the function the code is expected to call when wanting to run/query any script(s)
    func run(theseScripts: [String], withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withOutputHandler: ((_ outputDict: [String : String]) -> Void)?) {
        printLog(str: "----------")
        printLog(str: "runScripts: \(theseScripts), withArgs: \(withArgs), asUser: \(asUser), onThread: \(onThread)")
        
        if onThread == .Bg {
            let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            taskQueue.async {
                self.run(theseScripts: theseScripts, withArgs: withArgs, asUser: asUser, withOutputHandler: withOutputHandler)
            }
        } else {  // .Main
            run(theseScripts: theseScripts, withArgs: withArgs, asUser: asUser, withOutputHandler: withOutputHandler)
        }
    }
    
    // Note: could call this function directly, but it's more clear if called from: run(theseScriptsWithArgsAsUserOnThreadWithOutputHandler)
    func run(theseScripts: [String], withArgs: [String], asUser: RunScriptAs, withOutputHandler: ((_ outputDict: [String : String]) -> Void)?) {
        // Write AppleScript
        let allScriptsStr = theseScripts.joined(separator: " ")
        let argsStr = withArgs.joined(separator: " ")
        var appleScriptStr = "do shell script \"./runScripts.sh '\(argsStr)' \(allScriptsStr)\""
        if asUser == .Root {
            appleScriptStr += " with administrator privileges"
        }
        printLog(str: " appleScriptStr: \(appleScriptStr)")
        
        if let asObject = NSAppleScript(source: appleScriptStr) {
            // Run AppleScript
            var asError: NSDictionary?
            let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
            self.printLog(str: " [asOutput: \(asOutput.stringValue ?? "")]")
            
            // Parse & Handle AppleScript output
            let outputArr = self.parseAppleScript(asOutput: asOutput, asError: asError)
            handle(theseScripts: theseScripts, outputArr: outputArr, withOutputHandler: withOutputHandler)
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
    
    func handle(theseScripts: [String], outputArr: [String], withOutputHandler: ((_ outputDict: [String : String]) -> Void)?) {
        if let outputHandler = withOutputHandler {
            var outputDict = [String : String]()
            
            guard outputArr.count == theseScripts.count else {
                self.printLog(str: "*ERROR: outputArray.count (\(outputArr.count)) is not equal to scripts.count (\(theseScripts.count))")
                self.printLog(str: "*  outputArr: \(outputArr)")
                outputHandler(outputDict)
                return
            }
            
            var idx = 0
            for script in theseScripts {
                outputDict[script] = outputArr[idx]
                idx += 1
            }
            
            outputHandler(outputDict)
        }
    }
    
    // MARK: Misc
    func refreshAllGuiViews() {
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
            run(theseScripts: allScriptsToQueryAsUserArr, withArgs: ["-pf"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
            // Note: if want to run 1 at a time (so user can see a bit of animation)
            /*printLog(str: "====================")
            for script in allScriptsToQueryAsUserArr {
                run(theseScripts: [script], withArgs: ["-pf"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
            }
            printLog(str: "====================")*/
        }
        if allScriptsToQueryAsRootArr.count > 0 {
            run(theseScripts: allScriptsToQueryAsRootArr, withArgs: ["-pf"], asUser: .Root, onThread: .Main, withOutputHandler: outputHandler)
        }
    }
    
    func getCurrLangIso() -> String {
        let currLangArr = UserDefaults.standard.value(forKey: "AppleLanguages") as! [String]
        
        var currLangIso = currLangArr[0]
        
        // Chop off everything except 1st two characters
        currLangIso = currLangIso.substring(to: currLangIso.index(currLangIso.startIndex, offsetBy: 2))
        
        return currLangIso
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
}
