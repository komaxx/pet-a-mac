//
//  PurrPlayer.swift
//  PetAMac
//
//  Created by Matthias Schicker on 27.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import Cocoa
import AVKit

class PurrPlayer: NSObject {
    var purring : AVAudioPlayer?
    var screeching : AVAudioPlayer?
    var shaking : AVAudioPlayer?
    
    
    func updatePurring(purringLevel: Double){
        guard purringLevel > 0 else {
            if purring?.isPlaying ?? false {
                purring?.stop()
                purring = nil
                print("Purr player stopped")
            }
            return
        }
        
        createNewPurringPlayerIfNecessary()
        
        if !(purring?.isPlaying ?? true) {
            purring?.play()
        }
        
        purring?.volume = Float(purringLevel)
    }
    
    func screech(){
        let screechFiles = [ "screech_0.mp3", "screech_1.mp3" ]
        
        let path = Bundle.main.path(forResource: screechFiles[Int(drand48() * Double(screechFiles.count))], ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            screeching = try AVAudioPlayer(contentsOf: url)
            screeching?.play()
        } catch {
            screeching = nil
            print ("Could not make player for screeching file")
        }
    }
    
    func shake(){
        let screechFiles = [ "shake_0.mp3" ]
        
        let path = Bundle.main.path(forResource: screechFiles[Int(drand48() * Double(screechFiles.count))], ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            shaking = try AVAudioPlayer(contentsOf: url)
            shaking?.play()
        } catch {
            shaking = nil
            print ("Could not make player for shaking file")
        }
    }
    
    private func createNewPurringPlayerIfNecessary(){
        guard purring == nil else { return }
        
        let path = Bundle.main.path(forResource: "purr_0.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            purring = try AVAudioPlayer(contentsOf: url)
            purring?.volume = 0
            purring?.numberOfLoops = Int.max
            
            print("New purr player created")
        } catch {
            purring = nil
            print ("Could not make player for purr file")
        }
    }
}
