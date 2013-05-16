//
//  RMYelpSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero on 18/04/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth1Client.h"
@protocol YelpDelegate <NSObject>

@end

@interface RMYelpSDK : AFOAuth1Client

+ (RMYelpSDK *)sharedClient;

-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndBounds:(NSDictionary *)boundsParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndCoordinates:(NSDictionary *)coordParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndLatitude:(NSString *)latitude AndLongitude:(NSString *)longitude AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;
-(void)getBusinessWithBusinessId:(NSString *)businessId AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate;

@end
