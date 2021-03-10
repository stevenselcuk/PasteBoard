//
//  AppDelegate.swift
//  PasteBoard
//
//  Created by Steven J. Selcuk on 10.03.2021.
//

import Cocoa
import FinderSync
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // For first install, trigger Extensions screen
        FIFinderSyncController.showExtensionManagementInterface()
        // Terminate the application
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
