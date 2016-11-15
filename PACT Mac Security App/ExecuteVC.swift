//
//  ExecuteVC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/13/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class ExecuteVC: NSViewController {

    @IBOutlet var statusTV: NSTextView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var executeBtn: NSButton!
    
    var outputPipe: Pipe!
    var lsTask: Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func lsBtnClicked(_ sender: NSButton) {
        //statusTV.string = statusTV.string! + "ls:\n"
        
        
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        
        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: "ls",ofType:"command") else {
                print("Unable to locate ls.command")
                return
            }
            

            self.lsTask = Process()
            self.lsTask.launchPath = path
            //self.lsTask.arguments = arguments
            
            //3.
            self.lsTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.executeBtn.isEnabled = true
                    self.spinner.stopAnimation(self)
                    //self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.lsTask)
            
            //4.
            self.lsTask.launch()
            
            //5.
            self.lsTask.waitUntilExit()
        }
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        //1.
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            //let output = self.outputPipe.fileHandleForReading.readDataToEndOfFile()
            
            
            //let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? "!!ZZ!!"
            
            //5.
            DispatchQueue.main.async(execute: {
                //let previousOutput = self.statusTV.string ?? ""
                let previousOutput = self.statusTV.string ?? "!!YY!!"
                let nextOutput = previousOutput + "\n" + outputString
                self.statusTV.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.statusTV.scrollRangeToVisible(range)
                
            })
            
            //6.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
    }

}
