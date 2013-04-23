//
//  RMInstagramSDK.m
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

#import "RMInstagramSDK.h"
#import "AFOAuth2Client.h"

static NSString * const kOAuth2BaseURLString = @"https://instagram.com/";
static NSString * const kServerAPIURL = @"https://api.instagram.com/v1/";
static NSString * const kClientIDString = @"";//COMPLETE WITH YOUR OWN CLIENT ID
static NSString * const kClientSecretString = @"";//COMPLETE WITH YOUR OWN CLIENT SECRET


@implementation RMInstagramSDK
@synthesize clientID = _clientID;
@synthesize params = _params;
@synthesize credential = _credential;
@synthesize scopes = _scopes;
@synthesize loginDelegate = _loginDelegate;

#pragma mark - Singleton creation

+ (RMInstagramSDK *)sharedClient {
    static RMInstagramSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kOAuth2BaseURLString];
        _sharedClient = [RMInstagramSDK clientWithBaseURL:url clientID:kClientIDString secret:kClientSecretString];
        
        //get a previously stored credential
        _sharedClient.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:_sharedClient.serviceProviderIdentifier];
        if (_sharedClient.credential != nil) {
            [_sharedClient setAuthorizationHeaderWithCredential:_sharedClient.credential];
        }
        
    });
    
    return _sharedClient;
}


#pragma mark - INSTAGRAM Login/Logout
//Login
//FIRST REGISTER AN URL SCHEME (into the .plist file) IN THIS FORMAT: ig[CLIENT_ID_STRING]
- (void)authorizeWithScopes:(NSArray *)scopes{
    
    self.scopes = scopes;
    
    NSString* scope = [self.scopes componentsJoinedByString:@"+"];
    
    NSLog(@"SCOPE : %@", scope);
    
    [self authenticateUsingOAuthWithPath:@"oauth/authorize/" scope:scope redirectURI:[NSString stringWithFormat:@"ig%@://authorize", kClientIDString] success:^(AFOAuthCredential *credential) {
        
        
    } failure:^(NSError *error) {
        
    }];
    
}


- (void)authenticateUsingOAuthWithPath:(NSString *)path
                                 scope:(NSString *)scope
                           redirectURI:(NSString *)uri
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    // [mutableParameters setObject:kAFOAuthClientCredentialsGrantType forKey:@"grant_type"];
    [mutableParameters setValue:scope forKey:@"scope"];
    [mutableParameters setValue:uri forKey:@"redirect_uri"];
    [mutableParameters setValue:@"token" forKey:@"response_type"];
    [mutableParameters setValue:@"authorization_code" forKey:@"grant_type"];
    [mutableParameters setValue:kClientSecretString forKey:@"client_secret"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParameters setObject:self.clientID forKey:@"client_id"];
    //[mutableParameters setObject:self.secret forKey:@"client_secret"];
    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    [self clearAuthorizationHeader];
    
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:@"GET" path:path parameters:parameters];
    
    BOOL didOpenOtherApp = NO;
    
    NSLog(@"MutableWeb :%@", mutableRequest.URL);
    
    didOpenOtherApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mutableRequest.URL absoluteString]]];
    
    
}

//Logout
- (void)logout {
    
    self.credential = nil;
    [AFOAuthCredential deleteCredentialWithIdentifier:self.serviceProviderIdentifier];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:kOAuth2BaseURLString]];
    
    for (NSHTTPCookie* cookie in instagramCookies) {
        [cookies deleteCookie:cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
}

//helpers
- (BOOL)isLoginRequired {
    if (self.credential == nil) {
        return YES;
    }
    return NO;
}


- (BOOL)isCredentialExpired {
    if (self.credential.isExpired) {
        return YES;
    }
    return NO;
}


- (BOOL)handleOpenURL:(NSURL *)url{
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }
    NSLog(@"URL FRAGMENT: %@", [url fragment]);
    
    self.params = [self parseURLParams:query];
    NSString *accessToken = [self.params valueForKey:@"access_token"];
    
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!accessToken) {
        //NSString *error = [self.params valueForKey:@"error"];
        
        NSString *errorReason = [self.params valueForKey:@"error_reason"];
        
        //   BOOL userDidCancel = [errorReason isEqualToString:@"user_denied"];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorReason
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return YES;
    }
    
    NSString *refreshToken = [self.params  valueForKey:@"refresh_token"];
    // refreshToken = refreshToken ? refreshToken : [parameters valueForKey:@"refresh_token"];
    
    self.credential = [AFOAuthCredential credentialWithOAuthToken:[self.params valueForKey:@"access_token"] tokenType:[self.params  valueForKey:@"token_type"]];
    [self.credential setRefreshToken:refreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:[[self.params  valueForKey:@"expires_in"] integerValue]]];
    
    [AFOAuthCredential storeCredential:self.credential withIdentifier:self.serviceProviderIdentifier];
    
    [self setAuthorizationHeaderWithCredential:self.credential];
    
    NSLog(@"ACCESS TOKEN: %@", self.credential.accessToken);
    
    //Store the accessToken on userDefaults
    [[NSUserDefaults standardUserDefaults] setObject:self.credential.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //Uncomment the next line if you need to implement the delegate method performLoginFromHandle
    //[_loginDelegate performLoginFromHandle];
    
    return YES;
    
}

- (NSString *)getOwnBaseUrl {
    return [NSString stringWithFormat:@"ig%@://authorize", self.clientID];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}



#pragma mark - INSTAGRAM API REQUESTS
//USERS ENDPOINT
-(void)getUserInfoWithUserID:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER INFO REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getAuthenticatedUserFeedWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/self/feed", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"AUTHENTICATED USER FEED REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserMediaWithUserID:(NSString *)userID Parameters:(NSDictionary *)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/media/recent", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER MEDIA REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getAuthenticatedUserLikedMediaWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/self/media/liked", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"AUTHENTICATED USER LIKED MEDIA REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)searchUserWithQuery:(NSString *)query AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:query forKey:@"q"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER SEARCH REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


//RELATIONSHIPS ENDPOINT

-(void)getFollowedByWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/followed-by", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"AUTHENTICATED USER FOLLOWED-BY REQUEST");
        NSLog(@"Response object: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getRequestedByWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    
    NSString *path =  [NSString stringWithFormat:@"%@users/self/requested-by", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"REQUESTED-BY REQUEST");
        NSLog(@"Response object: %@", responseObject);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getFollowsWithUserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/follows", kServerAPIURL, userID];
    
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"GET FOLLOWS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)getRelationshipWithUserID:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/relationship", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RELATIONSHIP GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)postRelationshipWithAction:(NSString *)action UserId:(NSString *)userID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:action forKey:@"action"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/relationship", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"AUTHENTICATED USER POST RELATIONSHIP REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

//MEDIA ENDPOINT
-(void)getMediaWithMediaID:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@", kServerAPIURL, mediaID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"MEDIA GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getMediaSearchWithParams:(NSDictionary *)mediaParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:mediaParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"MEDIA SEARCH GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getPopularMediaWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/popular", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"POPULAR MEDIA GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

//MEDIA ENDPOINT: METHODS WITHOUT AUTHENTICATION
-(void)getWAMediaSearchWithParams:(NSDictionary *)mediaParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:mediaParams];
    [mutableParameters setValue:kClientIDString forKey:@"client_id"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"MEDIA SEARCH GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


//COMMENTS ENDPOINT
-(void)getCommentsWithMediaID:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/comments", kServerAPIURL, mediaID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"MEDIA COMMENTS GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postCommentWithMediaID:(NSString *)mediaID Text:(NSString *)text AndWithDelegate :(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:text forKey:@"text"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/comments", kServerAPIURL, mediaID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"MEDIA COMMENT POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)deleteCommentWithCommentID:(NSString *)commentID MediaID:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:@"DELETE" forKey:@"_method"]; //SIMULATE A DELETE METHOD ON INSTAGRAM
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/comments/%@", kServerAPIURL, mediaID, commentID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE COMMENT REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
    
}


//LIKES ENDPOINT

-(void)getLikesOfMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/likes", kServerAPIURL, mediaID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"LIKES MEDIA GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)postLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/likes", kServerAPIURL, mediaID];
    
    NSLog(@"PATH: %@", path);
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@" POST LIKE MEDIA REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)removeLikeOnMediaWithMediaId:(NSString *)mediaID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:@"DELETE" forKey:@"_method"]; //SIMULATE A DELETE METHOD ON INSTAGRAM
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@media/%@/likes", kServerAPIURL, mediaID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"DELETE LIKE MEDIA REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


//TAGS ENDPOINT
-(void)getTagInfoWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@tags/%@", kServerAPIURL, tagString];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TAGS GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getRecentTags:(NSString *)tagID WithParams:(NSDictionary *)tagParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:tagParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@tags/%@/media/recent", kServerAPIURL, tagID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TAGS RECENT GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getSearchTagsWithTagName:(NSString *)tagString AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:tagString forKey:@"q"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tags/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TAGS SEARCH GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


//LOCATIONS ENDPOINT
-(void)getLocationInfoWithLocationID:(NSString *)locationID AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@locations/%@", kServerAPIURL, locationID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"LOCATION INFO REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getLocationRecentMediaWithLocationID:(NSString *)locationID Parameters:(NSDictionary *)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@locations/%@/media/recent", kServerAPIURL, locationID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"LOCATION RECENT MEDIA REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)searchLocationWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@locations/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"LOCATION SEARCH REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


//GEOGRAPHIES ENDPOINT

-(void)getGeoWithGeoId:(NSString *)geoId WithParams:(NSDictionary *)geoParams AndWithDelegate:(NSObject<InstagramDelegate> *)delegate {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:geoParams];
    // [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:self.clientID forKey:@"client_id"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@geographies/%@/media/recent", kServerAPIURL, geoId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"GEO GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


//helpers
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}


@end
