//
//  RMGooglePlusSDK.m
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

#import "RMGooglePlusSDK.h"

static NSString * const kClientBaseURL = @"https://www.googleapis.com/plus/v1/";
static NSString * const kGooglePlusAPIKey = @"";//FILL IN WITH YOUR OWN API KEY

@implementation RMGooglePlusSDK

+ (RMGooglePlusSDK *)sharedClient {
    static RMGooglePlusSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[RMGooglePlusSDK alloc] initWithBaseURL:[NSURL URLWithString:kClientBaseURL]];
        
    });
    
    return _sharedClient;
}


//PEOPLE RESOURCE - METHODS
-(void)getPublicPeopleProfileWithUserId:(NSString *)userID AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
   
    NSString *path = [NSString stringWithFormat:@"%@people/%@", kClientBaseURL, userID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}


-(void)getPeopleSearchWithQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@people", kClientBaseURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    [parameters setValue:query forKey:@"query"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}


-(void)getPeopleListByActivityWithActivityId:(NSString *)activityID AndCollection:(NSString *)collection AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@activities/%@/people/%@", kClientBaseURL, activityID, collection];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}


//ACTIVITIES RESOURCE - METHODS
-(void)getPublicActivitiesListWithUserId:(NSString *)userID AndCollection:(NSString *)collection AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@people/%@/activities/%@", kClientBaseURL, userID, collection];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}


-(void)getActivityWithActivityId:(NSString *)activityID AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@activities/%@", kClientBaseURL, activityID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}

-(void)getActivitySearchWithQuery:(NSString *)query AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@activities", kClientBaseURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    [parameters setValue:query forKey:@"query"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}


//COMMENTS RESOURCE - METHODS
-(void)getCommentsListWithActivityId:(NSString *)activityID AndParameters:(NSDictionary *)params AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@activities/%@/comments", kClientBaseURL, activityID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}


-(void)getCommentWithCommentId:(NSString *)commentID AndWithDelegate:(NSObject<GooglePlusDelegate> *)delegate {
    
    NSString *path = [NSString stringWithFormat:@"%@comments/%@", kClientBaseURL, commentID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:kGooglePlusAPIKey forKey:@"key"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}

@end
