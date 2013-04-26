//
//  RMTwitterSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 24/04/13.
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


#import <Social/Social.h>
#import <Accounts/Accounts.h>

@protocol TwitterDelegate <NSObject>


@end

@interface RMTwitterSDK : NSObject

+ (RMTwitterSDK *)sharedClient;

//TIMELINES
//You can pass as Resource Path: mentions_timeline, user_timeline, home_timeline, retweets_of_me.
-(void)getTimelinesResourceWithResourcePath:(NSString *)resourcePath AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//TWEETS
//You can pass as Resource Path: retweets, show, oembed . If you pass as resource path "oembed", then you should pass nil as ID and pass the ID in the parameters dictionary.
-(void)getTweetsResourceWithResourcePath:(NSString *)resourcePath AndID:(NSString *)ID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//You can pass as Resource Path: destroy, update, retweet. For "update" ID should be nil.
-(void)postTweetsResourceWithResourcePath:(NSString *)resourcePath AndID:(NSString *)ID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//This method is for doing a status update with an image.
-(void)postTweetsUpdateWithMedia:(UIImage *)image AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//SEARCH
-(void)getSearchTweetsWithQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//FAVORITES
-(void)getFavoritesListWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//You can pass as Resource Path: destroy, create.
-(void)postFavoritesWithResourcePath:(NSString *)resourcePath AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate; 
//LISTS
//You can pass as Resource Path: list, statuses, subscribers, subscribers/show, members, members/show, subscriptions, ownerships.
-(void)getListsWithResourcePath:(NSString *)resourcePath AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//You can pass as Resource Path: create, update, destroy, members/create, members/create_all, members/destroy, members/destroy_all, subscribers/create, subscribers/destroy.
-(void)postListsWithResourcePath:(NSString *)resourcePath AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//SAVED SEARCHES
//You can pass as Resource Path: list, show. For "list" ID should be nil.
-(void)getSavedSearchesWithResourcePath:(NSString *)resourcePath AndID:(NSString *)ID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//You can pass as Resource Path: create, destroy. For "create" ID should be nil.
-(void)postSavedSearchesWithResourcePath:(NSString *)resourcePath AndID:(NSString *)ID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//PLACES & GEO
//You can pass as Resource Path: id, reverse_geocode, search, similar_places. For "reverse_geocode", "search" and "similar_places" ID should be nil.
-(void)getPlacesAndGeoWithResourcePath:(NSString *)resourcePath AndID:(NSString *)ID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
-(void)postPlacesAndGeoPlaceWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//TRENDS
//You can pass as Resource Path: place, available, closest.
-(void)getTrendsWithResourcePath:(NSString *)resourcePath AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//SPAM REPORTING
-(void)postSpamReportingReportSpamWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//HELP
//You can pass as Resource Path: configuration, languages, privacy, tos. 
-(void)getHelpWithResourcePath:(NSString *)resourcePath AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//This next method has only one parameter: resourceList, which can be a comma separated list of resource families to get current the rate limits for. For example: statuses,friends,trends,help
-(void)getHelpApplicationRateLimitStatusWithResources:(NSString *)resourceList AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;


//FRIENDS AND FOLLOWERS

//You can pass as resource:
//-Friendships: no_retweets/ids , lookup, incoming, outgoing, create, destroy, update, show
//-Friends: ids, list
//-Followers: ids, list

- (void)getFriendsAndFollowersFriendshipsWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)postFriendsAndFollowersFriendshipsWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getFriendsAndFollowersFriendsWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getFriendsAndFollowersFollowersWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//USERS

//You can pass as resource:
//-Account: settings, verify_credentials, update_delivery_device, update_profile, update_profile_background_image, update_profile_colors, update_profile_image, remove_profile_banner, update_profile_banner
//-Blocks: list, ids, create, destroy
//-Users: lookup, show, search, contributees, contributors, profile_banner

- (void)getUsersAccountWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)postUsersAccountWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getUsersBlocksWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)postUsersBlocksWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getUsersUsersWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)postUsersAccountWithResourcePath:(NSString *)resource AndImage:(UIImage *)image AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//- (void)postUsersAccountWithResourcePath:(NSString *)resource AndBanner:(UIImage *)banner AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
//SUGGESTED USERS

- (void)getUsersSuggestionsWithSlug:(NSString *)slug AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getUsersSuggestionsWithParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
- (void)getUsersSuggestionsMembersWithSlug:(NSString *)slug AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;

//STREAMING
/*
 //You can pass as resource: filter, sample, firehose
 - (void)getStreamingResourceWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 - (void)postStreamingResourceWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 - (void)getStreamingUserWithParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 - (void)getStreamingSiteWithParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 
 //DIRECT MESSAGES
 
 //You can pass as resource: sent, show, destroy, new
 - (void)getDirectMessagesWithParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 - (void)getDirectMessagesResourceWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 - (void)postDirectMessagesResourceWithResourcePath:(NSString *)resource AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <TwitterDelegate> *)delegate;
 */

@end
