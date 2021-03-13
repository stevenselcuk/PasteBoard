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
    var statusBarItem: NSStatusItem!
    let defaults = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!
    var timer: Timer!
    var savedItems: [String] = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!.stringArray(forKey: "SavedPasteBoardItems") ?? [String]()
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var selectedItemIndex: Int = 0
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Awesome menubar item. I love menubar apps. I am menubar app.
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

        if let button = statusBarItem.button {
            button.image = NSImage(named: "menubar-icon")
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
            //Finder Extension running we should sync them
            savedItems = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!.stringArray(forKey: "SavedPasteBoardItems")!
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount

                let pasteItems = self.pasteboard.pasteboardItems

                for case let pasteItem? in pasteItems ?? [] {
                    // I let only 10 items, IDK why
                    if self.savedItems.count >= 11 {
                        // If you reach 10, delete first one.
                        self.savedItems.removeFirst(1)
                    }

                    if !self.savedItems.contains(pasteItem.string(forType: .string)!) {
                        // Plop it baby
                        NSSound(named: "Pop")?.play()
                        self.savedItems.append(pasteItem.string(forType: .string)!.trimmingCharacters(in: .whitespacesAndNewlines))
                        defaults.set(self.savedItems, forKey: "SavedPasteBoardItems")
                        defaults.synchronize()
                    }
                }
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!

        // Catch click on our menubar
        if event.type == NSEvent.EventType.leftMouseUp {
            let menu = NSMenu()
            
            // Create menu items, in according with, sexy array
            for (index, item) in savedItems.enumerated().reversed() {
                let menuItem = NSMenuItem(title: item.truncated(limit: 40, position: .tail, leader: "..."), action: #selector(copyAction(_:)), keyEquivalent: "\(index + 1)")
                menu.addItem(menuItem)
            }
            
            menu.addItem(NSMenuItem.separator())
            if savedItems.count > 0 {
                menu.addItem(withTitle: "🧹 Clear PasteBoard", action: #selector(clear(_:)), keyEquivalent: "c")
            }
            
            // Promote our awesome Finder Extension
            menu.addItem(withTitle: "Activate Finder Extension", action: #selector(activateExt), keyEquivalent: "e")
            // Obviously users can quit app
            menu.addItem(withTitle: "Quit App", action: #selector(quit), keyEquivalent: "q")
            
            statusBarItem.menu = menu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil
        }
    }

    @objc func activateExt(_ sender: AnyObject?) {
        // Trigger Ext. section of settings
        FIFinderSyncController.showExtensionManagementInterface()
    }
    
    // Same as Finder Extension
    @objc func clear(_ sender: AnyObject?) {
        savedItems = []
        NSPasteboard.general.clearContents()
        defaults.set(self.savedItems, forKey: "SavedPasteBoardItems")
        defaults.synchronize()
    }

    @objc func copyAction(_ sender: NSMenuItem?) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        selectedItemIndex = Int(sender!.keyEquivalent)!
        if self.savedItems.count >= selectedItemIndex  {
            pasteboard.setString(self.savedItems[selectedItemIndex - 1], forType: NSPasteboard.PasteboardType.string)
        }
        NSSound(named: "Pop")?.play()
    }

    @objc func quit() {
        NSApp.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
    }
}
