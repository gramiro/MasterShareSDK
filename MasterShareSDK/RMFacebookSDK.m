//
//  RMFacebookSDK.m
//  MasterShareSDK
//
//  Created by Ramiro Guerrero & Marco Graciano on 29/04/13.
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


#import "RMFacebookSDK.h"

static NSString * const kClientBaseURL = @"https://graph.facebook.com/";
static NSString * const kClientIDString = @"";//FILL IN WITH YOUR OWN CLIENT ID
static NSString * const kClientSecretString = @"";//FILL IN WITH YOUR OWN CLIENT SECRET

@implementation RMFacebookSDK

+ (RMFacebookSDK *)sharedClient {
    static RMFacebookSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[RMFacebookSDK alloc] initWithBaseURL:[NSURL URLWithString:kClientBaseURL]];
        
    });
    
    return _sharedClient;
}


-(void)getPublicPageWithQuery:(NSString *)query WithParams:(NSDictionary *)params AndWithDelegate:(NSObject <FacebookDelegate> *)delegate{
    
    NSString *path = [NSString stringWithFormat:@"%@search", kClientBaseURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:query forKey:@"q"];
    [parameters setValue:@"page" forKey:@"type"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}

-(void)getPublicPlaceWithQuery:(NSString *)query WithParams:(NSDictionary *)params AndWithDelegate:(NSObject <FacebookDelegate> *)delegate{
    
    NSString *path = [NSString stringWithFormat:@"%@oauth/access_token", kClientBaseURL];
    
    NSDictionary *tParams = [NSDictionary dictionaryWithObjectsAndKeys:kClientIDString,@"client_id", kClientSecretString, @"client_secret", @"client_credentials", @"grant_type", nil];
    
    [self getPath:path parameters:tParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSRange access_token_range = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] rangeOfString:@"access_token="];
        if (access_token_range.length > 0) {
            int from_index = access_token_range.location + access_token_range.length;
            NSString *access_token = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] substringFromIndex:from_index];
            
            accessToken = access_token;
            
            NSString *path = [NSString stringWithFormat:@"%@search", kClientBaseURL];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
            
            [parameters setValue:query forKey:@"q"];
            [parameters setValue:accessToken forKey:@"access_token"];
            [parameters setValue:@"place" forKey:@"type"];
            
            [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSError *jsonError;
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                NSLog(@"Response Object: %@", responseData);
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
            }];

        }
        
        NSLog(@"ACCESS TOKEN: %@", accessToken);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)getPublicPlaceWithQuery:(NSString *)query WithLatitude:(NSString *)latitude WithLongitude:(NSString *)longitude WithParams:(NSDictionary *)params AndWithDelegate:(NSObject <FacebookDelegate> *)delegate{
    
    NSString *path = [NSString stringWithFormat:@"%@oauth/access_token", kClientBaseURL];
    
    NSDictionary *tParams = [NSDictionary dictionaryWithObjectsAndKeys:kClientIDString,@"client_id", kClientSecretString, @"client_secret", @"client_credentials", @"grant_type", nil];
    
    [self getPath:path parameters:tParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSRange access_token_range = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] rangeOfString:@"access_token="];
        if (access_token_range.length > 0) {
            int from_index = access_token_range.location + access_token_range.length;
            NSString *access_token = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] substringFromIndex:from_index];
            
            accessToken = access_token;
            
            NSString *path = [NSString stringWithFormat:@"%@search", kClientBaseURL];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
            
            [parameters setValue:query forKey:@"q"];
            [parameters setValue:accessToken forKey:@"access_token"];
            [parameters setValue:@"place" forKey:@"type"];
            
            NSString *coords = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
            
            [parameters setValue:coords forKey:@"center"];
            
            [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSError *jsonError;
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                NSLog(@"Response Object: %@", responseData);
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
            }];
    
        }
        
        NSLog(@"ACCESS TOKEN: %@", accessToken);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)getPublicPostsWithQuery:(NSString *)query WithParams:(NSDictionary *)params AndWithDelegate:(NSObject <FacebookDelegate> *)delegate{
    
    NSString *path = [NSString stringWithFormat:@"%@search", kClientBaseURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:query forKey:@"q"];
    [parameters setValue:@"post" forKey:@"type"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)getPublicGroupsWithQuery:(NSString *)query WithParams:(NSDictionary *)params AndWithDelegate:(NSObject <FacebookDelegate> *)delegate{
    
    NSString *path = [NSString stringWithFormat:@"%@search", kClientBaseURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [parameters setValue:query forKey:@"q"];
    [parameters setValue:@"group" forKey:@"type"];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        NSLog(@"Response Object: %@", responseData);

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

@end
