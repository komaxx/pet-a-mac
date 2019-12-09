//
//  ViewController.swift
//  PetAMac
//
//  Created by Matthias Schicker on 22.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import AppKit

class PetAViewController: NSViewController {
    @IBOutlet weak var helpButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func didTapHelpButton(_ sender: Any) {
//        let helpViewController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HelpViewController")) as! NSViewController
//        helpViewController.modal
        
        
//        let popOva = NSPopover()
//        popOva.behavior = .transient
//        popOva.contentViewController = HelpViewController()
//        popOva.contentSize = CGSize(width: 100, height: 100)
//        popOva.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: .maxX)
    }
}
