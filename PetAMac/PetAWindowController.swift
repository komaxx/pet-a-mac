//
//  WindowController.swift
//  PetAMac
//
//  Created by Matthias Schicker on 22.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import Cocoa

class PetAWindowController : NSWindowController {

    override func windowDidLoad() {
        self.window?.isOpaque = false
        self.window?.backgroundColor = NSColor.clear
    }
}
