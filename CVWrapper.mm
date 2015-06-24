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

+ (NSURL*) processMovie:(NSURL*)movieFileURL
{
    cv::VideoCapture capture;
    NSString* pathToFile = [movieFileURL path];
    if(capture.open(std::string([pathToFile UTF8String]))){
        NSLog(@"Opened");
    }else{
        NSLog(@"Failed to open");
    }
    return movieFileURL;
}

@end
