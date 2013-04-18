//
//  RMMasterSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero on 18/04/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMFoursquareSDK.h"

#import "RMTumblrSDK.h"

#import "RMInstagramSDK.h"

#import "RMYelpSDK.h"

@interface RMMasterSDK : NSObject

+(RMTumblrSDK *) TumblrSDK;
+(RMFoursquareSDK *) FoursquareSDK;
+(RMInstagramSDK *) InstagramSDK;
+(RMYelpSDK *) YelpSDK;

@end
