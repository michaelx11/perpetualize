//
//  CVWrapper.h
//  PerpetualizeV2
//
//  Created by Michael Xu on 6/24/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

#ifndef PerpetualizeV2_CVWrapper_h
#define PerpetualizeV2_CVWrapper_h
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject

+ (NSURL*) processMovie: (NSURL*) rawMovie;

@end

#endif
