//
//  FurView.swift
//  PetAMac
//
//  Created by Matthias Schicker on 23.08.18.
//  Copyright © 2018 Matthias Schicker. All rights reserved.
//

import Cocoa

class FurView: NSView {
    let furImageWidth : CGFloat = 60
    let furImageOverlap : CGFloat = 50
    let maxRandomOffset : CGFloat = 10
    
    let tailSteps = 5
    
    var baseLayer : CALayer
    var furLayers : [CALayer] = []
    
    var tickCounter = 0
    
    var faceLayer : CALayer
    var currentFace = #imageLiteral(resourceName: "face_ecstatic")
    var currentAppIcon = #imageLiteral(resourceName: "app_icon_happy")
    var blinkTime = Date()
    var touchingOnFace = false

    var timer : Timer?
    var shakeStart = Date.distantFuture
    let mood = Mood()
    
    
    required init?(coder decoder: NSCoder) {
        self.baseLayer = CALayer.init()
        self.faceLayer = CALayer.init()
        
        super.init(coder: decoder)
        
        mood.furView = self

        self.layer = self.baseLayer
        
        self.faceLayer.contents = #imageLiteral(resourceName: "face_ecstatic")
        self.faceLayer.frame = CGRect(x: 0, y: 0, width: 75, height: 30)
        self.faceLayer.zPosition = 1
        self.baseLayer.addSublayer(faceLayer)
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        recreateFurLayers()
        super.resize(withOldSuperviewSize: oldSize)
    }
    
    override func viewDidMoveToWindow() {
        startTickingIfNecessary()
    }
    
    func startTickingIfNecessary(){
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true){ [weak self] timer in
            guard let strongSelf = self else {
                print("timer removed")
                timer.invalidate()
                return
            }
            strongSelf.tick()
        }
        timer?.fire()
    }
    
    func tick(){
        tickCounter = tickCounter + 1
        let furChanged = mood.tick()
        if furChanged {
            self.updateRuffling()
        }
        updateFace()
        updateAppIcon()
        shakeTick()
    }
    
    func updateFace(){
        var nuFace = (tickCounter % 10==0) ? mood.getFace() : currentFace
        if touchingOnFace { nuFace = #imageLiteral(resourceName: "face_sleep") }
        if blinkTime.timeIntervalSinceNow < 0 && mood.mood > 0 {
            nuFace = #imageLiteral(resourceName: "face_sleep")
            blinkTime = Date().addingTimeInterval(4 + drand48()*4)
        }
        guard nuFace != currentFace else {
            return
        }
        faceLayer.contents = nuFace
        currentFace = nuFace
    }
    
    func updateAppIcon(){
        var appIcon = currentAppIcon
        if mood.mood < -0.1 { appIcon = #imageLiteral(resourceName: "app_icon_mad") }
        if mood.mood > 0.1 { appIcon = #imageLiteral(resourceName: "app_icon_happy") }
        guard appIcon != currentAppIcon else { return }
        
        NSApplication.shared.applicationIconImage = appIcon.imageWithTintColor(tintColor: NSColor.green)
        currentAppIcon = appIcon
    }
    
    func recreateFurLayers() {
        clearFurLayers()
        createFurLayers()
    }
    
    func clearFurLayers(){
        furLayers.forEach(){ $0.removeFromSuperlayer() }
        furLayers.removeAll()
    }
    
    func createFurLayers(){
        self.baseLayer.mask?.frame = self.bounds
        
        let furLayerCount = Int((bounds.width - furImageWidth) / (furImageWidth-furImageOverlap)) - 2
        let baseBounds = CGRect(x: furImageWidth/2.0, y: 0, width: furImageWidth, height: bounds.height)
        
        let layerOffsetStep = furImageWidth - furImageOverlap
        var lastFurIndices = [Int].init(repeating: -1, count: 2)    // increase counr for larger non-repeate window
        
        for i in 0..<furLayerCount {
            let layer = CALayer.init()
            
            // invers z-order
            //layer.zPosition = 0.9 - (CGFloat(i) / CGFloat(furLayerCount))
            
            // random z-order
            //layer.zPosition = CGFloat(0.8*drand48())
            
            let furs = [
                #imageLiteral(resourceName: "fur_0"), #imageLiteral(resourceName: "fur_1"), #imageLiteral(resourceName: "fur_2"), #imageLiteral(resourceName: "fur_3"), #imageLiteral(resourceName: "fur_4"), #imageLiteral(resourceName: "fur_5")
            ]
            let furEnds = [
                #imageLiteral(resourceName: "fur_end_0"), #imageLiteral(resourceName: "fur_end_1")
            ]
            
            var furIndex = -2
            if i > furLayerCount - tailSteps {
                layer.masksToBounds = false
                layer.frame = baseBounds.offsetBy(dx: CGFloat(i) * layerOffsetStep, dy: 0)
                layer.contents = furEnds[Int( drand48() * Double(furEnds.count) )]
            } else {
                repeat {
                    furIndex = Int( drand48() * Double(furs.count) )
                } while (lastFurIndices.contains(furIndex))
                lastFurIndices.remove(at: 0)
                lastFurIndices.append(furIndex)
                layer.contents = furs[furIndex]

                let randomOffset = CGFloat(drand48())*maxRandomOffset - maxRandomOffset/2.0
                layer.frame = baseBounds.offsetBy(dx: CGFloat(i) * layerOffsetStep + randomOffset, dy: 0)
            }

            let maskLayer = CALayer.init()
            maskLayer.frame = CGRect(x: 0, y: 0, width: furImageWidth, height: bounds.height)
            maskLayer.contents = #imageLiteral(resourceName: "fur_mask")
            layer.mask = maskLayer

            self.furLayers.append(layer)
            self.baseLayer.addSublayer(layer)
        }
    }
    
    func updateRuffling(){
        let firstTailIndex = furLayers.count - tailSteps
        var index = 0
        furLayers.forEach(){ furLayer in
            var factor : CGFloat = 1.0
            if index >= firstTailIndex {
                factor = 1.0 - CGFloat(index - firstTailIndex) / CGFloat(tailSteps)
                factor = factor*factor
            }
            
            let unitX = furLayer.frame.minX / max(bounds.width, 0.01)
            let rawRuffle = mood.fur.ruffleAt(xPos: unitX)
            let ruffling = rawRuffle * factor
            
            var width : CGFloat = 1
            var height : CGFloat = 1
            if (rawRuffle < 0){
                let rufflingAngle = rawRuffle * (index%2 == 0 ? 1 : -1) * CGFloat.pi/9
                furLayer.transform = CATransform3DMakeRotation(rufflingAngle, 0, 0, 1)
                width = 1 - (ruffling * 1.2)
                height = 1 - (ruffling * 0.4)
            } else {
                furLayer.transform = CATransform3DIdentity
                height = 1
                width = 1 - (ruffling * 1.5)
            }
            
            furLayer.contentsRect = CGRect(x: 0, y: (1.0-height)/2.0, width: width, height: height)
            index = index + 1
        }
    }
}

extension FurView {
    override func touchesBegan(with event: NSEvent) {
        setTouchingOnFaceIfApplicable(event: event)
    }
    
    override func touchesMoved(with event: NSEvent) {
        setTouchingOnFaceIfApplicable(event: event)
        guard let touch = event.allTouches().first else {
            return
        }
        let touchX = touch.location(in: self).x
        let lastTouchX = touch.previousLocation(in: self).x
        mood.interaction(x: touchX, lastX: lastTouchX)
    }
    
    func setTouchingOnFaceIfApplicable(event : NSEvent){
        let touchX = event.allTouches().first?.location(in: self).x
        touchingOnFace = (touchX ?? 999) < 70
    }
    
    override func touchesEnded(with event: NSEvent) {
        touchingOnFace = false
        mood.interactionFinished()
    }
    
    override func touchesCancelled(with event: NSEvent) {
        touchingOnFace = false
        mood.interactionFinished()
    }
}

extension FurView {
    public func shake(){
        shakeStart = Date()
        furLayers.forEach(){ $0.transform = CATransform3DIdentity }
    }
    
    func shakeTick(){
        let singleShakeDuration = 0.15
        let shakes = 4.0
        let maxShakeRadians = Double.pi / 1.8
        
        let timeSinceStart = -shakeStart.timeIntervalSinceNow
        guard timeSinceStart > 0 else { return }

        // shake face
        let facePhase = (timeSinceStart / singleShakeDuration) * Double.pi
        var faceRadians = sin(facePhase) * maxShakeRadians
        if facePhase < 0 || facePhase > shakes * 2 * Double.pi {
            faceRadians = 0
        }
        faceLayer.transform = CATransform3DMakeRotation(CGFloat(faceRadians), 0, 0, 1)
        
        var shakeFinished = timeSinceStart > 0.1
        
        // shake body
        for layer in furLayers {
            let layerPhaseOffset = Double(layer.frame.midX / max(bounds.width, 0.01)) * 0.5
            let phase = ((timeSinceStart - layerPhaseOffset) / singleShakeDuration) * Double.pi
            
            var radians = sin(phase) * maxShakeRadians
            if phase < 0 || phase > shakes * 2 * Double.pi {
                radians = 0
            } else {
                shakeFinished = false
            }
            
            layer.transform = CATransform3DMakeRotation(CGFloat(radians), 0, 0, 1)
        }
        
        if shakeFinished {
            shakeStart = Date.distantFuture
        }
    }
}


