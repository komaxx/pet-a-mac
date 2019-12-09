//
//  Mood.swift
//  PetAMac
//
//  Created by Matthias Schicker on 24.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import Cocoa

class Mood {
    let screechDuration : TimeInterval = 1
    let screechThreshold = -0.9
    
    public private(set) var mood : Double = 0
    public private(set) var awakeness : Double = 0
    
    public var furView : FurView!
    public let fur = Fur()
    let purrPlayer = PurrPlayer()
    
    var shakeStart = Date.distantFuture
    var screechStart = Date.distantFuture
    
    var petting = false
    var bothering = false

    
    init(){
        // nothing yet
    }
    
    func getFace() -> NSImage {
        if !isAwake() {
            return awakeness < 0.5 ? #imageLiteral(resourceName: "face_sleep") : #imageLiteral(resourceName: "face_sleepy")
        }
        if isScreeching() { return #imageLiteral(resourceName: "face_mad") }
        
        if mood >= 0.9 { return #imageLiteral(resourceName: "face_ecstatic") }
        if mood > 0.5 { return #imageLiteral(resourceName: "face_happy") }
        if petting { return #imageLiteral(resourceName: "face_happy") }
        
        if mood < -0.4 || bothering { return #imageLiteral(resourceName: "face_irritated") }
        
        return #imageLiteral(resourceName: "face_awake")
    }
    
    func tick() -> Bool {
        let furChanged = self.fur.tick(timeDelta: 0.03)
        
        updateSleepiness()
        updateMood()
        updatePurr()
        shakeIfTimeReached()
        screechIfMoodReached()
        return furChanged
    }
    
    func updateSleepiness(){
        awakeness = awakeness * 0.998
    }
    
    func isAwake() -> Bool {
        return awakeness >= 1
    }
    
    func updateMood(){
        guard isAwake() else {
            return
        }
        
        if !isScreeching(){
            if petting {
                mood += 0.007
                mood = min(1.5, mood)
            } else if bothering {
                mood -= 0.015
            }
        }
        
        mood = mood * 0.995
        if abs(mood) < 0.0001 {
            mood = 0
        }

        // print("mood: \(mood)")
    }
    
    func screechIfMoodReached(){
        if !isScreeching() && mood < screechThreshold {
            screech()
        }
    }
    
    func updatePurr(){
        let minPurrMood = 0.4
        let maxPurrMood = 0.9
        
        let purr = (max(minPurrMood, min(maxPurrMood, mood)) - minPurrMood) / (maxPurrMood - minPurrMood)
        purrPlayer.updatePurring(purringLevel: purr)
    }
    
    func interaction(x : CGFloat, lastX : CGFloat){
        awakeness += 0.007
        awakeness = min(5, awakeness)

        updateFurFromInteraction(x: x, lastX: lastX)

        guard isAwake() else {
            shakeStart = Date.distantFuture
            return
        }
        guard !isScreeching() else {
            return
        }

        scheduleShake()
        updateMoodChangeRateInteraction(x: x, lastX: lastX)
    }
    
    func interactionFinished(){
        petting = false
        bothering = false
    }
    
    func shakeIfTimeReached() {
        if Date().timeIntervalSince(shakeStart) > 0 {
            shakeStart = Date.distantFuture
            if isAwake(){
                purrPlayer.shake()
                furView.shake()
            }
        }
    }
    
    func scheduleShake(){
        shakeStart = Date().addingTimeInterval(4.0 + drand48() * 4.0)
    }
    
    private func updateFurFromInteraction(x : CGFloat, lastX : CGFloat){
        let boundsWidth = max(furView.bounds.width, 0.01)
        let delta = x - lastX

        fur.petAt(xPos: x / boundsWidth, delta: delta)
    }
    
    private func updateMoodChangeRateInteraction(x : CGFloat, lastX : CGFloat){
        let delta = x - lastX
        
        //print("delta \(delta)")
        guard delta < -0.1 || delta > 0.25 else {
            // too slow, no effect
            petting = false
            bothering = false
            return
        }
        
        bothering = delta < -0.1 || delta > 20
        petting = delta > 0.1 && delta <= 20
    }
    
    func screech(){
        mood += 0.4
        screechStart = Date()
        fur.screech()
        purrPlayer.screech()
        shakeStart = Date().addingTimeInterval(screechDuration + 0.5)
    }
    
    func isScreeching() -> Bool {
        let timeSinceScreechStart = Date().timeIntervalSince(screechStart)
        return timeSinceScreechStart > 0 && timeSinceScreechStart < screechDuration
    }
}
