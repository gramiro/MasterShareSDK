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
#import "RMTwitterSDK.h"
#import "RMFacebookSDK.h"
#import "RMLinkedInSDK.h"
#import "RMGooglePlusSDK.h"
#import "RMDeviantArtSDK.h"
#import "RMOrkutSDK.h"

@interface RMMasterSDK : NSObject

+(RMTumblrSDK *) TumblrSDK;
+(RMFoursquareSDK *) FoursquareSDK;
+(RMInstagramSDK *) InstagramSDK;
+(RMYelpSDK *) YelpSDK;
+(RMTwitterSDK *) TwitterSDK;
+(RMFacebookSDK *) FacebookSDK;
+(RMLinkedInSDK *) LinkedInSDK;
+(RMGooglePlusSDK *) GooglePlusSDK;
+(RMDeviantArtSDK *) DeviantArtSDK;
+(RMOrkutSDK *) OrkutSDK;

@end
