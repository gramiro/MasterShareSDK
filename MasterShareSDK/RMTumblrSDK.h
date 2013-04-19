//
//  RMTumblrSDK.h
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

#import "AFOAuth1Client.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"

@protocol TumblrDelegate <NSObject>

@end

@interface RMTumblrSDK : AFOAuth1Client

+ (RMTumblrSDK *)sharedClient;

//NOTE: READ THIS TUMBLR API WEB DOCUMENTATION (requests parameters, etc): http://www.tumblr.com/docs/en/api/v2

//BLOG METHODS
//Base Hostname: The standard or custom blog hostname
-(void)getBlogInfoWithBaseHostname:(NSString *)baseHostname AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: API Key
-(void)getBlogAvatarWithBaseHostname:(NSString *)baseHostname AndSize:(NSString *)avatarSize AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: None
-(void)getBlogLikesWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: API Key
-(void)getBlogFollowersWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getBlogPublishedPostsWithBaseHostname:(NSString *)baseHostname AndPostType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: API Key
-(void)getBlogQueuedPostsWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndFilter:(NSString *)filter AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getBlogDraftPostsWithBaseHostname:(NSString *)baseHostname AndFilter:(NSString *)filter AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getBlogSubmissionPostsWithBaseHostname:(NSString *)baseHostname AndOffset:(NSString *)offset AndFilter:(NSString *)filter AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogTEXTPostWithBaseHostname:(NSString *)baseHostname AndBody:(NSString *)body AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
//post creation:
-(void)postCreateANewBlogPHOTOPostWithBaseHostname:(NSString *)baseHostname AndSource:(NSString *)source OrImage:(UIImage *)image AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogQUOTEPostWithBaseHostname:(NSString *)baseHostname AndQuote:(NSString *)quote AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogLINKPostWithBaseHostname:(NSString *)baseHostname AndLink:(NSString *)link AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogCHATPostWithBaseHostname:(NSString *)baseHostname AndConversation:(NSString *)conversation AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogAUDIOPostWithBaseHostname:(NSString *)baseHostname AndSource:(NSString *)external_url OrAudioData:(NSData *)audioData AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postCreateANewBlogVIDEOPostWithBaseHostname:(NSString *)baseHostname AndCaption:(NSString *)caption AndEmbedCode:(NSString *)embedCode OrVideoData:(NSData *)videoData AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
//post edit/reblog/delete:
-(void)postEditPostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postReblogPostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndReblogKey:(NSString *)reblog_key AndType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postDeletePostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndWithDelegate:(NSObject<TumblrDelegate> *)delegate;//authentication: OAuth


//USER METHODS
-(void)getUserInfoWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getUserDashboardWithPostType:(NSString *)type AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getUserLikesWithLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)getUserFollowingWithLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postUserFollowBlogWithBlogURL:(NSString *)url AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postUserUnfollowBlogWithBlogURL:(NSString *)url AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postUserLikePostWithPostId:(NSString *)postID AndReblogKey:(NSString *)reblogKey AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth
-(void)postUserUnlikePostWithPostId:(NSString *)postID AndReblogKey:(NSString *)reblogKey AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: OAuth

//TAGGED METHOD
-(void)getPostsWithTag:(NSString *)tag AndLimit:(NSString *)limit AndFilter:(NSString *)filter AndBefore:(NSString *)before AndWithDelegate:(NSObject <TumblrDelegate> *)delegate;//authentication: API Key


@end
