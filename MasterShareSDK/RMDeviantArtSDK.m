//
//  RMDeviantArtSDK.m
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

#import "RMDeviantArtSDK.h"
#import "AFJSONRequestOperation.h"

static NSString * const kOAuth2BaseURLString = @"https://www.deviantart.com/oauth2/draft10/";
static NSString * const kServerAPIURL = @"https://www.deviantart.com/api/draft10/";
static NSString * const kClientIDString = @"";//FILL IN WITH YOUR OWN DATA
static NSString * const kClientSecretString = @"";//FILL IN WITH YOUR OWN DATA

@implementation RMDeviantArtSDK

+ (RMDeviantArtSDK *)sharedClient {
    static RMDeviantArtSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kOAuth2BaseURLString];
        _sharedClient = [RMDeviantArtSDK clientWithBaseURL:url clientID:kClientIDString secret:kClientSecretString];
        
        _sharedClient.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:_sharedClient.serviceProviderIdentifier];
        if (_sharedClient.credential != nil) {
            [_sharedClient setAuthorizationHeaderWithCredential:_sharedClient.credential];
        }
        
        
    });
    
    return _sharedClient;
}

-(void)authenticate {
    
    [self authenticateUsingOAuthWithPath:@"authorize" scope:nil redirectURI:@"dvntart://oauth2" success:^(AFOAuthCredential *credential) {
        
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
    //[mutableParameters setValue:scope forKey:@"scope"];
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
    
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:@"GET" path:path parameters:parameters];
    
    BOOL didOpenOtherApp = NO;
    
    NSLog(@"MutableWeb :%@", mutableRequest.URL);
    
    didOpenOtherApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mutableRequest.URL absoluteString]]];
    
}


- (BOOL)handleOpenURL:(NSURL *)url{
    

    NSString *query = [NSString stringWithFormat:@"%@",url];
    if (!query) {
        query = [url query];
    }
    
    self.params = [self parseURLParams:query];
    
    NSString *code = nil;

    if ([self.params valueForKey:@"dvntart://oauth2?code"])
         code = [self.params valueForKey:@"dvntart://oauth2?code"];
    
    
    if (code)
    {
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"authorization_code",@"grant_type",
                                code,@"code",
                                kClientIDString, @"client_id",
                                kClientSecretString, @"client_secret", nil];
        
        [self getPath:@"https://www.deviantart.com/oauth2/draft10/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response: %@", json);

            NSString *accessToken = [json objectForKey:@"access_token"];
            NSString *refresh_token = [json objectForKey:@"refresh_token"];
            NSString *expires = [json objectForKey:@"expires_in"];


            if (accessToken)
            {
                self.credential = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:nil];
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

-(void)refreshAccessToken {
    
    NSString *accessToken = self.credential.accessToken;
    NSLog(@"Access Token: %@", accessToken);
    
    NSString *refreshToken = self.credential.refreshToken;
    
    NSLog(@"Refresh Token: %@", refreshToken);
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:accessToken, @"access_token", nil];
    
    [self getPath:@"https://www.deviantart.com/api/draft10/placebo" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response: %@", json);
        
        NSString *status = [json objectForKey:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            NSLog(@"Access Token is still valid!");
        }
        else {
            NSLog(@"Access Token is expired, getting new Access Token...");
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"refresh_token",@"grant_type",
                                    refreshToken, @"refresh_token",
                                    kClientIDString, @"client_id",
                                    kClientSecretString, @"client_secret", nil];
            
            [self getPath:@"https://www.deviantart.com/oauth2/draft10/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                
                NSLog(@"Response: %@", json);
                
                NSString *accessToken = [json objectForKey:@"access_token"];
                NSString *refresh_token = [json objectForKey:@"refresh_token"];
                NSString *expires = [json objectForKey:@"expires_in"];
                
                
                if (accessToken)
                {
                    self.credential = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:nil];
                    [self.credential setRefreshToken:refresh_token expiration:[NSDate dateWithTimeIntervalSinceNow:[expires integerValue]]];
                    
                    [AFOAuthCredential storeCredential:self.credential withIdentifier:self.serviceProviderIdentifier];
                    
                    [self setAuthorizationHeaderWithCredential:self.credential];
                    
                    NSLog(@"ACCESS TOKEN: %@", self.credential.accessToken);
                    
                    //Store the accessToken on userDefaults
                    [[NSUserDefaults standardUserDefaults] setObject:self.credential.accessToken forKey:@"accessToken"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"Failed to refresh Access Token. Error: %@", error);
                
            }];

        }
     
                    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - User Methods

-(void)getUserInfoWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@user/whoami", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getUserdAmnAuthTokenWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@user/damntoken", kServerAPIURL];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

#pragma mark - Sta.sh methods

-(void)postSubmitOnStaWithFile:(NSData *)uploadFile Parameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/submit", kServerAPIURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerAPIURL]];
    NSMutableURLRequest *afRequest = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                           path:path
                                                                     parameters:parameters
                                                      constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:uploadFile
                                                                      name:@"media"
                                                                  fileName:@"asd"
                                                                  mimeType:@"image/jpeg"];
                                      }
                                      ];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"%@", operation.responseString); //Gives a very scary warning
    }];
    
    [operation start];
}

-(void)postDeleteOnStaWithStashId:(NSString *)stashid AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:stashid forKey:@"stashid"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/delete", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postMoveFileOnStaWithStashId:(NSString *)stashid Parameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:stashid forKey:@"stashid"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/move", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postRenameFolderOnStaWithFolder:(NSString *)newFolder WithFolderId:(NSString *)folderId AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:newFolder forKey:@"folder"];
    [mutableParameters setValue:folderId forKey:@"folderid"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/folder", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)getAvailibleSpaceOnStaWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/space", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR: %@", error);
        
    }];
    
}

-(void)getListFoldersAndSubmissionsOnStaWithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/delta", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

-(void)postFetchFolderAndSubmissionDataOnStaWithStashId:(NSString *)stashid WithFolderId:(NSString *)folderId WithParameters:(NSDictionary *)params AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:stashid forKey:@"stashid"];
    [mutableParameters setValue:folderId forKey:@"folderid"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/metadata", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
    
}

-(void)postFetchSubmissionMediaOnStaWithStashId:(NSString *)stashid AndWithDelegate:(NSObject <DeviantArtDelegate> *)delegate{
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:self.credential.accessToken forKey:@"access_token"];
    [mutableParameters setValue:stashid forKey:@"stashid"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path =  [NSString stringWithFormat:@"%@stash/media", kServerAPIURL];
    
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"USER Data REQUEST");
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"Response object: %@", data);        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}


@end
