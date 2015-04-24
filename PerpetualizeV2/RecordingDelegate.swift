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
        println(captureOutput.recordedDuration);
        println(captureOutput.recordedFileSize);
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            println("WROTE THE VIDEO")
        }
//        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL, nil, nil, nil)
        println("Stopped recording movie!")
    }
}
