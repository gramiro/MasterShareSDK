//
//  RMInstagramSDK.h
//  MasterShareSDK
//
//  Created by Marco Graciano on 18/04/13.
//  Copyright (c) 2013 Marco Graciano. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFOAuth2Client.h"

@protocol InstagramRequestsDelegate <NSObject>


@end

@protocol HandleURLLoginDelegate <NSObject>


@end

@interface RMInstagramSDK : AFOAuth2Client

@property (nonatomic, retain) NSString *clientID;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;
@property (nonatomic, retain) NSArray *scopes;
@property (nonatomic, strong) NSObject <HandleURLLoginDelegate> *loginDelegate;


//Login-logout methods
-(BOOL)handleOpenURL:(NSURL *)url;
+(RMInstagramSDK *)sharedClient;
-(void)authorizeWithScopes:(NSArray *)scopes;
-(void)logout;
-(BOOL)isLoginRequired;
-(BOOL)isCredentialExpired;


//USERS ENDPOINT
-(void)getUserInfoWithUserID:(NSString*)userID AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;
-(void)getAuthenticatedUserFeedWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;
-(void)getUserMediaWithUserID:(NSString*)userID Parameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;
-(void)getAuthenticatedUserLikedMediaWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;
-(void)searchUserWithQuery:(NSString*)query AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;

//RELATIONSHIPS ENDPOINT
-(void)getFollowedByWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getFollowsWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)postRelationshipWithAction:(NSString *)action UserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getRequestedByWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;
-(void)getRelationshipWithUserID:(NSString*)userID AndWithDelegate:(NSObject <InstagramRequestsDelegate> *)delegate;

//MEDIA ENDPOINT
-(void)getMediaWithMediaID:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getMediaSearchWithParams:(NSDictionary *)mediaParams AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getPopularMediaWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

//COMMENTS ENDPOINT
-(void)getCommentsWithMediaID:(NSString*)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)postCommentWithMediaID:(NSString*)mediaID Text:(NSString*)text AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)deleteCommentWithCommentID:(NSString*)comment MediaID:(NSString*)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

//LIKES ENDPOINT
-(void)getLikesOfMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)postLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)removeLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

//TAGS ENDPOINT
-(void)getTagInfoWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getRecentTags:(NSString *)tagID WithParams:(NSDictionary *)tagParams AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getSearchTagsWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

//LOCATIONS ENDPOINT
-(void)getLocationInfoWithLocationID:(NSString*)locationID AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)getLocationRecentMediaWithLocationID:(NSString*)locationID Parameters:(NSDictionary*)params AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;
-(void)searchLocationWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

//GEOGRAPHIES ENDPOINT
-(void)getGeoWithGeoId:(NSString *)geoId WithParams:(NSDictionary *)geoParams AndWithDelegate:(NSObject<InstagramRequestsDelegate> *)delegate;

@end
