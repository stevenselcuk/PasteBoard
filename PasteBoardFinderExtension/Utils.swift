//
//  Utils.swift
//  PasteBoardFinderExtension
//
//  Created by Steven J. Selcuk on 10.03.2021.
//

import Cocoa

extension NSMenuItem {
    struct PasteBoardContext {
        static var pasteboardItem: String = ""
    }
    
    var pasteBoardContextItem: String {
        get {
            return PasteBoardContext.pasteboardItem
        }
        set(newValue) {
            PasteBoardContext.pasteboardItem = newValue
        }
    }
}

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }
    
    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard count > limit else { return self }
        
        switch position {
            case .head:
                return leader + suffix(limit)
            case .middle:
                let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
                
                let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
                
                return "\(prefix(headCharactersCount))\(leader)\(suffix(tailCharactersCount))"
            case .tail:
                return prefix(limit) + leader
        }
    }
}

