//
//  RMMasterSDK.m
//  MasterShareSDK
//
//  Created by Ramiro Guerrero on 18/04/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import "RMMasterSDK.h"

@implementation RMMasterSDK

+(RMTumblrSDK *) TumblrSDK{
    return [RMTumblrSDK sharedClient];
}

+(RMFoursquareSDK *) FoursquareSDK {
    return [RMFoursquareSDK sharedClient];
}

+(RMInstagramSDK *) InstagramSDK{
    return [RMInstagramSDK sharedClient];
    
}

+(RMYelpSDK *) YelpSDK{
    return [RMYelpSDK sharedClient];
    
}

+(RMTwitterSDK *) TwitterSDK{
    return [RMTwitterSDK sharedClient];
    
}

+(RMFacebookSDK *) FacebookSDK{
    return [RMFacebookSDK sharedClient];
}

@end
