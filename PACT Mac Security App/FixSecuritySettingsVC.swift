//
//  FixSecuritySettingsVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FixSecuritySettingsVC: NSViewController {

    let settingsToQuery = [
        "autologindisabled.sh",
        "autoupdatesoftware.sh",
        "bluetoothsharing.sh",
        "ds_store.sh",
        "firewallenabled.sh",
        "firewallstealth.sh",
        "guestaccount.sh",
        "networkguestshared.sh",
        "remotedesktopmanagement.sh",
        "screensaver5sec.sh",
        "screensaver10min.sh"
    ]
    
    @IBOutlet weak var settingsStackView: NSStackView!
    @IBOutlet weak var fixAllBtn: NSButton!
    
    override func viewDidAppear() {
        // Add (Version Number) to title of Main GUI's Window
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let appVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
        self.view.window?.title = "\(appName) (v\(appVersion))"
        
        // Ask user their language preference
        //setGuiLanguage(langInt: langSelectionButtonsAlert())
        langSelectionButtonsAlert()
        
        // Make sure user's OS is Mountain Lion or higher. Mountain Lion (10.8.x) [12.x.x]. If not, tell user & Quit App.
        let minReqOsVer = OperatingSystemVersion(majorVersion: 10, minorVersion: 8, patchVersion: 0)
        let userOsVer = ProcessInfo().operatingSystemVersion
        
        if !ProcessInfo().isOperatingSystemAtLeast(minReqOsVer) {
            _ = osVerTooOldAlert(userOsVer: userOsVer)
            NSApplication.shared().terminate(self)  // Quit App no matter what.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Output Timestamp
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss"
        let timestamp = df.string(from: d)
        printLog(str: "=====================")
        printLog(str: "[" + timestamp + "]")
        printLog(str: "=====================")
        
        // Build the list of Security Settings for the Main GUI
        for settingToQuery in settingsToQuery {
            
            let aTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-a"])  // -a => Applicable given user's OS Version.
            if aTaskOutput == "true" {

                // Setup Status Image
                let statusImgView = NSImageView(image: NSImage(named: "greyQM")!)
                statusImgView.identifier = settingToQuery
                
                // Setup Setting Description Label
                let dTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-d", getCurrLangIso()])  // -d => Get Description, getCurrLangIso returns "en" or "tr" or "ru"
                let settingDescLabel = NSTextField(labelWithString: dTaskOutput)

                // Setup FixIt Button
                let fixItBtn = NSButton(title: NSLocalizedString("Fix It!", comment: "button text"), target: self, action: #selector(fixItBtnClicked))
                fixItBtn.identifier = settingToQuery
                
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
            }
        }
        
        // Update all Status Images & FixIt Button visibilities.
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
        // Note: Running in Main thread because it's not going take long at all (if it does, something is majorly wrong).
        
        printLog(str: "runTask: \(taskFilename) \(arguments[0]) ", terminator: "")  // Finish this print statement at end of runTask() function

        // Make sure we can find the script file. Return if not.
        let settingNameArr = taskFilename.components(separatedBy: ".")
        guard let path = Bundle.main.path(forResource: settingNameArr[0], ofType:settingNameArr[1]) else {
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
        let settingToQuery = btn.identifier ?? ""
        if !settingToQuery.isEmpty {
            //_ = runTask(taskFilename: settingToQuery, arguments: ["-w"])  // -w => Write Setting
            
            fixAsRoot(allFixItScriptsStr: settingToQuery)

            updateAllStatusImagesAndFixItBtns()
        }
    }

    @IBAction func fixAllBtnClicked(_ sender: NSButton) {
        // Build list of all scripts which need to be fixed
        var allFixItScriptsArr = Array<String>()

        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView? {
                let settingToQuery = statusImgView.identifier ?? ""
                if !settingToQuery.isEmpty {
                    if let imgName = statusImgView.image?.name() {
                        if imgName != "greenCheck" {
                            allFixItScriptsArr.append(settingToQuery)
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
        printLog(str: "-----")
        
        printLog(str: "fixAsRoot - allFixItScriptsStr: \(allFixItScriptsStr)")
        
        
        
        
//        let currDir = FileManager.default.currentDirectoryPath
//        printLog(str: "currDir: \(currDir)")
        
        
//        // Change directory
//        let filemgr = FileManager.default
//        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
//        let docsDir = dirPaths[0].path
//        if filemgr.changeCurrentDirectoryPath(docsDir) {
//            // Success
//            printLog(str: "success")
//        } else {
//            // Failure
//            printLog(str: "failure")
//        }
//        let currDir2 = FileManager.default.currentDirectoryPath
//        printLog(str: "currDir2: \(currDir2)")

        
        guard let runWsPath = Bundle.main.path(forResource: "runWs", ofType:"sh") else {
            printLog(str: "\n  Unable to locate: runWs.sh!")
            return
        }
        //printLog(str: "runWsPath: \(runWsPath)")

        let resourcesPath = String(runWsPath.characters.dropLast(8))
        if FileManager.default.changeCurrentDirectoryPath(resourcesPath) {
            //printLog(str: "success changing dir to: \(resourcesPath)")
        } else {
            printLog(str: "failure changing dir to: \(resourcesPath)")
        }
        
//        let currDir2b = FileManager.default.currentDirectoryPath
//        printLog(str: "currDir2b: \(currDir2b)")
        
        
        
        /*
        //let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            //let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: currDir)
            printLog(str: "currDirContents: \(directoryContents.description)")
//            directoryContents = try FileManager.default.contentsOfDirectory(atPath: docsDir)
//            printLog(str: "docsDir: \(directoryContents.description)")
            
//            // if you want to filter the directory contents you can do like this:
//            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
//            print("mp3 urls:",mp3Files)
//            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
//            print("mp3 list:", mp3FileNames)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        */
        
        
        // Write AppleScript
        let appleScriptStr =
            "tell application \"Finder\"\n" +
            "   set myPath to container of (path to me) as string\n" +
            "end tell\n" +
            //"do shell script (quoted form of (POSIX path of myPath)) & \"Security-Fixer-Upper.app/Contents/Resources/runWs.sh \(allFixItScriptsStr)\" with administrator privileges"
            "do shell script \"./runWs.sh \(allFixItScriptsStr)\" with administrator privileges"
        
        // Run AppleScript
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScriptStr) {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            
            if let err = error {
                printLog(str: "AS Error: \(err)")
            } else {
                printLog(str: output.stringValue ?? "Note!: AS Output has no stringValue")
            }
        }
        printLog(str: "----------")
    }
    
    func updateAllStatusImagesAndFixItBtns() {
        var allSettingsFixed = true
        
        // Iterate through all our entryStackViews, finding the image views and buttons.
        for entryStackView in settingsStackView.views as! [NSStackView] {
            if let statusImgView = entryStackView.views.first as! NSImageView? , let fixItBtn = entryStackView.views.last as! NSButton? {
                let settingToQuery = statusImgView.identifier ?? ""
                if !settingToQuery.isEmpty {
                    let pfTaskOutput = runTask(taskFilename: settingToQuery, arguments: ["-pf"])  // -pf => Return "pass" or "fail" security test
                    
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
            //let data = strLog.data(using: String.Encoding.utf8, allowLossyConversion: false)!

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
}
