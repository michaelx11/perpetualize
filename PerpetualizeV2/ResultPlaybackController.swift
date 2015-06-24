//
//  LoopedPlaybackController.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/25/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit
import AVFoundation

class ResultPlaybackController: UIViewController {

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var mainView: ViewController!
    var pollTimer: NSTimer?
    var resultFileURL: NSURL?
    
    var pollLock: NSLock = NSLock()
    
    @IBOutlet var doneButton: UIButton!
    
    var isPolling = false
    var didLoad = false
    var firstLoad = true
    var pollCounter = 0
    
    let MAX_TIMES = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD")
        // Do any additional setup after loading the view, typically from a nib.
        
        didLoad = true
        reset()
    }
    
    func getVideoData() {
        println("POLLING NOW")
        pollLock.lock()
        if isPolling {
            pollLock.unlock()
            return
        }
        isPolling = true
        pollLock.unlock()
        
        pollCounter++
        
        if pollCounter > MAX_TIMES {
            // TODO: trigger error / segue back
            println("TIME OUT")
            pollTimer?.invalidate()
            return
        }
        
        if resultFileURL != nil {
            pollTimer?.invalidate()
            return
        }
        
        requestManager.downloadFile(localData.downloadedVideoURL!, handler: {(fileURL: NSURL?, error: NSString?) -> Void in
            if (error != nil) {
                println(error)
                self.pollLock.lock()
                self.isPolling = false
                self.pollLock.unlock()
                return
            }
            if (fileURL != nil) {
                self.pollTimer?.invalidate()
                self.resultFileURL = fileURL
                self.refreshPlayer()
                self.pollLock.lock()
                self.isPolling = false
                self.pollLock.unlock()
                println("GOT THE DATA WOO")
                println(self.resultFileURL)
            }
        })
    }
    
    func reset() {
        if !didLoad {
            return
        }
        resultFileURL = nil
        isPolling = false
        pollCounter = 0
        pollTimer?.invalidate()
        pollTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "getVideoData", userInfo: nil, repeats: true)
        pollTimer?.fire()
        
    }
    
    func refreshPlayer() {
        if resultFileURL == nil {
            return
        }
        
        player = AVPlayer(URL: resultFileURL)
        println(player?.status.rawValue)
        println("WOO REFRESHING: \(resultFileURL)")
        if player != nil {
            println("ADDING PLAYERLAYER")
            playerLayer?.removeFromSuperlayer()
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.cornerRadius = 10.0
            playerLayer?.frame = self.view.frame
            self.view.layer.insertSublayer(playerLayer, below: doneButton.layer)
            
            // TODO: confirm that this cleans up observer
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            // Add a new observer
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "replayVideo", name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
            
            player?.seekToTime(kCMTimeZero)
            player?.play()
            // Code to allow looping
            player?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        }
    }
    
    func replayVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    @IBAction func exitView() {
        presentDeleteWarning()
    }
    
//    @IBAction func discardVideo() {
//        rewindSegue()
//    }
//    
//    @IBAction func saveVideo() {
//        var outputURL = localData.currentVideoURL!
//        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path) {
//            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
//            println("WROTE THE VIDEO")
//            requestManager.uploadMovie(outputURL, handler: {(url: NSString?, error: NSString?) -> Void in
//                println("YEAHHHHHHH \(url)")
//                localData.downloadedVideoURL = String(url!)
//                self.rewindSegue()
//            })
//        } else {
//            rewindSegue()
//        }
//    }
//    
//    func rewindSegue() {
//        println("GOT CALLED YO")
//        self.dismissViewControllerAnimated(false, completion: {
//            println("yeah dismissed yeah")
//        })
//    }
    
    func presentDeleteWarning() {
        var alert = UIAlertController(title: "Are you sure you want to permanently delete this GIF?",
            message: "You have not saved this gif. Exiting now will permanently delete it.",
            preferredStyle: .Alert)
        
        let deleteAction = UIAlertAction(title: "Delete GIF",
            style: .Default) { (action: UIAlertAction!) -> Void in
                // Exit View
                self.navigationController?.popToRootViewControllerAnimated(false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
