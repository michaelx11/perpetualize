//
//  CVWrapper.m
//  PerpetualizeV2
//
//  Created by Michael Xu on 6/24/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

#import "CVWrapper.h"
#import <opencv2/opencv.hpp>

@implementation CVWrapper

std::vector<cv::Mat> frames;

+ (void) preprocessFrame:(cv::Mat&)image
{
    cv::resize(image, image, cv::Size(image.size[1], image.size[0]), 0, 0, CV_INTER_CUBIC);
    cv::transpose(image, image);
    cv::flip(image, image, 1);
//    return image;
}

+ (NSURL*) processMovie:(NSURL*)movieFileURL
{
    frames.clear();
    cv::VideoCapture capture;
    NSString* pathToFile = [movieFileURL path];
    if(capture.open(std::string([pathToFile UTF8String]))){
        NSLog(@"Opened");
//        NSMutableArray *frames = [[NSMutableArray alloc] init];
        
        cv::Mat frame;
        while(capture.read(frame)) {
            [self preprocessFrame:frame];
            frames.push_back(frame.clone());
        }
        NSLog(@"Processed");
        cv::VideoWriter writer;
        cv::Size frameSize(frames[0].cols, frames[0].rows);
//        frameSize = cv::Size(frames[0].size);
        NSLog(@"%d, %d", frames[0].rows, frames[0].cols);
        NSLog(@"%d, %d", frameSize.height, frameSize.width);
        
        NSString *path = [NSString stringWithFormat:@"%@/result-%@.mp4", NSTemporaryDirectory(), [movieFileURL lastPathComponent]];
        writer.open(std::string([path UTF8String]), writer.fourcc('M', 'J', 'P', 'G'), 30.0, frameSize, true);
        NSLog(@"is opened: %d", writer.isOpened());
        for (int i = 0; i < frames.size(); i++) {
            NSLog(@"%d", i);
            writer.write(frames[i]);
            [NSThread sleepForTimeInterval:0.02f];
        }
        frames.clear();
        writer.release();
        return [NSURL fileURLWithFileSystemRepresentation:[path UTF8String] isDirectory:false relativeToURL:nil];
    }else{
        NSLog(@"Failed to open");
    }
    return movieFileURL;
}

@end
