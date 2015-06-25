//
//  PlaybackController.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/24/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit
import AVFoundation

class PlaybackController: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var mainView: ViewController!
    @IBOutlet var doneButton: UIButton!
    
    var didLoad = false
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD")
        // Do any additional setup after loading the view, typically from a nib.

        didLoad = true
        refreshPlayer()
    }
    
    func refreshPlayer() {
        if !didLoad {
            return
        }
        
        player = AVPlayer(URL: localData.currentVideoURL)
        
        if player != nil {
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
    
    @IBAction func discardVideo() {
        rewindSegue()
    }
    
    @IBAction func saveVideo() {
        var outputURL = localData.currentVideoURL!
        let loopedFileURL: NSURL = CVWrapper.processMovie(outputURL)
        localData.processedVideoURL = loopedFileURL
        println(loopedFileURL)
        self.resultVideoSegue()
        /*
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            println("WROTE THE VIDEO")
            
            // Hack for no server, just replay original ^^^
//            localData.downloadedVideoURL = outputURL.path
//            self.resultVideoSegue()
            println(outputURL)
            
            let loopedFileURL: NSURL = CVWrapper.processMovie(outputURL)
            println(loopedFileURL)
//            requestManager.uploadMovie(outputURL, handler: {(url: NSString?, error: NSString?) -> Void in
//                println("YEAHHHHHHH \(outputURL)");
//                
//                if (error != nil) {
//                    println("Error saving video: \(error)")
//                } else {
//                    localData.downloadedVideoURL = String(url!)
//                    self.resultVideoSegue()
//                }
//            })
        } else {
            rewindSegue()
        }
        */
    }
    
    func rewindSegue() {
        println("GOT CALLED YO")
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func resultVideoSegue() {
        self.mainView.resultPlaybackController.reset()
        self.navigationController?.pushViewController(self.mainView.resultPlaybackController, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
