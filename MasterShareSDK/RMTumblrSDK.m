//
//  RMTumblrSDK.m
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

#import "RMTumblrSDK.h"
#import "AFImageRequestOperation.h"

static NSString * const kOAuth1BaseURLString = @"http://www.tumblr.com";
static NSString * const kConsumerKeyString = @"";//COMPLETE WITH YOUR OWN KEY
static NSString * const kConsumerSecretString = @"";//COMPLETE WITH YOUR OWN SECRET

@implementation RMTumblrSDK

+ (RMTumblrSDK *)sharedClient {
    static RMTumblrSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[RMTumblrSDK alloc] initWithBaseURL:[NSURL URLWithString:kOAuth1BaseURLString] key:kConsumerKeyString secret:kConsumerSecretString];
        [_sharedClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [_sharedClient setDefaultHeader:@"Accept" value:@"application/json"];
        
    });
    
    return _sharedClient;
}

//BLOG METHODS
-(void)getBlogInfoWithBaseHostname:(NSString *)baseHostname AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/info", baseHostname];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"BLOG INFO REQUEST");
        
        NSLog(@"Response object: %@", responseObject);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
    
}


//This method gets the avatar image and not a JSON response
-(void)getBlogAvatarWithBaseHostname:(NSString *)baseHostname AndSize:(NSString *)avatarSize AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    NSString *path;
    
    if (avatarSize) {
        path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/avatar/%@", baseHostname, avatarSize];
    }
    else {
        path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/avatar", baseHostname];
    }
    
    [self registerHTTPOperationClass:[AFImageRequestOperation class]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    AFImageRequestOperation *operation;
    operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        NSLog(@"SUCCESS!");
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error retrieving image: %@", error);
    }];
    
    [operation start];
    
}

-(void)getBlogLikesWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
    
    if (limit) {
        [mutableParameters setValue:limit forKey:@"limit"];
    }
    if (offset) {
        [mutableParameters setValue:offset forKey:@"offset"];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/likes", baseHostname];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"BLOG LIKES REQUEST");
        
        NSLog(@"Response object: %@", responseObject);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
    
}

-(void)getBlogFollowersWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (limit) {
            [mutableParameters setValue:limit forKey:@"limit"];
        }
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/followers", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"BLOG FOLLOWERS REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)getBlogPublishedPostsWithBaseHostname:(NSString *)baseHostname AndPostType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path;
    
    if (type) {
        path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/posts/%@", baseHostname, type];
    }
    else {
        path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/posts", baseHostname];
    }
    
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"BLOG PUBLISHED POSTS REQUEST");
        
        NSLog(@"Response object: %@", responseObject);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
    
}

-(void)getBlogQueuedPostsWithBaseHostname:(NSString *)baseHostname AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndFilter:(NSString *)filter AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (limit) {
            [mutableParameters setValue:limit forKey:@"limit"];
        }
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        if (filter) {
            [mutableParameters setValue:filter forKey:@"filter"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/posts/queue", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"BLOG QUEUED POSTS REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
}


-(void)getBlogDraftPostsWithBaseHostname:(NSString *)baseHostname AndFilter:(NSString *)filter AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (filter) {
            [mutableParameters setValue:filter forKey:@"filter"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/posts/draft", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"BLOG DRAFT POSTS REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
}

-(void)getBlogSubmissionPostsWithBaseHostname:(NSString *)baseHostname AndOffset:(NSString *)offset AndFilter:(NSString *)filter AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        if (filter) {
            [mutableParameters setValue:filter forKey:@"filter"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/posts/submission", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"BLOG SUBMISSION POSTS REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


//post creation
-(void)postCreateANewBlogTEXTPostWithBaseHostname:(NSString *)baseHostname AndBody:(NSString *)body AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"text" forKey:@"type"];
        [mutableParameters setValue:body forKey:@"body"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"TEXT POST CREATION, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}

//MULTIPLE-Photo-Upload is not implemented yet.

-(void)postCreateANewBlogPHOTOPostWithBaseHostname:(NSString *)baseHostname AndSource:(NSString *)source OrImage:(UIImage *)image AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"photo" forKey:@"type"];
        
        if (source)
            [mutableParameters setValue:source forKey:@"source"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        if (image && !source)
        {
            NSData* uploadFile = nil;
            uploadFile = (NSData*)UIImageJPEGRepresentation(image,70);
            
            
            NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                if (uploadFile) {
                    [formData appendPartWithFileData:uploadFile name:@"data" fileName:@"text.jpg" mimeType:@"image/jpeg"];
                    
                }
            }];
            
            AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //success!
                NSLog(@"SUCCESS UPLOADING PHOTO! :D, %@", responseObject);
                // completionBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"FAILURE :(");
                //failure :(
                // completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
            }];
            [operation start];
            
        }
        else
        {
            [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"PHOTO POST CREATION, POST REQUEST");
                NSLog(@"Response object: %@", responseObject);
                //Complete with delegate call
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"POST ERROR: %@", error);
            }];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}




-(void)postCreateANewBlogQUOTEPostWithBaseHostname:(NSString *)baseHostname AndQuote:(NSString *)quote AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"quote" forKey:@"type"];
        [mutableParameters setValue:quote forKey:@"quote"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"QUOTE POST CREATION, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)postCreateANewBlogLINKPostWithBaseHostname:(NSString *)baseHostname AndLink:(NSString *)link AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"link" forKey:@"type"];
        [mutableParameters setValue:link forKey:@"url"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"LINK POST CREATION, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}

-(void)postCreateANewBlogCHATPostWithBaseHostname:(NSString *)baseHostname AndConversation:(NSString *)conversation AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"chat" forKey:@"type"];
        [mutableParameters setValue:conversation forKey:@"conversation"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"CHAT POST CREATION, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


//This method only accepts MP3 files, please convert to MP3 type the file you want to upload.
-(void)postCreateANewBlogAUDIOPostWithBaseHostname:(NSString *)baseHostname AndSource:(NSString *)external_url OrAudioData:(NSData *)audioData AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"audio" forKey:@"type"];
        
        if (external_url)
            [mutableParameters setValue:external_url forKey:@"external_url"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        if (audioData && !external_url)
        {
            NSData* uploadFile = nil;
            uploadFile = audioData;
            
            
            NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                if (uploadFile) {
                    [formData appendPartWithFileData:uploadFile name:@"data" fileName:@"data" mimeType:@"audio/mpeg"];
                    
                }
            }];
            
            AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //success!
                NSLog(@"SUCCESS UPLOADING AUDIO! :D, %@", responseObject);
                // completionBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"FAILURE :( 123 %@", error);
                //failure :(
                // completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
            }];
            [operation start];
            
        }
        else
        {
            [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"AUDIO POST CREATION, POST REQUEST");
                NSLog(@"Response object: %@", responseObject);
                //Complete with delegate call
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"GET ERROR: %@", error);
            }];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}



-(void)postCreateANewBlogVIDEOPostWithBaseHostname:(NSString *)baseHostname AndCaption:(NSString *)caption AndEmbedCode:(NSString *)embedCode OrVideoData:(NSData *)videoData AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:@"video" forKey:@"type"];
        
        [mutableParameters setValue:caption forKey:@"caption"];
        
        if (embedCode)
            [mutableParameters setValue:embedCode forKey:@"embed"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        if (videoData && !embedCode)
        {
            NSData* uploadFile = nil;
            uploadFile = (NSData*)videoData;
            
            NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                if (uploadFile) {
                    [formData appendPartWithFileData:uploadFile name:@"data" fileName:@"test.mp4" mimeType:@"video/H264"];
                    
                }
            }];
            
            AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //success!
                NSLog(@"SUCCESS UPLOADING VIDEO! :D, %@", responseObject);
                // completionBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"FAILURE :(");
                //failure :(
                // completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
            }];
            [operation start];
            
        }
        else
        {
            [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"VIDEO POST CREATION, POST REQUEST");
                NSLog(@"Response object: %@", responseObject);
                //Complete with delegate call
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"POST ERROR: %@", error);
            }];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
    
}


-(void)postEditPostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:type forKey:@"type"];
        
        [mutableParameters setValue:postId forKey:@"id"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post/edit", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"EDIT POST, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)postReblogPostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndReblogKey:(NSString *)reblog_key AndType:(NSString *)type AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:type forKey:@"type"];
        
        [mutableParameters setValue:postId forKey:@"id"];
        
        [mutableParameters setValue:reblog_key forKey:@"reblog_key"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post/reblog", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"REBLOG POST, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}

-(void)postDeletePostWithBaseHostname:(NSString *)baseHostname AndPostId:(NSString *)postId AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        
        [mutableParameters setValue:postId forKey:@"id"];
        
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/post/delete", baseHostname];
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"DELETE POST, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}




//USER METHODS
-(void)getUserInfoWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/info";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"USER INFORMATION REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}

-(void)getUserDashboardWithPostType:(NSString *)type AndLimit:(NSString *)limit AndOffset:(NSString *)offset AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (type) {
            [mutableParameters setValue:type forKey:@"type"];
        }
        if (limit) {
            [mutableParameters setValue:limit forKey:@"limit"];
        }
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/dashboard";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"USER DASHBOARD REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)getUserLikesWithLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (limit) {
            [mutableParameters setValue:limit forKey:@"limit"];
        }
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/likes";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"USER LIKES REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
}

-(void)getUserFollowingWithLimit:(NSString *)limit AndOffset:(NSString *)offset AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        if (limit) {
            [mutableParameters setValue:limit forKey:@"limit"];
        }
        if (offset) {
            [mutableParameters setValue:offset forKey:@"offset"];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/following";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"USER FOLLOWING REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"GET ERROR: %@", error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
}

-(void)postUserFollowBlogWithBlogURL:(NSString *)url AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:url forKey:@"url"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/follow";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"USER FOLLOW BLOG, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
}

-(void)postUserUnfollowBlogWithBlogURL:(NSString *)url AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:url forKey:@"url"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/unfollow";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"USER UNFOLLOW BLOG, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)postUserLikePostWithPostId:(NSString *)postID AndReblogKey:(NSString *)reblogKey AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:postID forKey:@"id"];
        [mutableParameters setValue:reblogKey forKey:@"reblog_key"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/like";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"USER LIKE POST, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


-(void)postUserUnlikePostWithPostId:(NSString *)postID AndReblogKey:(NSString *)reblogKey AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    [self setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token" userAuthorizationPath:@"/oauth/authorize" callbackURL:[NSURL URLWithString:@"tumblrtest://success"] accessTokenPath:@"/oauth/access_token" accessMethod:@"POST" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"TOKEN key: %@", accessToken.key);
        NSLog(@"TOKEN secret: %@", accessToken.secret);
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
        
        [mutableParameters setValue:postID forKey:@"id"];
        [mutableParameters setValue:reblogKey forKey:@"reblog_key"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = @"http://api.tumblr.com/v2/user/unlike";
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"USER UNLIKE POST, POST REQUEST");
            NSLog(@"Response object: %@", responseObject);
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST ERROR: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"AUTHORIZATION ERROR: %@", error);
    }];
    
}


//TAGGED METHOD
-(void)getPostsWithTag:(NSString *)tag AndLimit:(NSString *)limit AndFilter:(NSString *)filter AndBefore:(NSString *)before AndWithDelegate:(NSObject<TumblrDelegate> *)delegate {
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setValue:kConsumerKeyString forKey:@"api_key"];
    
    [mutableParameters setValue:tag forKey:@"tag"];
    
    if (limit) {
        [mutableParameters setValue:limit forKey:@"limit"];
    }
    if (filter) {
        [mutableParameters setValue:filter forKey:@"filter"];
    }
    if (before) {
        [mutableParameters setValue:before forKey:@"before"];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *path = @"http://api.tumblr.com/v2/tagged";
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"TAGGED POSTS REQUEST");
        
        NSLog(@"Response object: %@", responseObject);
        
        //Complete with delegate call
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];
    
}


@end
