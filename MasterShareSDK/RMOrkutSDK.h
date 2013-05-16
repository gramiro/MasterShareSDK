//
//  RMOrkutSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 06/05/13
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

#import "AFOAuth2Client.h"

@protocol OrkutDelegate <NSObject>
@optional
-(void)performLoginFromHandle;
@end

@interface RMOrkutSDK : AFOAuth2Client <UIWebViewDelegate>


@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;
@property (nonatomic, strong) NSObject <OrkutDelegate> *loginDelegate;
@property (nonatomic, strong) UIWebView *webView;

+ (RMOrkutSDK *)sharedClient;
-(void)authenticateWithScopes:(NSString *)scopes;

-(void)deleteAclWithActivityId:(NSString *)activityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getActivitiesListWithCollection:(NSString *)collection WithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteActivityWithActivityId:(NSString *)activityId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getActivityVisibilityWithActivityId:(NSString *)activityId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)putActivityVisibilityWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)patchActivityVisibilityWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getBadgesListWithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getBadgesWithUserId:(NSString *)userId WithBadgeId:(NSString *)badgeId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommentsListWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommentWithCommentId:(NSString *)commentId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommentWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteCommentWithCommentId:(NSString *)commentId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCountersListWithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunitiesWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunitiesListWithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteCommunityFollowWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityFollowWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityMembersListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteCommunityMessagesWithCommunityId:(NSString *)communityId WithMessageId:(NSString *)messageId WithTopicId:(NSString *)topicId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityMessagesWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityMessagesListWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityPollCommentsWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityPollCommentListWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityPollVotesWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityPollsWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityPollsListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityRelatedListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)deleteCommunityTopicsWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityTopicsWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postCommunityTopicsWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)getCommunityTopicsListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate;
-(void)postScrapsWithDelegate:(NSObject <OrkutDelegate> *)delegate;









@end
