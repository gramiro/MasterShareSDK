//
//  RMFoursquareSDK.h
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

@protocol FoursquareDelegate <NSObject>
//-(void)performLoginFromHandle;

-(void)loadNearbyExploreWithData:(NSDictionary *)array;

@end

@interface RMFoursquareSDK : AFOAuth2Client

@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;
@property (nonatomic, strong) NSObject <FoursquareDelegate> *loginDelegate;

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
-(void)postLikeVenueWithVenueId:(NSString *)venueID AndAction:(NSString *)set AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;//Action 1->like, 0->unlike
-(void)postProposeEditVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postSetUserRoleForVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
//VENUES USERLESS METHODS
-(void)getUserlessExploreVenuesWithLatitudeLongitude:(NSDictionary *)coords OrNear:(NSString *)near AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;


//VENUEGROUPS ENDPOINT
-(void)getVenueGroupDetailsWithGroupId:(NSString *)groupID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddVenueGroupWithVenueGroupName:(NSString *)name AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDeleteVenueGroupWithVenueGroupId:(NSString *)groupID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getListVenueGroupsWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getVenueGroupTimeSeriesDataWithGroupId:(NSString *)groupID AndStartAt:(NSString *)startAt AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddVenueToVenueGroupWithVenueGroupId:(NSString *)groupID AndVenuesList:(NSString *)venuesList AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getCampaignsForVenueGroupWithVenueGroupId:(NSString *)groupID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postEditVenuesInVenueGroupWithVenueGroupId:(NSString *)groupID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postRemoveVenuesFromVenueGroupWithVenueGroupId:(NSString *)groupID AndVenuesList:(NSString *)venuesList AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postUpdateVenueGroupWithVenueGroupId:(NSString *)groupID AndVenueGroupName:(NSString *)name OrVenuesList:(NSString *)venuesList AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;


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
-(void)getTipDataWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postTipWithVenueId:(NSString *)venueId WithText:(NSString *)text WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipLikesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipListsWithTipId:(NSString *)tipId WithParameters:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getTipSavesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postFlagATipWithTipId:(NSString *)tipId WithProblem:(NSString *)problem WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
//The specific problem with the tip. Must be one of "offensive", "spam", or "nolongerrelevant".
-(void)postAddOrRemoveLikeATipWithTipId:(NSString *)tipId WithAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate; //1-> Like  0->Unlike
-(void)postUnmarkTipWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;


//LISTS ENDPOINT
-(void)getListDetailsWithListId:(NSString *)listID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddListWithListName:(NSString *)name AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getListFollowersWithListId:(NSString *)listID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUsersWhoSavedAListWithListId:(NSString *)listID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSuggestPhotoAppropiateForItemInListWithListId:(NSString *)listID AndItemId:(NSString *)itemID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSuggestTipAppropiateForItemInListWithListId:(NSString *)listID AndItemId:(NSString *)itemID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSuggestVenuesAppropiateForListWithListId:(NSString *)listID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddItemToListWithListId:(NSString *)listID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDeleteItemInListWithListId:(NSString *)listID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postFollowListWithListId:(NSString *)listID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postMoveItemInListWithListId:(NSString *)listID AndItemId:(NSString *)itemID AndBeforeId:(NSString *)beforeID OrAfterId:(NSString *)afterID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postShareListWithListId:(NSString *)listID AndBroadcast:(NSString *)broadcast AndMessage:(NSString *)message AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postUnfollowListWithListId:(NSString *)listID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postUpdateListWithListId:(NSString *)listID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postUpdateItemInListWithListId:(NSString *)listID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//UPDATES ENDPOINT
-(void)getUpdateDetailsWithUpdateId:(NSString *)updateID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserNotificationsWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postMarkNotificationAsReadWithTimestamp:(NSString *)timestamp AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//PHOTOS ENDPOINT
-(void)getPhotoDetailsWithPhotoId:(NSString *)photoID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddPhotoWithPhoto:(UIImage *)photo AndCheckinId:(NSString *)checkinID OrTipId:(NSString *)tipID OrVenueId:(NSString *)venueID OrPageId:(NSString *)pageID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//SETTINGS ENDPOINT
-(void)getSettingDetailWithSettingId:(NSString *)settingID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getAllActingUserSettingsWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postChangeSettingWithSettingId:(NSString *)settingID AndValue:(NSString *)value AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//SPECIALS ENDPOINT
-(void)getSpecialDetailWithSpecialId:(NSString *)specialID AndVenueId:(NSString *)venueID AndUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddSpecialWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSpecialsListWithVenuesListId:(NSString *)venuesList AndStatus:(NSString *)status AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSearchNearSpecialsWithLatitudeLongitude:(NSDictionary *)coords AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSpecialConfigurationDetailsWithSpecialId:(NSString *)specialID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postFlagASpecialWithSpecialId:(NSString *)specialID AndVenueId:(NSString *)venueID AndProblem:(NSString *)problem AndText:(NSString *)text AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postRetireSpecialWithSpecialId:(NSString *)specialID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//CAMPAIGNS ENDPOINT
-(void)getCampaignsDetailWithCampaignId:(NSString *)campaignID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddCampaignWithSpecialId:(NSString *)specialID OrGroupId:(NSString *)groupID OrVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getListCampaignsWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getCampaignTimeSeriesDataWithCampaignId:(NSString *)campaignID AndStartAt:(NSString *)startAt AndEndAt:(NSString *)endAt AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDeleteCampaignWithCampaignId:(NSString *)campaignID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postEndCampaignWithCampaignId:(NSString *)campaignID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postStartCampaignWithCampaignId:(NSString *)campaignID AndStartAt:(NSString *)startAt AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//EVENTS ENDPOINT
-(void)getEventDetailsWithEventId:(NSString *)eventID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getEventCategoriesWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSearchEventsWithDomain:(NSString *)domain AndEventId:(NSString *)eventID OrParticipantId:(NSString *)participantID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddEventWithVenueId:(NSString *)venueID AndEventName:(NSString *)name AndStart:(NSString *)start AndEnd:(NSString *)end AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//PAGES ENDPOINT
-(void)getUserDetailsForAPageWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddPageWithName:(NSString *)name AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getManagedPagesListWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getSearchPagesWithName:(NSString *)name AndTwitterHandles:(NSString *)twitter AndFacebookIds:(NSString *)fbid AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getPageVenuesTimeSeriesDataWithPageId:(NSString *)pageID AndStartAt:(NSString *)startAt AndEndAt:(NSString *)endAt AndFields:(NSString *)fields AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getPageVenuesWithPageId:(NSString *)pageID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postLikePageWithUserId:(NSString *)userID AndAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

//PAGEUPDATES ENDPOINT
-(void)getPageUpdatesDetailsWithUpdateId:(NSString *)updateID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postAddPageUpdateWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)getUserCreatedPageUpdatesListWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postDeletePageUpdateWithUpdateId:(NSString *)updateID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;
-(void)postLikePageUpdateWithUpdateId:(NSString *)updateID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate;

@end
