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

//            var filename : String = (outputFileURL.pathComponents?.last as! String).stringByDeletingPathExtension;
//            println("YO: \(filename)")
//            var path = NSBundle.mainBundle().pathForResource(filename, ofType: ".mp4")

//            println("path ext: \(outputFileURL.pathExtension)")
//            println("REAL PATH: \(path)")
//            NSData(contentsOfURL: outputFileURL)
//            println(errP)
//            println("data?!??!: \(NSData(contentsOfFile: outputFileURL.path!))")
//            println("data?!??! 2: \(NSData(contentsOfURL: outputFileURL, options: nil, error: &errP))")
//            println(errP)
//            println("data?!??! 3: \(NSData(contentsOfURL: outputFileURL.!))")
            requestManager.uploadMovie(outputFileURL!, handler: {(url: NSString?, error: NSString?) -> Void in
                println("YEAHHHHHHH \(outputFileURL)");
            })
        }
//        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL, nil, nil, nil)
        println("Stopped recording movie!")
    }
}
