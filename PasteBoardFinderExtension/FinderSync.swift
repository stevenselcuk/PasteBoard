//
//  FinderSync.swift
//  PasteBoardFinderExtension
//
//  Created by Steven J. Selcuk on 10.03.2021.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    // App groups. We like it.
    let defaults = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!
    var timer: Timer!
    var savedItems: [String] = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!.stringArray(forKey: "SavedPasteBoardItems") ?? [String]()
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var selectedItemIndex: Int = 0

    override init() {
        super.init()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            // Check if menubar app running, if yes sync Finder extension
            if (NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "org.tabbycatllc.PasteBoard" }) {
                savedItems = UserDefaults(suiteName: "group.org.tabbycatllc.PasteBoard")!.stringArray(forKey: "SavedPasteBoardItems")!
            } else {
                // Otherwise user wants to run extension as standalone app.
                // Our classic tactic is here
                if self.lastChangeCount != self.pasteboard.changeCount {
                    self.lastChangeCount = self.pasteboard.changeCount

                    let pasteItems = self.pasteboard.pasteboardItems

                    for case let pasteItem? in pasteItems ?? [] {
                        if self.savedItems.count >= 11 {
                            self.savedItems.removeFirst(1)
                        }

                        if !self.savedItems.contains(pasteItem.string(forType: .string)!) {
                            // Plop sound when something copied
                            NSSound(named: "Pop")?.play()
                            // Add copied text to our sexy array
                            self.savedItems.append(pasteItem.string(forType: .string)!.trimmingCharacters(in: .whitespacesAndNewlines))
                            // Save it universal storage
                            defaults.set(self.savedItems, forKey: "SavedPasteBoardItems")
                            defaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    // This things for toolbars
    override var toolbarItemName: String {
        return "PasteBoard"
    }

    // This things for toolbars, show only on hover
    override var toolbarItemToolTip: String {
        return "PasteBoard: Right in your toolbar"
    }

    // Our nice icon for toolbar
    override var toolbarItemImage: NSImage {
        return NSImage(named: "toolbar-icon")!
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        // Get current pasteboard items
        for item in savedItems.reversed() {
            // Create menu items
            let menuItem = NSMenuItem(title: item.truncated(limit: 30, position: .tail, leader: "..."), action: #selector(copyAction(_:)), keyEquivalent: "")
            // Add them to our menu object
            menu.addItem(menuItem)
        }

        // No item, no need to clear
        if savedItems.count > 0 {
            // Run clear func
            menu.addItem(withTitle: "🧹 Clear PasteBoard", action: #selector(clear(_:)), keyEquivalent: "")
        } else {
            // Create menu item
            let disabledMenuItem = NSMenuItem(title: "No items found.", action: nil, keyEquivalent: "")
            // Than disable it
            disabledMenuItem.isEnabled = false
            // After than register it
            menu.addItem(disabledMenuItem)
        }

        // Return it
        return menu
    }

    @objc func clear(_ sender: AnyObject?) {
        // Zero items in sexy array
        savedItems = []
        // Clear macOS pasteboard
        NSPasteboard.general.clearContents()
        // Zero saved items in defaults
        defaults.set(savedItems, forKey: "SavedPasteBoardItems")
        // Sync it
        defaults.synchronize()
    }

    @objc func copyAction(_ sender: NSMenuItem?) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        // We are using key equi thing as index number. But it's text. damn.
        selectedItemIndex = Int(sender!.keyEquivalent)!
        // We found which item user wants
        // Unnecassary check but
        if savedItems.count >= selectedItemIndex {
            // Save it to clipboard
            pasteboard.setString(savedItems[selectedItemIndex - 1], forType: NSPasteboard.PasteboardType.string)
        }
        // A plop again
        NSSound(named: "Pop")?.play()
    }
}
