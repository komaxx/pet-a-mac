//
//  PopoverContentView.swift
//  PetAMac
//
//  Created by Matthias Schicker on 03.09.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//
import Cocoa

class PopoverContentView:NSView {
    var backgroundView:PopoverBackgroundView?
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let frameView = self.window?.contentView?.superview {
            if backgroundView == nil {
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSView.AutoresizingMask([.width, .height]);
                frameView.addSubview(backgroundView!, positioned: NSWindow.OrderingMode.below, relativeTo: frameView)
                
                let imageLayer = CALayer()
                imageLayer.contents = #imageLiteral(resourceName: "help_background")
                imageLayer.frame = backgroundView!.bounds
                backgroundView!.layer = imageLayer
            }
        }
    }
}

class PopoverBackgroundView:NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedRed: 64/255.0, green: 61/255.0, blue: 238/255.0, alpha: 1.0).set()
        self.bounds.fill()
    }
}
