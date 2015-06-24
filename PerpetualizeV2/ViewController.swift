//
//  ViewController.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/23/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit
import AVFoundation

let requestManager = RequestManager()
let localData = FastLocalData()
let globalNavigationController = UINavigationController()

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    let recordingDelegate : RecordingDelegate = RecordingDelegate()
    var playbackController : PlaybackController!
    var resultPlaybackController : ResultPlaybackController!
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet var recordButton : UIButton!
    @IBOutlet var durationLabel : UILabel!
    @IBOutlet var durationBackground : UIView!
    @IBOutlet var holdLabel : UILabel!
    @IBOutlet var holdBackground : UIImageView!
    
    var duration : Int64 = 0
    var durationTimer : NSTimer!
    
    var isRecording : Bool = false
    
    
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var movieOutput : AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
//    var memoryOutput : AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD")
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
        // Pass self reference to recording delegate
        recordingDelegate.parent = self
        
        // Get playback controller
        playbackController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaybackController") as! PlaybackController
        resultPlaybackController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ResultPlaybackController") as! ResultPlaybackController
        // HACK: give a reference to allow playback to present our view when done
        playbackController.mainView = self
        
        self.durationLabel.hidden = true
        self.durationBackground.hidden = true
        self.holdLabel.hidden = false
        self.holdBackground.hidden = false
    }

    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        movieOutput.maxRecordedDuration = CMTimeMakeWithSeconds(10, 30)
        movieOutput.minFreeDiskSpaceLimit = 10 * 1024 * 1024
        if captureSession.canAddOutput(self.movieOutput) {
            captureSession.addOutput(self.movieOutput)
        } else {
            println("couldn't add movie output!")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.cornerRadius = 10.0
        self.view.layer.insertSublayer(previewLayer, below: self.recordButton.layer);
        previewLayer?.frame = self.view.layer.frame
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        captureSession.startRunning()
    }
    
    @IBAction func startRecording() {
        if isRecording {
            stopRecording()
            isRecording = false
        }
        println("started recording!")
        startTimer()
        var temp = NSTemporaryDirectory();
        var outputURL : NSURL = NSURL(fileURLWithPath: "\(temp)/movie" + NSProcessInfo.processInfo().globallyUniqueString + ".mp4")!
        println("URL: \(outputURL)")
        println("what: \(outputURL.path)")
        self.movieOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self.recordingDelegate)
    }
    
    @IBAction func stopRecording() {
        println("stopped recording woo")
        self.movieOutput.stopRecording()
        isRecording = false
    }
    
    func startTimer() {
        self.durationLabel.text = "0:00"
        self.duration = 0
        self.durationLabel.hidden = false
        self.durationBackground.hidden = false
        self.holdLabel.hidden = true
        self.holdBackground.hidden = true
        self.durationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tickDuration", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.durationTimer.invalidate()
        self.durationLabel.hidden = true
        self.durationBackground.hidden = true
        self.holdLabel.hidden = false
        self.holdBackground.hidden = false
    }
    
    func tickDuration() {
        self.duration += 1
        let minutes = self.duration / 60
        let seconds = self.duration % 60
        self.durationLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func focusTo(value : Float) {
        println("FOCUSING")
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                println(value)
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
            }
        }
    }
    
    func presentPlaybackView() {
        self.navigationController?.pushViewController(playbackController, animated: false)
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        println("TOUCHES BEGAN")
//        var anyTouch = touches.first as! UITouch
//        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
//        focusTo(Float(touchPercent))
//    }
//    
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        println("TOUCHES MOVED")
//        var anyTouch = touches.first as! UITouch
//        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
//        focusTo(Float(touchPercent))
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

