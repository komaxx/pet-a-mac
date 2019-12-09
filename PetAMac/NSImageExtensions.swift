//
//  NSImageExtensions.swift
//  PetAMac
//
//  Created by Matthias Schicker on 29.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//
import Cocoa

extension NSImage {
    func imageWithTintColor(tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        NSMakeRect(0, 0, image.size.width, image.size.height).fill(using: NSCompositingOperation.sourceAtop)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}
