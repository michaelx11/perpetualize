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
    var mainView: ViewController!
    @IBOutlet var doneButton: UIButton!
    
    var didLoad = false
    
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
            var playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.frame
            playerLayer.cornerRadius = 10
            self.view.layer.insertSublayer(playerLayer, below: doneButton.layer)
            player?.seekToTime(kCMTimeZero)
            player?.play()
            // Code to allow looping
            player?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "replayVideo", name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
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
            })
        }
        rewindSegue()
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
