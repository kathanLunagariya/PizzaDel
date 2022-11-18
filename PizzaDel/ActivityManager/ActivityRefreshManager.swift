//
//  ActivityRefreshManager.swift
//  PizzaDel
//
//  Created by Kathan Lunagariya on 17/11/22.
//

import Foundation
import AVFoundation
import ActivityKit
import UIKit

class ActivityRefreshManager:NSObject{
    static let shared = ActivityRefreshManager()
    let session = AVAudioSession.sharedInstance()
    let playQueue = DispatchQueue(label: "com.soundPlayer.playQueue", qos: .userInitiated)
    var testSoundPlayer: AVAudioPlayer!
    
    var soundPath: String { Bundle.main.path(forResource: "sound", ofType: "mp3")! }
    var soundURL: URL { URL(fileURLWithPath: soundPath) }
    
    var soundTimer: Timer?
    var orderStateIndex = 0
    
    override init() {
        super.init()
        do {
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print(error)
        }
        
        do {
            testSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error)
        }
    }
    
    func setupSoundTimer(){
        soundTimer = Timer(timeInterval: 30, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.orderStateIndex += 1
            
            if self.orderStateIndex >= OrderState.allCases.count-1{
                self.invalidateSoundTimer()
            }else{
                self.testSoundPlayer.play()
                self.updateActivityState(for: self.orderStateIndex)
            }
        })
        RunLoop.main.add(soundTimer!, forMode: .common)
    }
    
    func updateActivityState(for index:Int){
        guard let orderActivity = ActivityStateManager.activity else { return }
        let state = OrderState.allCases[index]
        
        let updatedState = ActivityStateManager.fetchUpdateContentState(for: state)
        Task{ @MainActor in
            await orderActivity.update(using: updatedState)
            
            if state == .atDoorStep{
                NotificationCenter.default.post(name: NSNotification.Name("Accept-Order-Button"), object: nil, userInfo: ["asAcceptance" : true])
            }
        }
    }
    
    func invalidateSoundTimer(){
        guard let soundTimer else { return }
        orderStateIndex = 0
        soundTimer.invalidate()
        
        if BG.backgroundTask != nil {
            UIApplication.shared.endBackgroundTask(BG.backgroundTask!)
            BG.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
    }
}
