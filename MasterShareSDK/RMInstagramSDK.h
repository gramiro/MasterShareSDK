//
//  RMInstagramSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 18/04/13.
//
//    Copyright (c) 2013 Weston McBride
//
//    Permission is hereby granted, free of charge, to any
//    person obtaining a copy of this software and associated
//    documentation files (the "Software"), to deal in the
//    Software without restriction, including without limitation
//    the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the
//    Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice
//    shall be included in all copies or substantial portions of
//    the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
//    KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//    WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//    OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "AFOAuth2Client.h"

@protocol InstagramDelegate <NSObject>
//-(void)performLoginFromHandle;


@end

@interface RMInstagramSDK : AFOAuth2Client

@property (nonatomic, retain) NSString *clientID;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;
@property (nonatomic, retain) NSArray *scopes;
@property (nonatomic, strong) NSObject <InstagramDelegate> *loginDelegate;


//Login-logout methods
-(BOOL)handleOpenURL:(NSURL *)url;
+(RMInstagramSDK *)sharedClient;
-(void)authorizeWithScopes:(NSArray *)scopes;
-(void)logout;
-(BOOL)isLoginRequired;
-(BOOL)isCredentialExpired;


//USERS ENDPOINT
-(void)getUserInfoWithUserID:(NSString*)userID AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;
-(void)getAuthenticatedUserFeedWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;
-(void)getUserMediaWithUserID:(NSString*)userID Parameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;
-(void)getAuthenticatedUserLikedMediaWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;
-(void)searchUserWithQuery:(NSString*)query AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;

//RELATIONSHIPS ENDPOINT
-(void)getFollowedByWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getFollowsWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)postRelationshipWithAction:(NSString *)action UserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getRequestedByWithDelegate:(NSObject <InstagramDelegate> *)delegate;
-(void)getRelationshipWithUserID:(NSString*)userID AndWithDelegate:(NSObject <InstagramDelegate> *)delegate;

//MEDIA ENDPOINT
-(void)getMediaWithMediaID:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getMediaSearchWithParams:(NSDictionary *)mediaParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getPopularMediaWithDelegate:(NSObject<InstagramDelegate> *)delegate;
//MEDIA ENDPOINT: METHODS WITHOUT AUTHENTICATION
-(void)getWAMediaSearchWithParams:(NSDictionary *)mediaParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

//COMMENTS ENDPOINT
-(void)getCommentsWithMediaID:(NSString*)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)postCommentWithMediaID:(NSString*)mediaID Text:(NSString*)text AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)deleteCommentWithCommentID:(NSString*)comment MediaID:(NSString*)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

//LIKES ENDPOINT
-(void)getLikesOfMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)postLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)removeLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

//TAGS ENDPOINT
-(void)getTagInfoWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getRecentTags:(NSString *)tagID WithParams:(NSDictionary *)tagParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getSearchTagsWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

//LOCATIONS ENDPOINT
-(void)getLocationInfoWithLocationID:(NSString*)locationID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)getLocationRecentMediaWithLocationID:(NSString*)locationID Parameters:(NSDictionary*)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;
-(void)searchLocationWithParameters:(NSDictionary*)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

//GEOGRAPHIES ENDPOINT
-(void)getGeoWithGeoId:(NSString *)geoId WithParams:(NSDictionary *)geoParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate;

@end
