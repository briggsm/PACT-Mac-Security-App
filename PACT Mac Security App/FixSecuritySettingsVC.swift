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
    //var runPfUser: String  // "root" or "user"
    //var runWUser: String  // "root" or "user"
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
            //let dTaskOutput = runTask(taskFilename: scriptToQuery, arguments: ["-d", getCurrLangIso()])  // -d => Get Description, Note: getCurrLangIso returns "en" or "tr" or "ru"
            //if dTaskOutput != "" {
            
            // Add to settingMetaDict. Continue loop if anything looks wrong.
            // -settingMeta => [AppName||runPfUser||runWUser]
            
            
            
            /*
            //let settingMetaTaskOutput = runTask(taskFilename: scriptToQuery, arguments: ["-settingMeta", getCurrLangIso()])
            if settingMetaTaskOutput != "" {
                let settingMetaArr = settingMetaTaskOutput.components(separatedBy: "||")
                
                // Sanity Checks
                guard settingMetaArr.count == 3 else {
                    printLog(str: "settingMetaArr.count is not equal to 3! Failing. Format for -settingMeta is e.g.: desc||user||root")
                    continue  // to next iteration of for loop
                }
                guard settingMetaArr[1] == "root" || settingMetaArr[1] == "user" else {
                    continue  // to next iteration of for loop
                }
                guard settingMetaArr[2] == "root" || settingMetaArr[2] == "user" else {
                    continue  // to next iteration of for loop
                }

                // Add to dictionary
                settingMetaDict[scriptToQuery] = SettingMeta(settingDescription: settingMetaArr[0], runPfUser: settingMetaArr[1], runWUser: settingMetaArr[2])
            }
            */
            
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
    
    /*
    func runTask(taskFilename: String, arguments: [String]) -> String {
        // Note: Purposely running in Main thread because it's not going take that long to run each of our tasks
        
        printLog(str: "runTask: \(taskFilename) \(arguments[0]) ", terminator: "")  // Finish this print statement at end of runTask() function

        // Make sure we can find the script file. Return if not.
        let settingNameArr = taskFilename.components(separatedBy: ".")
        guard let path = Bundle.main.path(forResource: "Scripts/" + settingNameArr[0], ofType:settingNameArr[1]) else {
            printLog(str: "\n  Unable to locate: \(taskFilename)!")
            return "Unable to locate: \(taskFilename)!"
        }
        
        // Init outputPipe
        let outputPipe = Pipe()
        
        // Setup & Launch our process
        let ps: Process = Process()
        ps.launchPath = path
        ps.arguments = arguments
        ps.standardOutput = outputPipe
        ps.launch()
        ps.waitUntilExit()

        // Read everything the outputPipe captured from stdout
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var outputString = String(data: data, encoding: String.Encoding.utf8) ?? ""
        outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Return the output
        printLog(str: " [output(runTask): \(outputString)]")
        return outputString
    }
    */
    
    func fixItBtnClicked(btn: NSButton) {
        let scriptToQuery = btn.identifier ?? ""
        if !scriptToQuery.isEmpty {
            if let settingMeta = settingMetaDict[scriptToQuery] {
                if settingMeta.runWUser == .Root {
                    //fixAsRoot(allFixItScriptsStr: scriptToQuery)
                    //queryAsRoot(allScriptsArr: [scriptToQuery], args: ["-w"])
                    run(scripts: [scriptToQuery], allAtOnce: true, withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
                } else {  // .User
                    //_ = runTask(taskFilename: scriptToQuery, arguments: ["-w"])
                    //run(scripts: [scriptToQuery], allAtOnce: true, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
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
        /*
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
        */
        if allScriptsToQueryAsUserArr.count > 0 {
            run(scripts: allScriptsToQueryAsUserArr, allAtOnce: true, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
            //run(scripts: allScriptsToQueryAsUserArr, allAtOnce: false, withArgs: ["-w"], asUser: .User, onThread: .Main, withOutputHandler: nil)
        }
        if allScriptsToQueryAsRootArr.count > 0 {
            run(scripts: allScriptsToQueryAsRootArr, allAtOnce: true, withArgs: ["-w"], asUser: .Root, onThread: .Main, withOutputHandler: nil)
        }
        
        updateAllStatusImagesAndFixItBtns()
        
        /*
        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView?, let scriptToQuery = statusImgView.identifier, let imgName = statusImgView.image?.name(), let settingMeta = settingMetaDict[scriptToQuery] {
                if !scriptToQuery.isEmpty {
                    if imgName != "greenCheck" {
                        if settingMeta.runWUser == .Root {
                            // "root", so append to list, to run all at once, later.
                            allFixItScriptsArr.append(scriptToQuery)
                        } else {  // .User
                            // "user", so run it right now
                            _ = runTask(taskFilename: scriptToQuery, arguments: ["-w"])
                        }
                    }
                }
            }
        }
        */
        
        /*
        //let allFixItScriptsStr = allFixItScriptsArr.joined(separator: " ")

        // Now run all the scripts which need "root"
        //fixAsRoot(allFixItScriptsStr: allFixItScriptsStr)
        queryAsRoot(allScriptsArr: allFixItScriptsArr, args: ["-w"])
        
        updateAllStatusImagesAndFixItBtns()
        */
        
        
    }
    /*
    func fixAsRoot(allFixItScriptsStr: String) {
        printLog(str: "----------")
        printLog(str: "fixAsRoot()")

        // Write AppleScript
        let appleScriptStr = "do shell script \"./runWs.sh \(allFixItScriptsStr)\" with administrator privileges"
        printLog(str: "appleScriptStr: \(appleScriptStr)")
        
        // Run AppleScript
        var asError: NSDictionary?
        if let asObject = NSAppleScript(source: appleScriptStr) {
            let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
            
            if let err = asError {
                printLog(str: "AppleScript Error: \(err)")
            } else {
                printLog(str: asOutput.stringValue ?? "Note!: AS Output has 'nil' for stringValue")
            }
        }
        printLog(str: "----------")
    }
    */
    
    /*
    func queryAsRoot(allScriptsArr: [String], args: [String]) -> [String : String]? {
        printLog(str: "----------")
        printLog(str: "queryAsRoot()")
        
        // Write AppleScript
        let allScriptsStr = allScriptsArr.joined(separator: " ")
        let argsStr = args.joined(separator: " ")
        let appleScriptStr = "do shell script \"./runAllAsRoot.sh '\(argsStr)' \(allScriptsStr)\" with administrator privileges"
        printLog(str: "appleScriptStr: \(appleScriptStr)")
        
        // Run AppleScript
        var asError: NSDictionary?
        if let asObject = NSAppleScript(source: appleScriptStr) {
            let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
            
            if let err = asError {
                printLog(str: "AppleScript Error: \(err)")
            } else {
                printLog(str: asOutput.stringValue ?? "Note!: AS Output has 'nil' for stringValue")
                
                // First tidy-up str a bit
                if let asOutputRaw = asOutput.stringValue {
                    var asOutputStr = asOutputRaw.replacingOccurrences(of: "\r\n", with: "\n") // just incase
                    asOutputStr = asOutputStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
                    
                    let asOutputArr = asOutputStr.components(separatedBy: "\n")
                    //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                    
                    var asOutputDict = [String : String]()
                    var idx = 0
                    for scriptToQuery in allScriptsArr {
                        asOutputDict[scriptToQuery] = asOutputArr[idx]
                        idx += 1
                    }
                    return asOutputDict

                    
//                    if asOutputArr.count >= allScriptsArr.count {
//                        for scriptToQuery in allScriptsArr {
//                            
//                        }
//                    }
                }
            }
        }
        printLog(str: "----------")
        return nil
    }
    */
    
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
        
        /*
        if allScriptsToQueryAsUserArr.count > 0 {
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
            run(scripts: allScriptsToQueryAsUserArr, withArgs: ["-pf"], asUser: .User, onThread: .Main, withOutputHandler: outputHandler)
        }
        if allScriptsToQueryAsRootArr.count > 0 {
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
            run(scripts: allScriptsToQueryAsRootArr, withArgs: ["-pf"], asUser: .Root, onThread: .Main, withOutputHandler: outputHandler)
        }
        */
        
        /*
        var allSettingsFixed = true
        
        // Iterate through all our entrys, updating the image views and buttons.
        for (scriptToQuery, statusImgView) in statusImgViewDict {
            if let fixItBtn = fixItBtnDict[scriptToQuery], let settingMeta = settingMetaDict[scriptToQuery] {
                if !scriptToQuery.isEmpty {
                    if settingMeta.runPfUser == "root" {
                        allScriptsToQueryAsRootArr.append(scriptToQuery)
                    } else {
                        // "user"
                        let pfTaskOutput = runTask(taskFilename: scriptToQuery, arguments: ["-pf"])  // -pf => Return "pass" or "fail" security test
                        
                        // Update statusImageView & fixItBtn
                        statusImgView.image = NSImage(named: getImgNameFor(pfString: pfTaskOutput))
                        fixItBtn.isHidden = pfTaskOutput == "pass"
                        
                        if pfTaskOutput != "pass" {
                            allSettingsFixed = false
                        }
                    }
                }
            }
        }
        
        if allScriptsToQueryAsRootArr.count > 0 {
            // Now run all the scripts which need "root"
            if let queryOutputDict = queryAsRoot(allScriptsArr: allScriptsToQueryAsRootArr, args: ["-pf"]) {
                // Update statusImageView & fixItBtn's for ALL scripts which were queried as root.
                for scriptToQuery in allScriptsToQueryAsRootArr {
                    if let statusImgView = statusImgViewDict[scriptToQuery], let fixItBtn = fixItBtnDict[scriptToQuery], let queryOutput = queryOutputDict[scriptToQuery] {
                        statusImgView.image = NSImage(named: getImgNameFor(pfString: queryOutput))
                        fixItBtn.isHidden = queryOutput == "pass"
                        
                        if queryOutput != "pass" {
                            allSettingsFixed = false
                        }
                    }
                }
            }
        }
        
        // If all settings are fixed, disable the "Fix All" button
        if allSettingsFixed {
            fixAllBtn.isEnabled = false
        }
        */
    }
    
    func getCurrLangIso() -> String {
        let currLangArr = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
        return currLangArr[0]
    }
    
    func langSelectionButtonsAlert() {

        var currLangPretty = ""
        var currLangIso = getCurrLangIso()
        
        // Chop off everything except 1st two characters
        currLangIso = currLangIso.substring(to: currLangIso.index(currLangIso.startIndex, offsetBy: 2))
        
        switch currLangIso {
        case "en":
            currLangPretty = "English"
        case "tr":
            currLangPretty = "Türkçe"
        case "ru":
            currLangPretty = "Русский"
        default:
            currLangPretty = currLangIso
        }

        let alert: NSAlert = NSAlert()
        alert.messageText = "Current Language: \(currLangPretty)\nMevcut dil: \(currLangPretty)\nтекущий язык: \(currLangPretty)"
        alert.informativeText = "If you choose a DIFFERENT language, this box will disappear and you must RESTART THE APP!\n\nBir FARKLI dili seçerseniz, bu kutu kaybolur ve UYGULAMAYI YENIDEN BAŞLATIN gerekir!\n\nЕсли вы выберите другой язык, это окно исчезнет, и вы должны перезапустить приложение!"
        alert.addButton(withTitle: "English")
        alert.addButton(withTitle: "Türkçe")
        alert.addButton(withTitle: "Русский")
       
        let res = alert.runModal()
        // Note on res: 1000 => 1st button (on far right), 1001 => 2nd button, 1002 => 3rd, etc
        switch res {
        case 1000:  // English
            if currLangIso != "en" {
                UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        case 1001:  // Turkish
            if currLangIso != "tr" {
                UserDefaults.standard.setValue(["tr"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        case 1002:  // Russian
            if currLangIso != "ru" {
                UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        default:
            // Shouldn't get here
            break
        }
    }
    
    func alertTooOldAndQuit(userOsVer: OperatingSystemVersion) {
        printLog(str: "OS Version is TOO OLD: \(userOsVer)")
        _ = osVerTooOldAlert(userOsVer: userOsVer)
        NSApplication.shared().terminate(self)  // Quit App no matter what.
    }
    
    func osVerTooOldAlert(userOsVer: OperatingSystemVersion) -> Bool {
        let alert: NSAlert = NSAlert()

        alert.messageText = NSLocalizedString("Operating System Outdated", comment: "os outdated")
        alert.informativeText = String.localizedStringWithFormat(NSLocalizedString("Your operating system is too old. It must first be updated to AT LEAST Yosemite (10.10) before this app will run. Your OS Version is: [%d.%d.%d]", comment: "os too old message"), userOsVer.majorVersion, userOsVer.minorVersion, userOsVer.patchVersion)
        
        alert.alertStyle = NSAlertStyle.informational
        alert.addButton(withTitle: NSLocalizedString("Quit", comment: ""))
        return alert.runModal() == NSAlertFirstButtonReturn
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
        guard let runWsPath = Bundle.main.path(forResource: "Scripts/runWs", ofType:"sh") else {
            printLog(str: "\n  Unable to locate: Scripts/runWs.sh!")
            return
        }
        
        scriptsDirPath = String(runWsPath.characters.dropLast(8))  // drop off: "runWs.sh"
        if FileManager.default.changeCurrentDirectoryPath(scriptsDirPath) {
            //printLog(str: "success changing dir to: \(scriptsDirPath)")
        } else {
            printLog(str: "failure changing dir to: \(scriptsDirPath)")
        }
    }
    
    func setupScriptsToQueryArray() {
        do {
            var scriptsDirContents = try FileManager.default.contentsOfDirectory(atPath: scriptsDirPath)

            // Remove "runWs.sh" from the list of scripts.
            if let index = scriptsDirContents.index(of: "runWs.sh") {
                scriptsDirContents.remove(at: index)
            }
            
            // Remove "runAllAsRoot.sh" from the list of scripts.
            if let index = scriptsDirContents.index(of: "runAllAsRoot.sh") {
                scriptsDirContents.remove(at: index)
            }
            
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
    
    //func run(scripts: [String], withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withTerminationHandler:@escaping (Process) -> Void) -> [String : String] {
    //func run(scripts: [String], withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread) -> [String : String] {
    //func run(scripts: [String], withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withOutputHandler: @escaping (_ outputDict: [String : String]) -> Void) {
    //func run(scripts: [String], allAtOnce: Bool, withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withOutputHandler: @escaping (_ outputDict: [String : String]) -> Void) {
    func run(scripts: [String], allAtOnce: Bool, withArgs: [String], asUser: RunScriptAs, onThread: RunScriptOnThread, withOutputHandler: ((_ outputDict: [String : String]) -> Void)?) {
        
        // Notes:
        //  If user is "Root", then "allAtOnce" is treated as TRUE, no matter what it's passed in value (because we never want to ask user their PW more than is necessary)
        
        printLog(str: "runScripts: \(scripts), allAtOnce: \(allAtOnce), withArgs: \(withArgs), asUser: \(asUser), onThread: \(onThread)")
        
        // From runTask:
        //printLog(str: "runTask: \(taskFilename) \(arguments[0]) ", terminator: "")  // Finish this print statement at end of runTask() function
        
        var outputDict = [String : String]()
        
        
        if asUser == .Root {
            
            // From queryAsRoot:
            // Write AppleScript
            let allScriptsStr = scripts.joined(separator: " ")
            let argsStr = withArgs.joined(separator: " ")
            let appleScriptStr = "do shell script \"./runAllAsRoot.sh '\(argsStr)' \(allScriptsStr)\" with administrator privileges"
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
                            //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                            var idx = 0
                            for script in scripts {
                                outputDict[script] = asOutputArr[idx]
                                idx += 1
                            }
                            
                            outputHandler(outputDict)
                        }
                        
                        /*
                        if let err = asError {
                            self.printLog(str: "AppleScript Error: \(err)")
                        } else {
                            self.printLog(str: asOutput.stringValue ?? "Note!: AS Output has 'nil' for stringValue")
                            
                            // First tidy-up str a bit
                            if let asOutputRaw = asOutput.stringValue {
                                var asOutputStr = asOutputRaw.replacingOccurrences(of: "\r\n", with: "\n") // just incase
                                asOutputStr = asOutputStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
                                
                                let asOutputArr = asOutputStr.components(separatedBy: "\n")
                                //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                                
                                //var asOutputDict = [String : String]()
                                var idx = 0
                                for script in scripts {
                                    //asOutputDict[script] = asOutputArr[idx]
                                    outputDict[script] = asOutputArr[idx]
                                    idx += 1
                                }
                                //return asOutputDict
                                withOutputHandler(outputDict)
                            }
                        }
                        */
                    
                    }

                } else {  // .Main
                    // Run AppleScript
                    
                    let asOutput: NSAppleEventDescriptor = asObject.executeAndReturnError(&asError)
                    printLog(str: " [asOutput(root,allAtOnce!,Main): \(asOutput.stringValue ?? "")]")
                    if let outputHandler = withOutputHandler {
                        // Parse & Handle AppleScript output
                        let asOutputArr = self.parseAppleScript(asOutput: asOutput, asError: asError)
                        //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                        
                        guard asOutputArr.count == scripts.count else {
                            self.printLog(str: "*ERROR: asOutputArray.count (\(asOutputArr.count)) is not equal to scripts.count (\(scripts.count))")
                            self.printLog(str: "*  asOutputArr: \(asOutputArr)")
                            return  // ??????????? Should we just return here ???????????
                        }
                        
                        var idx = 0
                        for script in scripts {
                            outputDict[script] = asOutputArr[idx]
                            idx += 1
                        }
                        
                        outputHandler(outputDict)
                    }
                    
                    
                    /*
                    if let err = asError {
                        printLog(str: "AppleScript Error: \(err)")
                    } else {
                        printLog(str: asOutput.stringValue ?? "Note!: AS Output has 'nil' for stringValue")
                        
                        // First tidy-up str a bit
                        if let asOutputRaw = asOutput.stringValue {
                            var asOutputStr = asOutputRaw.replacingOccurrences(of: "\r\n", with: "\n") // just incase
                            asOutputStr = asOutputStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
                            
                            let asOutputArr = asOutputStr.components(separatedBy: "\n")
                            //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                            
                            //var asOutputDict = [String : String]()
                            var idx = 0
                            for script in scripts {
                                //asOutputDict[script] = asOutputArr[idx]
                                outputDict[script] = asOutputArr[idx]
                                idx += 1
                            }
                            //return asOutputDict
                            withOutputHandler(outputDict)
                        }
                    }
                    */
                    
                }
            }
            
        } else {  // .User
            //printLog(str: ".User")
            if allAtOnce {
                //printLog(str: " .allAtOnce")
                //let allScriptsStr = scripts.joined(separator: " ")
                //let argsStr = withArgs.joined(separator: " ")
                //var allArgs = withArgs
                
                var allArgs = [String]()
                let withArgsStr = withArgs.joined(separator: " ")  // eg: ["-i", "en"]  ==>  "-i en"
                //allArgs.append("'\(withArgsStr)'")  // eg: '-i en'
                //allArgs.append("\(withArgsStr)")  // eg: '-i en'
                allArgs.append(withArgsStr)  // eg: '-i en'
                allArgs.append(contentsOf: scripts)  // eg: '-i en' abc.sh def.sh
                
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
                    //printLog(str: "  .Bg")
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
                                return  // ??????????? Should we just return here ???????????
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
                    //printLog(str: "  .Main")
                    ps.launch()
                    ps.waitUntilExit()
                    
                    // Read everything the outputPipe captured from stdout
                    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    var outputStr = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    outputStr = outputStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Return the output
                    printLog(str: " [output(user,allAtOnce,Main): \(outputStr)]")
                    
                    if let outputHandler = withOutputHandler {
                        let outputArr = outputStr.components(separatedBy: "\n")
                        
                        guard outputArr.count == scripts.count else {
                            printLog(str: "*ERROR: outputArray.count (\(outputArr.count)) is not equal to scripts.count (\(scripts.count))")
                            printLog(str: "*  outputArr: \(outputArr)")
                            return  // ??????????? Should we just return here ???????????
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
                        /*
                        //return "Unable to locate: \(script)!"
                        outputDict[script] = "Unable to locate: \(script)!"
                        //return outputDict
                        withOutputHandler(outputDict)
                        */
                        return
                    }
                    
//                    var allArgs = [String]()
//                    let withArgsStr = withArgs.joined(separator: " ")  // eg: ["-i", "en"]  ==>  "-i en"
//                    //allArgs.append("'\(withArgsStr)'")  // eg: '-i en'
//                    allArgs.append("\(withArgsStr)")  // eg: '-i en'

                    
                    // .User
                    // Init outputPipe
                    let outputPipe = Pipe()
                    
                    // Setup & Launch our process
                    let ps: Process = Process()
                    ps.launchPath = path
                    ps.arguments = withArgs
                    //ps.arguments = allArgs
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
                            //return outputString
                            //outputDict[script] = outputString  // Uh oh !!!!!!!!!!!!!!!!!!!!!
                            
                            //DispatchQueue.main.async(execute: {
                            /*
                            var bgOutputDict = [String : String]()
                            bgOutputDict[script] = outputString
                            
                            //self.handleBgThreadOutput(bgOutputDict: bgOutputDict, withArgs: withArgs)
                            withOutputHandler(bgOutputDict)
                            //return
                            */
                            
                            if let outputHandler = withOutputHandler {
                                outputDict[script] = outputString
                                outputHandler(outputDict)
                            }
                            //return
                            
                            //})
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
                            //outputDict[script] = outputString
                            //outputHandler(outputDict)
                            
                        }
                    }
                }
            }
        }
        
        //return outputDict
        //withOutputHandler(outputDict)
    }
    
    func parseAppleScript(asOutput: NSAppleEventDescriptor, asError: NSDictionary?) -> [String] {
        if let err = asError {
            printLog(str: "AppleScript Error: \(err)")
            //return ["AppleScript Error: \(err)"]
            return []
        } else {
            //self.printLog(str: asOutput.stringValue ?? "Note!: AS Output has 'nil' for stringValue")
            
            // First tidy-up str a bit
            if let asOutputRaw = asOutput.stringValue {
                var asOutputStr = asOutputRaw.replacingOccurrences(of: "\r\n", with: "\n") // just incase
                asOutputStr = asOutputStr.replacingOccurrences(of: "\r", with: "\n") // becasue AppleScript returns line endings with '\r'
                //printLog(str: " [asOutput(parse): \(asOutputStr)]")
                
                let asOutputArr = asOutputStr.components(separatedBy: "\n")
                //printLog(str: "asOutputArr.count: \(asOutputArr.count)")
                
                /*
                //var asOutputDict = [String : String]()
                var idx = 0
                for script in scripts {
                    //asOutputDict[script] = asOutputArr[idx]
                    outputDict[script] = asOutputArr[idx]
                    idx += 1
                }
                //return asOutputDict
                withOutputHandler(outputDict)
                */
                
                return asOutputArr
            }
        }
        
        return [""]
    }
    /*
    func handleBgThreadOutput(bgOutputDict: [String : String], withArgs: [String]) {
        DispatchQueue.main.async(execute: {
            for (script, bgOutput) in bgOutputDict {
     
            }
        })
    }
    */
}
