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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD")
        // Do any additional setup after loading the view, typically from a nib.
        player = AVPlayer(URL: localData.currentVideoURL)
        
        if player != nil {
            var playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.frame
            self.view.layer.insertSublayer(playerLayer, below: doneButton.layer)
//            self.view.layer.addSublayer(playerLayer)
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
    
    @IBAction func rewindSegue() {
        println("GOT CALLED YO")
        self.dismissViewControllerAnimated(true, completion: {
            println("yeah dismissed yeah")
        })
    }
//    func beginSession() {
//        var err : NSError? = nil
//        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
//        
//        if err != nil {
//            println("error: \(err?.localizedDescription)")
//        }
//        
//        movieOutput.maxRecordedDuration = CMTimeMakeWithSeconds(10, 30)
//        movieOutput.minFreeDiskSpaceLimit = 10 * 1024 * 1024
//        if captureSession.canAddOutput(self.movieOutput) {
//            captureSession.addOutput(self.movieOutput)
//        } else {
//            println("couldn't add movie output!")
//        }
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer?.cornerRadius = 10.0
//        //        self.view.layer.addSublayer(previewLayer)
//        self.view.layer.insertSublayer(previewLayer, below: self.recordButton.layer);
//        previewLayer?.frame = self.view.layer.frame
//        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        captureSession.startRunning()
//    }
//    
//    @IBAction func startRecording() {
//        println("started recording!")
//        var temp = NSTemporaryDirectory();
//        var outputURL : NSURL = NSURL(fileURLWithPath: "\(temp)/movie" + NSProcessInfo.processInfo().globallyUniqueString + ".mp4")!;
//        println("URL: \(outputURL)")
//        println("what: \(outputURL.path)")
//        self.movieOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self.recordingDelegate)
//    }
//    
//    @IBAction func stopRecording() {
//        println("stopped recording woo")
//        self.movieOutput.stopRecording();
//    }
//    
//    func configureDevice() {
//        if let device = captureDevice {
//            device.lockForConfiguration(nil)
//            device.focusMode = .Locked
//            device.unlockForConfiguration()
//        }
//    }
//    
//    func focusTo(value : Float) {
//        println("FOCUSING")
//        if let device = captureDevice {
//            if(device.lockForConfiguration(nil)) {
//                println(value)
//                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
//                    //
//                })
//                device.unlockForConfiguration()
//            }
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
