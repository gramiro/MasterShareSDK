//
//  RMGooglePlusSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 5/3/13.
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
#import "AFNetworking.h"

@protocol GooglePlusDelegate <NSObject>


@end

@interface RMGooglePlusSDK : AFHTTPClient

+ (RMGooglePlusSDK *)sharedClient;

//PEOPLE RESOURCE
-(void)getPublicPeopleProfileWithUserId:(NSString *)userID AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;
-(void)getPeopleSearchWithQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;
-(void)getPeopleListByActivityWithActivityId:(NSString *)activityID AndCollection:(NSString *)collection AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;

//ACTIVITIES RESOURCE
-(void)getPublicActivitiesListWithUserId:(NSString *)userID AndCollection:(NSString *)collection AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;
-(void)getActivityWithActivityId:(NSString *)activityID AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;
-(void)getActivitySearchWithQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;

//COMMENTS RESOURCE
-(void)getCommentsListWithActivityId:(NSString *)activityID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;
-(void)getCommentWithCommentId:(NSString *)commentID AndWithDelegate:(NSObject <GooglePlusDelegate> *)delegate;


@end
