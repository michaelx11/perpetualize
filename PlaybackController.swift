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
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.view.frame
            playerLayer?.cornerRadius = 10
            playerLayer?.removeFromSuperlayer()
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
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            println("WROTE THE VIDEO")
            requestManager.uploadMovie(outputURL, handler: {(url: NSString?, error: NSString?) -> Void in
                println("YEAHHHHHHH \(outputURL)");
                self.rewindSegue()
            })
        } else {
            rewindSegue()
        }
    }
    
    func rewindSegue() {
        println("GOT CALLED YO")
        self.dismissViewControllerAnimated(false, completion: {
            println("yeah dismissed yeah")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
