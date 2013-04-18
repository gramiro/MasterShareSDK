//
//  YelpSDK.h
//  YelpSDKExample
//
//  Created by Marco S. Graciano on 4/16/13.
//  Copyright (c) 2013 Marco S. Graciano. All rights reserved.
//

#import "AFOAuth1Client.h"

@protocol YelpDelegate <NSObject>

@end

@interface YelpSDK : AFOAuth1Client

+ (YelpSDK *)sharedClient;

-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndBounds:(NSDictionary *)boundsParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndCoordinates:(NSDictionary *)coordParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndLatitude:(NSString *)latitude AndLongitude:(NSString *)longitude AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getBusinessWithBusinessId:(NSString *)businessId AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;

@end