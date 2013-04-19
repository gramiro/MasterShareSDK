//
//  RMFoursquareSDK.m
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


#import "RMFoursquareSDK.h"

#import "AFJSONRequestOperation.h"

static NSString * const kOAuth2BaseURLString = @"https://foursquare.com/";
static NSString * const kServerAPIURL = @"https://api.foursquare.com/v2/";
static NSString * const kClientIDString = @"";//COMPLETE WITH YOUR OWN CLIENT_ID
static NSString * const kClientSecretString = @"";//COMPLETE WITH YOUR OWN CLIENT_SECRET

@implementation RMFoursquareSDK

+ (RMFoursquareSDK *)sharedClient {
    static RMFoursquareSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kOAuth2BaseURLString];
        _sharedClient = [RMFoursquareSDK clientWithBaseURL:url clientID:kClientIDString secret:kClientSecretString];
        
        _sharedClient.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:_sharedClient.serviceProviderIdentifier];
        if (_sharedClient.credential != nil) {
            [_sharedClient setAuthorizationHeaderWithCredential:_sharedClient.credential];
        }
        
        
    });
    
    return _sharedClient;
}

-(void)authenticate {
    
    [self authenticateUsingOAuthWithPath:@"oauth2/authenticate" scope:nil redirectURI:@"fsqad1qbewhczwatqnpfjoet2rd3lozoxvhax534nx30uobnx12://authorize" success:^(AFOAuthCredential *credential) {
        
        
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
    //[mutableParameters setValue:scope forKey:@"scope"];
    [mutableParameters setValue:uri forKey:@"redirect_uri"];
    [mutableParameters setValue:@"token" forKey:@"response_type"];
    //[mutableParameters setValue:@"authorization_code" forKey:@"grant_type"];
    //[mutableParameters setValue:kClientSecretString forKey:@"client_secret"];
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
        //     [self igDidNotLogin:userDidCancel];
        
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
    
    
    //     [self igDidLogin:accessToken/* expirationDate:expirationDate*/];
    return YES;
    
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

#pragma mark - FOURSQUARE API REQUESTS
//USERS ENDPOINT
-(void)getUserDataWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getLeaderboardsWithNeighborsParameter:(NSString *)neighbors AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if (neighbors)
        [mutableParameters setValue:neighbors forKey:@"neighbors"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/leaderboard", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Leaderboards REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getRequestsWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/requests", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Requests REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getSearchUserWithName:(NSString *)name AndParameters:(NSDictionary *)searchParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([searchParams objectForKey:@"phone"])
        [mutableParameters setValue:[searchParams objectForKey:@"phone"] forKey:@"phone"];
    if ([searchParams objectForKey:@"email"])
        [mutableParameters setValue:[searchParams objectForKey:@"email"] forKey:@"email"];
    if ([searchParams objectForKey:@"twitter"])
        [mutableParameters setValue:[searchParams objectForKey:@"twitter"] forKey:@"twitter"];
    if ([searchParams objectForKey:@"twitterSource"])
        [mutableParameters setValue:[searchParams objectForKey:@"twitterSource"] forKey:@"twitterSource"];
    if ([searchParams objectForKey:@"fbid"])
        [mutableParameters setValue:[searchParams objectForKey:@"fbid"] forKey:@"fbid"];
    
    if (name)
        [mutableParameters setValue:name forKey:@"name"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/leaderboard", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Search REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserBadgesWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/badges", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Badges REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

//For now ONLY SELF SUPPORTED - Foursquare API says.

-(void)getUserCheckinsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)checkinsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([checkinsParam objectForKey:@"limit"])
        [mutableParameters setValue:[checkinsParam objectForKey:@"limit"] forKey:@"limit"];
    if ([checkinsParam objectForKey:@"offset"])
        [mutableParameters setValue:[checkinsParam objectForKey:@"offset"] forKey:@"offset"];
    if ([checkinsParam objectForKey:@"sort"])
        [mutableParameters setValue:[checkinsParam objectForKey:@"sort"] forKey:@"sort"];
    if ([checkinsParam objectForKey:@"afterTimestamp"])
        [mutableParameters setValue:[checkinsParam objectForKey:@"afterTimestamp"] forKey:@"afterTimestamp"];
    if ([checkinsParam objectForKey:@"beforeTimestamp"])
        [mutableParameters setValue:[checkinsParam objectForKey:@"beforeTimestamp"] forKey:@"beforeTimestamp"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/checkins", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Checkins REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserFriendsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)friendsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([friendsParam objectForKey:@"limit"])
        [mutableParameters setValue:[friendsParam objectForKey:@"limit"] forKey:@"limit"];
    if ([friendsParam objectForKey:@"offset"])
        [mutableParameters setValue:[friendsParam objectForKey:@"offset"] forKey:@"offset"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/friends", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Friends REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserListsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)listsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([listsParam objectForKey:@"group"])
        [mutableParameters setValue:[listsParam objectForKey:@"group"] forKey:@"group"];
    if ([listsParam objectForKey:@"ll"])
        [mutableParameters setValue:[listsParam objectForKey:@"ll"] forKey:@"ll"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/lists", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Lists REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserMayorshipsWithUserId:(NSString *)userID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/mayorships", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Mayorship REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

//For now ONLY SELF SUPPORTED - Foursquare API says.

-(void)getUserPhotosWithUserId:(NSString *)userID AndParameters:(NSDictionary *)friendsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([friendsParam objectForKey:@"limit"])
        [mutableParameters setValue:[friendsParam objectForKey:@"limit"] forKey:@"limit"];
    if ([friendsParam objectForKey:@"offset"])
        [mutableParameters setValue:[friendsParam objectForKey:@"offset"] forKey:@"offset"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/photos", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Photos REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getUserTipsWithUserId:(NSString *)userID AndParameters:(NSDictionary *)tipsParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([tipsParam objectForKey:@"sort"])
        [mutableParameters setValue:[tipsParam objectForKey:@"sort"] forKey:@"sort"];
    if ([tipsParam objectForKey:@"ll"])
        [mutableParameters setValue:[tipsParam objectForKey:@"ll"] forKey:@"ll"];
    if ([tipsParam objectForKey:@"limit"])
        [mutableParameters setValue:[tipsParam objectForKey:@"limit"] forKey:@"limit"];
    if ([tipsParam objectForKey:@"offset"])
        [mutableParameters setValue:[tipsParam objectForKey:@"offset"] forKey:@"offset"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/tips", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Tips REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

//For now ONLY SELF SUPPORTED - Foursquare API says.


-(void)getUserVenueHistoryWithUserId:(NSString *)userID AndParameters:(NSDictionary *)vHistoryParam AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if ([vHistoryParam objectForKey:@"beforeTimestamp"])
        [mutableParameters setValue:[vHistoryParam objectForKey:@"beforeTimestamp"] forKey:@"beforeTimestamp"];
    if ([vHistoryParam objectForKey:@"afterTimestamp"])
        [mutableParameters setValue:[vHistoryParam objectForKey:@"afterTimestamp"] forKey:@"afterTimestamp"];
    if ([vHistoryParam objectForKey:@"categoryId"])
        [mutableParameters setValue:[vHistoryParam objectForKey:@"categoryId"] forKey:@"categoryId"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/venuehistory", kServerAPIURL, userID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER VenueHistory REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

//Post Users Methods

-(void)postApproveWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/approve", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postDenyWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/deny", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postRequestWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/request", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postSetPingsWithUserId:(NSString *)userID AndValue:(NSString *)value AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:value forKey:@"value"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/setpings", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postUnfriendWithUserId:(NSString *)userID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/%@/unfriend", kServerAPIURL, userID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postUpdateWithPhoto:(UIImage *)photo AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:photo forKey:@"photo"];
    
    NSData* uploadFile = nil;
	if ([mutableParameters objectForKey:@"photo"]) {
		uploadFile = (NSData*)UIImageJPEGRepresentation([mutableParameters objectForKey:@"photo"],70);
		[mutableParameters removeObjectForKey:@"photo"];
	}
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@users/self/update", kServerAPIURL];
    
    NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		if (uploadFile) {
			[formData appendPartWithFileData:uploadFile name:@"photo" fileName:@"text.jpg" mimeType:@"image/jpeg"];
		}
	}];
    
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
        NSLog(@"SUCCESS! :D, %@", responseObject);
        // completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE :(");
        //failure :(
        // completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    [operation start];
    
}


//VENUES ENDPOINT
-(void)getVenueDetailsWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE details REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postAddVenueWithName:(NSString *)name AndLatitudeLongitude:(NSDictionary *)coords AndParameters:(NSDictionary *)venueParams AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:venueParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    [mutableParameters setValue:name forKey:@"name"];
    NSString *ll = [NSString stringWithFormat:@"%@,%@", [coords objectForKey:@"latitude"], [coords objectForKey:@"longitude"]];
    [mutableParameters setValue:ll forKey:@"ll"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/add", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getVenueCategoriesWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/categories", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE CATEGORIES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getExploreVenuesWithLatitudeLongitude:(NSDictionary *)coords OrNear:(NSString *)near AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if (coords) {
        NSString *ll = [NSString stringWithFormat:@"%@,%@", [coords objectForKey:@"latitude"], [coords objectForKey:@"longitude"]];
        [mutableParameters setValue:ll forKey:@"ll"];
    }
    if (near) {
        [mutableParameters setValue:near forKey:@"near"];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/explore", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"EXPLORE VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getManagedVenuesWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/managed", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"MANAGED VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getSearchVenuesWithLatitudeLongitude:(NSDictionary *)coords OrNear:(NSString *)near AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    if (coords) {
        NSString *ll = [NSString stringWithFormat:@"%@,%@", [coords objectForKey:@"latitude"], [coords objectForKey:@"longitude"]];
        [mutableParameters setValue:ll forKey:@"ll"];
    }
    if (near) {
        [mutableParameters setValue:near forKey:@"near"];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/search", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"SEARCH VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getSuggestCompletionVenuesWithLatitudeLongitude:(NSDictionary *)coords AndQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    
    NSString *ll = [NSString stringWithFormat:@"%@,%@", [coords objectForKey:@"latitude"], [coords objectForKey:@"longitude"]];
    [mutableParameters setValue:ll forKey:@"ll"];
    [mutableParameters setValue:query forKey:@"query"];
    
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/suggestcompletion", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"SUGGEST COMPLETION VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueTimeSeriesDataWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/timeseries", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE TIME SERIES DATA REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getTrendingVenuesWithLatitudeLongitude:(NSDictionary *)coords AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSString *ll = [NSString stringWithFormat:@"%@,%@", [coords objectForKey:@"latitude"], [coords objectForKey:@"longitude"]];
    [mutableParameters setValue:ll forKey:@"ll"];
    
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/trending", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TRENDING VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueEventsWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/events", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE EVENTS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueHereNowWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/herenow", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE HERE NOW REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)getVenueHoursWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/hours", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE HOURS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getVenueLikesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/likes", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE LIKES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
    
}


-(void)getVenueLinksWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/links", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE LINKS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getVenueListsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/listed", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE LISTS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)getVenueMenuWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/menu", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE MENU REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueNextVenuesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/nextvenues", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"NEXT VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getVenuePhotosWithVenueId:(NSString *)venueID AndGroup:(NSString *)group AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    [mutableParameters setValue:group forKey:@"group"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/photos", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE PHOTOS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueSimilarVenuesWithVenueId:(NSString *)venueID AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/similar", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"SIMILAR VENUES REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueStatsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/stats", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE STATS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)getVenueTipsWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/tips", kServerAPIURL, venueID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"VENUE TIPS REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)postDislikeVenueWithWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/dislike", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DISLIKE VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


-(void)postEditVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/edit", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"EDIT VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)postFlagVenueWithVenueId:(NSString *)venueID AndProblem:(NSString *)problem AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    [mutableParameters setValue:problem forKey:@"problem"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/flag", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FLAG VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)postLikeVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/like", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"LIKE VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)postProposeEditVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/proposeedit", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"PROPOSE EDIT VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}


-(void)postSetUserRoleForVenueWithVenueId:(NSString *)venueID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<FoursquareDelegate> *)delegate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@venues/%@/setrole", kServerAPIURL, venueID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SET USER ROLE FOR VENUE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

//CHECKINS ENDPOINT
-(void)getCheckinDataWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)checkinParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:checkinParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@", kServerAPIURL, checkinID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"CHECKIN REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postAddCheckinWithvenueId:(NSString *)venueId WithParameters:(NSDictionary *)addParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:addParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:venueId forKey:@"venueId"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/add", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST ADD CHECKIN POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getRecentCheckinsWithParameters:(NSDictionary *)recentCheckinParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:recentCheckinParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/recent", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"CHECKIN REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getCheckinLikesWithCheckinId:(NSString *)checkinID AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/likes", kServerAPIURL, checkinID];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"CHECKIN REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)postAddCommentInCheckinWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)commentParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:commentParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/addcomment", kServerAPIURL, checkinID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST ADD COMMENT POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postAddPostInCheckinWithCheckinId:(NSString *)checkinID WithParameters:(NSDictionary *)postParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:postParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/addpost", kServerAPIURL, checkinID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST ADD POST POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postDeleteCommentInCheckinWithCheckinId:(NSString *)checkinID WithCommentID:(NSString *)commentId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:commentId forKey:@"commentId"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/deletecomment", kServerAPIURL, checkinID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST DELETE COMMENT POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)postAddOrRemoveLikeInCheckinWithCheckinId:(NSString *)checkinID WithAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:set forKey:@"set"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/like", kServerAPIURL, checkinID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST ADD OR REMOVE LIKE POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)postReplyWithCheckinId:(NSString *)checkinID WithText:(NSString *)text WithParams:(NSDictionary *)replyParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:replyParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:text forKey:@"text"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/checkins/%@/reply", kServerAPIURL, checkinID];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST REPLY POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

//TIPS ENDPOINT

-(void)getTipDataWithTipId:(NSString *)tipId WithParameters:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:tipParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@", kServerAPIURL, tipId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TIP GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postTipWithVenueId:(NSString *)venueId WithText:(NSString *)text WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:tipParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:text forKey:@"text"];
    [mutableParameters setValue:venueId forKey:@"venueId"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/add", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TIP POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getTipLikesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/likes", kServerAPIURL, tipId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TIP GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getTipListsWithTipId:(NSString *)tipId WithParameters:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:tipParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/listed", kServerAPIURL, tipId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TIP GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getTipSavesWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/saves", kServerAPIURL, tipId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TIP GET REQUEST");
        NSLog(@"Response object: %@", responseObject);
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postFlagATipWithTipId:(NSString *)tipId WithProblem:(NSString *)problem WithParams:(NSDictionary *)tipParams AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:tipParams];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:problem forKey:@"problem"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/flag", kServerAPIURL, tipId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TIP POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postAddOrRemoveLikeATipWithTipId:(NSString *)tipId WithAction:(NSString *)set AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    [mutableParameters setValue:set forKey:@"set"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/like", kServerAPIURL, tipId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TIP POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postUnmarkTipWithTipId:(NSString *)tipId AndWithDelegate:(NSObject <FoursquareDelegate> *)delegate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:[[NSString stringWithFormat:@"%@",[NSDate date]] substringToIndex:10]];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateForFS = [dateFormat stringFromDate:date];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"oauth_token"];
    [mutableParameters setValue:dateForFS forKey:@"v"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@/tips/%@/unmark", kServerAPIURL, tipId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TIP POST REQUEST");
        NSLog(@"Response object: %@", responseObject);
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