//
//  RMDeviantArtSDK.h
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 03/05/13
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

@protocol DeviantArtDelegate <NSObject>
@optional
-(void)performLoginFromHandle;

@end

@interface RMDeviantArtSDK : AFOAuth2Client

@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) AFOAuthCredential *credential;
@property (nonatomic, strong) NSObject <DeviantArtDelegate> *loginDelegate;

+ (RMDeviantArtSDK *)sharedClient;
-(void)authenticate;
- (BOOL)handleOpenURL:(NSURL *)url;

-(void)refreshAccessToken;

-(void)getUserInfoWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)getUserdAmnAuthTokenWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)postSubmitOnStaWithFile:(NSData *)uploadFile Parameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)postDeleteOnStaWithStashId:(NSString *)stashid AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)postMoveFileOnStaWithStashId:(NSString *)stashid Parameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)postRenameFolderOnStaWithFolder:(NSString *)newFolder WithFolderId:(NSString *)folderId AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)getAvailibleSpaceOnStaWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)getListFoldersAndSubmissionsOnStaWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;
-(void)postFetchFolderAndSubmissionDataOnStaWithStashId:(NSString *)stashid WithFolderId:(NSString *)folderId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate; // Double-check this method
-(void)postFetchSubmissionMediaOnStaWithStashId:(NSString *)stashid AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate;


@end
