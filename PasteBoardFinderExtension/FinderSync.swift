//
//  FinderSync.swift
//  PasteBoardFinderExtension
//
//  Created by Steven J. Selcuk on 10.03.2021.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    var savedItems: [String] = []
    
    override init() {
        super.init()
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
        let pasteItems = NSPasteboard.general.pasteboardItems
        
        for case let pasteItem? in pasteItems ?? [] {
            if savedItems.count > 10 {
                savedItems.removeFirst(1)
            }
            savedItems.append(pasteItem.string(forType: .string)!)
        }
        
        for item in savedItems {
            let menuItem = NSMenuItem(title: "👉 " + item.truncated(limit: 30, position: .tail, leader: "..."), action: #selector(copyAction(_:)), keyEquivalent: "")
            menuItem.pasteBoardContextItem = item
            menu.addItem(menuItem)
        }
        
        if savedItems.count > 0 {
            menu.addItem(withTitle: "🧹 Clear Stash", action: #selector(clear(_:)), keyEquivalent: "")
        }
        
        return menu
    }
    
    @objc func clear(_ sender: AnyObject?) {
        savedItems = []
        NSPasteboard.general.clearContents()
    }
    
    @objc func copyAction(_ sender: NSMenuItem?) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sender!.pasteBoardContextItem, forType: NSPasteboard.PasteboardType.string)
        NSSound(named: "Pop")?.play()
    }
}
