//
//  RMOrkutSDK.m
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

#import "RMOrkutSDK.h"
#import "AFJSONRequestOperation.h"

static NSString * const kOAuth2BaseURLString = @"https://accounts.google.com/o/";
static NSString * const kServerAPIURL = @"https://accounts.google.com/o/";
static NSString * const kClientIDString = @"";//FILL IN WITH YOUR OWN DATA
static NSString * const kClientSecretString = @"";//FILL IN WITH YOUR OWN DATA

@implementation RMOrkutSDK

+ (RMOrkutSDK *)sharedClient {
    static RMOrkutSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kOAuth2BaseURLString];
        _sharedClient = [RMOrkutSDK clientWithBaseURL:url clientID:kClientIDString secret:kClientSecretString];
        
        
        _sharedClient.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:_sharedClient.serviceProviderIdentifier];
        if (_sharedClient.credential != nil) {
            [_sharedClient setAuthorizationHeaderWithCredential:_sharedClient.credential];
        }
        
        
    });
    
    return _sharedClient;
}

-(void)authenticateWithScopes:(NSString *)scopes{
    
    [self authenticateUsingOAuthWithPath:@"oauth2/auth" scope:scopes redirectURI:@"urn:ietf:wg:oauth:2.0:oob" success:^(AFOAuthCredential *credential) {
        
        NSLog(@"Success ? ");
        
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
    [mutableParameters setValue:@"code" forKey:@"response_type"];
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
    
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    
    NSLog(@"MutableWeb :%@", request.URL);
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 460)];
    self.webView.delegate = self;
    [self.webView loadRequest:request];

    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
    
    NSLog(@"HTML: %@", html);
    
    NSString *code = [self.webView stringByEvaluatingJavaScriptFromString:
                      @"document.getElementById('code').value"];
    
    NSLog(@"CODE: %@", code);
        
    if (code.length > 0)
    {
        [self.webView removeFromSuperview];
        [self makeTokenRequestWithCode:code];
    }
}

-(void)makeTokenRequestWithCode:(NSString *)code{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code",
                            kClientIDString, @"client_id",
                            kClientSecretString, @"client_secret",
                            @"urn:ietf:wg:oauth:2.0:oob", @"redirect_uri",
                            @"authorization_code", @"grant_type",nil];
    [self postPath:@"https://accounts.google.com/o/oauth2/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
                   NSLog(@"Response: %@", json);
        
                    NSString *accessToken = [json objectForKey:@"access_token"];
                    NSString *refresh_token = [json objectForKey:@"refresh_token"];
                    NSString *expires = [json objectForKey:@"expires_in"];
                    NSString *tokenType = [json objectForKey:@"token_type"];

        
                    if (accessToken)
                    {
                        self.credential = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:tokenType];
                        [self.credential setRefreshToken:refresh_token expiration:[NSDate dateWithTimeIntervalSinceNow:[expires integerValue]]];
                        [AFOAuthCredential storeCredential:self.credential withIdentifier:self.serviceProviderIdentifier];
        
                        [self setAuthorizationHeaderWithCredential:self.credential];
        
                        NSLog(@"ACCESS TOKEN: %@", self.credential.accessToken);
        
                        //Store the accessToken on userDefaults
                        [[NSUserDefaults standardUserDefaults] setObject:self.credential.accessToken forKey:@"accessToken"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [_loginDelegate performLoginFromHandle];
                    }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)deleteAclWithActivityId:(NSString *)activityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/acl/%@", activityId, userId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}

-(void)getActivitiesListWithCollection:(NSString *)collection WithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/people/%@/activities/%@", userId, collection];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteActivityWithActivityId:(NSString *)activityId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@", activityId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getActivityVisibilityWithActivityId:(NSString *)activityId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
   
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/visibility", activityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)putActivityVisibilityWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
      NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    
     NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/visibility", activityId];
    
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [self putPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)patchActivityVisibilityWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    //[mutableParameters setValue:kClientIDString forKey:@"key"];

     NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/visibility", activityId];
    
    self.parameterEncoding = AFJSONParameterEncoding;

    [self patchPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getBadgesListWithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
      NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
     NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/people/%@/badges", userId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getBadgesWithUserId:(NSString *)userId WithBadgeId:(NSString *)badgeId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
      NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
     NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/people/%@/badges/%@", userId, badgeId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommentsListWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/comments", activityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommentWithCommentId:(NSString *)commentId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/comments/%@", commentId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommentWithActivityId:(NSString *)activityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
   
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/%@/comments", activityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteCommentWithCommentId:(NSString *)commentId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/comments/%@", commentId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCountersListWithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/people/%@/counters", userId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunitiesWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@", communityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunitiesListWithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/people/%@/communities", userId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteCommunityFollowWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/followers/%@", communityId, userId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityFollowWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/followers/%@", communityId, userId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/members/%@", communityId, userId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/members/%@", communityId, userId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityMembersWithCommunityId:(NSString *)communityId WithUserId:(NSString *)userId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/members/%@", communityId, userId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityMembersListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/members", communityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteCommunityMessagesWithCommunityId:(NSString *)communityId WithMessageId:(NSString *)messageId WithTopicId:(NSString *)topicId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics/%@/messages/%@", communityId, topicId, messageId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityMessagesWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics/%@/messages", communityId, topicId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityMessagesListWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics/%@/messages", communityId, topicId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityPollCommentsWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/polls/%@/comments", communityId, pollId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityPollCommentListWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/polls/%@/comments", communityId, pollId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityPollVotesWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
      NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/polls/%@/votes", communityId, pollId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityPollsWithCommunityId:(NSString *)communityId WithPollId:(NSString *)pollId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/polls/%@", communityId, pollId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityPollsListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/polls", communityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityRelatedListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/related", communityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)deleteCommunityTopicsWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
     NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics/%@", communityId, topicId];
    
    [self deletePath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityTopicsWithCommunityId:(NSString *)communityId WithTopicId:(NSString *)topicId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics/%@", communityId, topicId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postCommunityTopicsWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics", communityId];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)getCommunityTopicsListWithCommunityId:(NSString *)communityId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/communities/%@/topics", communityId];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}

-(void)postScrapsWithDelegate:(NSObject <OrkutDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"https://www.googleapis.com/orkut/v2/activities/scraps"];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);

    }];
}
@end
