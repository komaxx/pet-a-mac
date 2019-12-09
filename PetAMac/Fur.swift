//
//  Fur.swift
//  PetAMac
//
//  Created by Matthias Schicker on 24.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import AppKit

class Fur {
    var ruffleStates = [CGFloat].init(repeating: 0, count: 60)
    
    /// progress the fur simulation
    func tick(timeDelta : TimeInterval) -> Bool {
        let changed = ruffleStates.reduce(false, { $0 || ($1 != 0) })
        ruffleStates = ruffleStates.map(){
            //let nuValue = $0 * 0.974
            let nuValue = $0 * 0.98
            if abs(nuValue) < 0.001 { return 0 }
            return nuValue
        }
        
        return changed
    }
    
    /// Computes the ruffle state in [-1;1] at the abstract position x
    /// (unit range [0;1])
    func ruffleAt(xPos : CGFloat) -> CGFloat {
        // clamp input to [0|1]
        let x = min(1, max(0, xPos))
        
        let ruffelStatesMaxIndex = CGFloat(ruffleStates.count - 1)
        
        let lowerIndex = floor(x * ruffelStatesMaxIndex)
        let upperIndex = ceil(x * ruffelStatesMaxIndex)
        
        let upperWeight = x*ruffelStatesMaxIndex - lowerIndex
        let lowerWeight = 1 - upperWeight
        
        return ruffleStates[Int(lowerIndex)] * lowerWeight
             + ruffleStates[Int(upperIndex)] * upperWeight
    }
    
    /// Computes new smoothing / ruffling at the given unit coordinate
    /// based on the delta
    func petAt(xPos: CGFloat, delta: CGFloat){
        // clamp input to [0|1]
        let x = min(1, max(0, xPos))
        let index = Int(round(x * CGFloat(ruffleStates.count - 1)))
        
        let deltaRuffling : CGFloat = delta > 0 ? 0.4 : -0.6
        ruffleStates[index] = deltaRuffling + deltaRuffling
    }
    
    func screech(){
        ruffleStates = ruffleStates.map(){ state in return drand48()>0.5 ? -1.7 : 0.7 }
    }
}
