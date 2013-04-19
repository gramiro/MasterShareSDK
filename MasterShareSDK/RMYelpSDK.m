//
//  RMYelpSDK.m
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

#import "RMYelpSDK.h"

static NSString * const kOAuth1BaseURLString = @"http://api.yelp.com/v2/";
static NSString * const kConsumerKeyString = @"";//COMPLETE WITH YOUR OWN CONSUMER KEY
static NSString * const kConsumerSecretString = @"";//COMPLETE WITH YOUR OWN CONSUMER SECRET
static NSString * const kTokenString = @"";//COMPLETE WITH YOUR OWN TOKEN
static NSString * const kTokenSecretString = @"";//COMPLETE WITH YOUR OWN TOKEN SECRET

//IMPORTANT NOTE: IT MIGHT BE NECESSARY TO COMMENT THE LINES 418 & 419 IN THE FILE AFOAuth1Client.m

@implementation RMYelpSDK

+ (RMYelpSDK *)sharedClient {
    static RMYelpSDK *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[RMYelpSDK alloc] initWithBaseURL:[NSURL URLWithString:kOAuth1BaseURLString] key:kConsumerKeyString secret:kConsumerSecretString];
        
    });
    
    return _sharedClient;
}


//General Search.

-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate{
    
    
    AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:kTokenString secret:kTokenSecretString session:nil expiration:nil renewable:NO];
    
    [self acquireOAuthAccessTokenWithPath:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york" requestToken:token accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"SUCCESS");
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        
        [mutableParameters setValue:term forKey:@"term"];
        [mutableParameters setValue:location forKey:@"location"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        [self getPath:@"http://api.yelp.com/v2/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"SEARCH REQUEST");
            NSLog(@"Response object: %@", responseObject);
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response array: %@", json);
            
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
        
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

-(void)getSearchWithTerm:(NSString *)term AndBounds:(NSDictionary *)boundsParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate{
    
    AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:kTokenString secret:kTokenSecretString session:nil expiration:nil renewable:NO];
    
    [self acquireOAuthAccessTokenWithPath:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york" requestToken:token accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"SUCCESS");
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        
        [mutableParameters setValue:term forKey:@"term"];
        
        NSString *boundsString = [NSString stringWithFormat:@"%@,%@|%@,%@", [boundsParams objectForKey:@"sw_latitude"],[boundsParams objectForKey:@"sw_longitude"],[boundsParams objectForKey:@"ne_latitude"],[boundsParams objectForKey:@"ne_longitude"]];
        
        [mutableParameters setValue:boundsString forKey:@"bounds"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        [self getPath:@"http://api.yelp.com/v2/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"SEARCH REQUEST");
            NSLog(@"Response object: %@", responseObject);
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response array: %@", json);
            
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
        
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

-(void)getSearchWithTerm:(NSString *)term AndCoordinates:(NSDictionary *)coordParams AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate{
    
    AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:kTokenString secret:kTokenSecretString session:nil expiration:nil renewable:NO];
    
    [self acquireOAuthAccessTokenWithPath:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york" requestToken:token accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"SUCCESS");
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        
        [mutableParameters setValue:term forKey:@"term"];
        
        NSMutableArray *locationArray = [NSMutableArray array];
        
        [locationArray addObject:[coordParams objectForKey:@"latitude"]];
        [locationArray addObject:[coordParams objectForKey:@"longitude"]];
        
        if ([coordParams objectForKey:@"accuracy"])
            [locationArray addObject:[coordParams objectForKey:@"accuracy"]];
        if ([coordParams objectForKey:@"altitude"])
            [locationArray addObject:[coordParams objectForKey:@"altitude"]];
        if ([coordParams objectForKey:@"altitude_accuracy"])
            [locationArray addObject:[coordParams objectForKey:@"altitude_accuracy"]];
        
        NSString *coordinateString = [locationArray componentsJoinedByString:@","];
        
        [mutableParameters setValue:coordinateString forKey:@"ll"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        [self getPath:@"http://api.yelp.com/v2/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"SEARCH REQUEST");
            NSLog(@"Response object: %@", responseObject);
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response array: %@", json);
            
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
        
        
    } failure:^(NSError *error) {
        
    }];
}

-(void)getSearchWithTerm:(NSString *)term AndLocation:(NSString *)location AndLatitude:(NSString *)latitude AndLongitude:(NSString *)longitude AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate{
    
    AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:kTokenString secret:kTokenSecretString session:nil expiration:nil renewable:NO];
    
    [self acquireOAuthAccessTokenWithPath:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york" requestToken:token accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"SUCCESS");
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        
        [mutableParameters setValue:term forKey:@"term"];
        [mutableParameters setValue:location forKey:@"location"];
        
        NSString *coordinateString = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
        
        [mutableParameters setValue:coordinateString forKey:@"cll"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        [self getPath:@"http://api.yelp.com/v2/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"SEARCH REQUEST");
            NSLog(@"Response object: %@", responseObject);
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response array: %@", json);
            
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
        
        
    } failure:^(NSError *error) {
        
    }];
}

-(void)getBusinessWithBusinessId:(NSString *)businessId AndParams:(NSDictionary *)params AndWithDelegate:(NSObject <YelpDelegate> *)delegate{
    
    AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:kTokenString secret:kTokenSecretString session:nil expiration:nil renewable:NO];
    
    [self acquireOAuthAccessTokenWithPath:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york" requestToken:token accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        
        NSLog(@"SUCCESS");
        
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
        
        if (params)
            mutableParameters = [NSMutableDictionary dictionaryWithDictionary:params];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        
        NSString *path = [NSString stringWithFormat:@"http://api.yelp.com/v2/business/%@", businessId];
        
        [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"SEARCH REQUEST");
            NSLog(@"Response object: %@", responseObject);
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            
            NSLog(@"Response array: %@", json);
            
            //Complete with delegate call
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
        }];
        
        
    } failure:^(NSError *error) {
        
    }];
    
    
}


@end
