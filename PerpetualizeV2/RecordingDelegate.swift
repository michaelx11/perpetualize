//
//  RecordingDelegate.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/23/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class RecordingDelegate : NSObject, AVCaptureFileOutputRecordingDelegate {
    
    // TODO: FAT HACK WILL FIX WHEN WISER
    // Should be populated before delegate is used
    var parent: ViewController!
    
    override init() {
        println("CREATED")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Started recording movie!")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if let err = error {
            println(err)
        }
        localData.currentVideoURL = outputFileURL
        self.parent.playbackController.refreshPlayer()
        self.parent.presentPlaybackView()
        println("Stopped recording movie!")
    }
}
