//
//  AppDelegate.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/11/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true  // So clicking the red X in upper-left of window will terminate the app
    }

}

