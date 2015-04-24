//
//  ViewController.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/23/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit
import AVFoundation

let requestManager = RequestManager();

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession();
    let recordingDelegate : RecordingDelegate = RecordingDelegate()
    var previewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet var recordButton : UIButton!
    
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
//        self.view.layer.addSublayer(previewLayer)
        self.view.layer.insertSublayer(previewLayer, below: self.recordButton.layer);
        previewLayer?.frame = self.view.layer.frame
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        captureSession.startRunning()
    }
    
    @IBAction func startRecording() {
        println("started recording!")
        var temp = NSTemporaryDirectory();
        var outputURL : NSURL = NSURL(fileURLWithPath: "\(temp)/movie" + NSProcessInfo.processInfo().globallyUniqueString + ".mp4")!;
        println("URL: \(outputURL)")
        println("what: \(outputURL.path)")
        self.movieOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self.recordingDelegate)
    }
    
    @IBAction func stopRecording() {
        println("stopped recording woo")
        self.movieOutput.stopRecording();
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

