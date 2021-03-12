//
//  FinderSync.swift
//  PasteBoardFinderExtension
//
//  Created by Steven J. Selcuk on 10.03.2021.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    let defaults = UserDefaults.standard
    var timer: Timer!
    var savedItems: [String] = UserDefaults.standard.stringArray(forKey: "SavedPasteBoardItems") ?? [String]()
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var selectedItemIndex: Int = 0
    
    override init() {
        super.init()
        if(!NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "org.tabbycatllc.PasteBoard" }) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
                if self.lastChangeCount != self.pasteboard.changeCount {
                    self.lastChangeCount = self.pasteboard.changeCount
                    
                    let pasteItems = self.pasteboard.pasteboardItems
                    
                    for case let pasteItem? in pasteItems ?? [] {
                        if self.savedItems.count >= 11 {
                            self.savedItems.removeFirst(1)
                        }
                        
                        if !self.savedItems.contains(pasteItem.string(forType: .string)!) {
                            self.savedItems.append(pasteItem.string(forType: .string)!.trimmingCharacters(in: .whitespacesAndNewlines))
                            defaults.set(self.savedItems, forKey: "SavedPasteBoardItems")
                        }
                    }
                }
            }
        }

    }
    
    override var toolbarItemName: String {
        return "PasteBoard"
    }
    
    override var toolbarItemToolTip: String {
        return "PasteBoard: Right in your toolbar"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "toolbar-icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        for item in savedItems.reversed() {
            let menuItem = NSMenuItem(title: item.truncated(limit: 30, position: .tail, leader: "..."), action: #selector(copyAction(_:)), keyEquivalent: "")
            menuItem.pasteBoardContextItem = item
            menu.addItem(menuItem)
        }
        
        if savedItems.count > 0 {
            menu.addItem(withTitle: "🧹 Clear PasteBoard", action: #selector(clear(_:)), keyEquivalent: "")
        }
        
        return menu
    }
    
    @objc func clear(_ sender: AnyObject?) {
        savedItems = []
        NSPasteboard.general.clearContents()
        defaults.set(self.savedItems, forKey: "SavedPasteBoardItems")
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
}
