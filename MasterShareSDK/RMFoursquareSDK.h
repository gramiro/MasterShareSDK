//
//  RMFoursquareSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero on 18/04/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth2Client.h"

@protocol FoursquareDelegate <NSObject>

@end

@interface RMFoursquareSDK : AFOAuth2Client

@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;

+ (RMFoursquareSDK *)sharedClient;
-(void)authenticate;
- (BOOL)handleOpenURL:(NSURL *)url;


//USERS ENDPOINT
-(void)getUserDataWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getLeaderboardsWithNeighborsParameter:(NSString *)neighbors AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getRequestsWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSearchUserWithName:(NSString *)name AndParameters:(NSDictionary *)searchParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserBadgesWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserCheckinsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)checkinsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserFriendsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)friendsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserListsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)listsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserMayorshipsWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserPhotosWithUserId:(NSString *)userID AndParameters:(NSDictionary *)friendsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserTipsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)tipsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserVenueHistoryWithUserId:(NSString *)userID AndParameters:(NSDictionary *)vHistoryParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postApproveWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;
-(void)postDenyWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;
-(void)postRequestWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;
-(void)postSetPingsWithUserId:(NSString *)userID AndValue:(NSString *)value AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;
-(void)postUnfriendWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;
-(void)postUpdateWithPhoto:(UIImage *)photo AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate;


//VENUES ENDPOINT
-(void)getVenueDetailsWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddVenueWithName:(NSString *)name AndLatitudeLongitude:(NSDictionary *)coords AndParameters:(NSDictionary *)venueParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueCategoriesWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getExploreVenuesWithLatitudeLongitude:(NSDictionary *)coords OrNear:(NSString *)near AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getManagedVenuesWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSearchVenuesWithLatitudeLongitude:(NSDictionary *)coords OrNear:(NSString *)near AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSuggestCompletionVenuesWithLatitudeLongitude:(NSDictionary *)coords AndQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueTimeSeriesDataWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTrendingVenuesWithLatitudeLongitude:(NSDictionary *)coords AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueEventsWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueHereNowWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueHoursWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueLikesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueLinksWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueListsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueMenuWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueNextVenuesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenuePhotosWithVenueId:(NSString *)venueID AndGroup:(NSString *)group AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueSimilarVenuesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueStatsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueTipsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDislikeVenueWithWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postEditVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postFlagVenueWithVenueId:(NSString *)venueID AndProblem:(NSString *)problem AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postLikeVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postProposeEditVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postSetUserRoleForVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//CHECKINS ENDPOINT
-(void)getCheckinDataWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)checkinParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddCheckinWithvenueId:(NSString *)venueId WithParameters:(NSDictionary *)addParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getRecentCheckinsWithParameters:(NSDictionary *)recentCheckinParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getCheckinLikesWithCheckinId:(NSString *)checkinID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddCommentInCheckinWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)commentParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddPostInCheckinWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)postParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDeleteCommentInCheckinWithCheckinId:(NSString *)checkinID WithCommentID:(NSString *)commentId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddOrRemoveLikeInCheckinWithCheckinId:(NSString *)checkinID WithAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate; //1-> Like  0->Unlike
-(void)postReplyWithCheckinId:(NSString *)checkinID WithText:(NSString *)text WithParams:(NSDictionary *)replyParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//TIPS ENDPOINT

-(void)getTipDataWithTipId:(NSString *)tipId WithParameters:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postTipWithVenueId:(NSString *)venueId WithText:(NSString *)text WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipLikesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipListsWithTipId:(NSString *)tipId WithParameters:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipSavesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postFlagATipWithTipId:(NSString *)tipId WithProblem:(NSString *)problem WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
//The specific problem with the tip. Must be one of "offensive", "spam", or "nolongerrelevant".
-(void)postAddOrRemoveLikeATipWithTipId:(NSString *)tipId WithAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate; //1-> Like  0->Unlike
-(void)postUnmarkTipWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;


@end
