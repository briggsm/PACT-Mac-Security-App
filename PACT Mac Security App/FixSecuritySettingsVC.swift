//
//  FixSecuritySettingsVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FixSecuritySettingsVC: NSViewController {

    var scriptsDirPath: String = ""
    var scriptsToQuery = Array<String>()
    
    @IBOutlet weak var settingsStackView: NSStackView!
    @IBOutlet weak var fixAllBtn: NSButton!
    
    override func viewDidAppear() {
        // Make sure user's OS is Mountain Lion or higher. Mountain Lion (10.8.x) [12.x.x]. If not, tell user & Quit App.
        let minReqOsVer = OperatingSystemVersion(majorVersion: 10, minorVersion: 8, patchVersion: 0)
        let userOsVer = ProcessInfo().operatingSystemVersion
        if !ProcessInfo().isOperatingSystemAtLeast(minReqOsVer) {
            _ = osVerTooOldAlert(userOsVer: userOsVer)
            NSApplication.shared().terminate(self)  // Quit App no matter what.
        }
        
        // Add (Version Number) to title of Main GUI's Window
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let appVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
        self.view.window?.title = "\(appName) (v\(appVersion))"

        // Bring window to front of all other windows, right now (including Xcode)
        //NSApp.activate(ignoringOtherApps: true)  // Doesn't seem to bring to front when loading...
        //NSApplication.shared().activate(ignoringOtherApps: true)
        //self.view.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        //self.view.window?.level = Int(CGWindowLevelForKey(.maximumWindow))  // But this even puts it over the dialog box!
        self.view.window?.level = Int(CGWindowLevelForKey(.floatingWindow))  // This forces window to ALWAYS be on top, even if don't want
        
        // Build the list of Security Settings for the Main GUI
        for scriptToQuery in scriptsToQuery {
            let dTaskOutput = runTask(taskFilename: scriptToQuery, arguments: ["-d", getCurrLangIso()])  // -d => Get Description, Note: getCurrLangIso returns "en" or "tr" or "ru"
            if dTaskOutput != "" {
                // Setup Status Image
                let statusImgView = NSImageView(image: NSImage(named: "greyQM")!)
                statusImgView.identifier = scriptToQuery
                
                // Setup Setting Description Label
                let settingDescLabel = NSTextField(labelWithString: dTaskOutput)
                
                // Setup FixIt Button
                let fixItBtn = NSButton(title: NSLocalizedString("Fix It!", comment: "button text"), target: self, action: #selector(fixItBtnClicked))
                fixItBtn.identifier = scriptToQuery
                
                // Create StackView
                let entryStackView = NSStackView()  // Default is Horizontal
                entryStackView.alignment = .centerY
                entryStackView.spacing = 10
                entryStackView.distribution = .gravityAreas
                
                // Add Image, Label, and Button to StackView
                entryStackView.addView(statusImgView, in: .leading)
                entryStackView.addView(settingDescLabel, in: .leading)
                entryStackView.addView(fixItBtn, in: .leading)
                
                // Add our entryStackView to the settingsStackView
                settingsStackView.addView(entryStackView, in: NSStackViewGravity.top)
                
                // Force window update, so we can see it doing something
                //self.view.window?.update()
                //NSApplication.shared().updateWindows()
            }
        }
        
        // Update all Status Images & FixIt Button visibilities.
        updateAllStatusImagesAndFixItBtns()
        
        
        // Ask user their language preference
        langSelectionButtonsAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change current directory to script's dir for rest of App's lifetime
        changeCurrentDirToScriptsDir()
        
        // Find all scripts/settings we need to query
        setupScriptsToQueryArray()
        
        // Output Timestamp
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd HH:mm:ss"
        let timestamp = df.string(from: d)
        printLog(str: "=====================")
        printLog(str: "[" + timestamp + "]")
        printLog(str: "=====================")
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
        printLog(str: "[output: \(outputString)]")
        return outputString
    }
    
    func fixItBtnClicked(btn: NSButton) {
        let scriptToQuery = btn.identifier ?? ""
        if !scriptToQuery.isEmpty {
            //_ = runTask(taskFilename: scriptToQuery, arguments: ["-w"])  // -w => Write Setting
            
            fixAsRoot(allFixItScriptsStr: scriptToQuery)

            updateAllStatusImagesAndFixItBtns()
        }
    }

    @IBAction func fixAllBtnClicked(_ sender: NSButton) {
        // Build list of all scripts which need to be fixed
        var allFixItScriptsArr = Array<String>()

        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView? {
                let scriptToQuery = statusImgView.identifier ?? ""
                if !scriptToQuery.isEmpty {
                    if let imgName = statusImgView.image?.name() {
                        if imgName != "greenCheck" {
                            allFixItScriptsArr.append(scriptToQuery)
                        }
                    }
                }
            }
        }
        
        let allFixItScriptsStr = allFixItScriptsArr.joined(separator: " ")

        // Fix all these scripts with admin priv.
        fixAsRoot(allFixItScriptsStr: allFixItScriptsStr)
        
        updateAllStatusImagesAndFixItBtns()
    }
    
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
    
    func updateAllStatusImagesAndFixItBtns() {
        var allSettingsFixed = true
        
        // Iterate through all our entryStackViews, finding the image views and buttons.
        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView? , let fixItBtn = entryStackView.views.last as! NSButton? {
                let scriptToQuery = statusImgView.identifier ?? ""
                if !scriptToQuery.isEmpty {
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
        
        // If all settings are fixed, disable the "Fix All" button
        if allSettingsFixed {
            fixAllBtn.isEnabled = false
        }
    }
    
    func getCurrLangIso() -> String {
        let currLangArr = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
        return currLangArr[0]
    }
    
    func langSelectionButtonsAlert() {

        var currLangPretty = ""
        switch getCurrLangIso() {
        case "en":
            currLangPretty = "English"
        case "tr":
            currLangPretty = "Türkçe"
        case "ru":
            currLangPretty = "Русский"
        default:
            currLangPretty = getCurrLangIso()
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
            if getCurrLangIso() != "en" {
                UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        case 1001:  // Turkish
            if getCurrLangIso() != "tr" {
                UserDefaults.standard.setValue(["tr"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        case 1002:  // Russian
            if getCurrLangIso() != "ru" {
                UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                NSApplication.shared().terminate(self)
            }
        default:
            // Shouldn't get here
            break
        }
    }
    
    func osVerTooOldAlert(userOsVer: OperatingSystemVersion) -> Bool {
        let alert: NSAlert = NSAlert()

        alert.messageText = NSLocalizedString("Operating System Outdated", comment: "os outdated")
        alert.informativeText = String.localizedStringWithFormat(NSLocalizedString("Your operating system is too old. It must first be updated to AT LEAST Mountain Lion (10.8) before this app will run. Your OS Version is: [%d.%d.%d]", comment: "os too old message"), userOsVer.majorVersion, userOsVer.minorVersion, userOsVer.patchVersion)
        
        alert.alertStyle = NSAlertStyle.informational
        alert.addButton(withTitle: NSLocalizedString("Quit", comment: ""))
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    func printLog(str: String) {
        printLog(str: str, terminator: "\n")
    }

    func printLog(str: String, terminator: String) {
    
        // First tidy-up string a bit
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
        //printLog(str: "runWsPath: \(runWsPath)")
        
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
            
            //printLog(str: "scriptsDirContents: \(scriptsDirContents.description)")

            scriptsToQuery = scriptsDirContents
        } catch {
            printLog(str: "Cannot get contents of Scripts dir: \(scriptsDirPath)")
            //scriptsToQuery = [""]
        }
    }
}
