//
//  IWWebApiManager.m
//  VKLovers_web_API
//
//  Created by Vitaly Davydov on 20/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWWebApiManager.h"
#import "IWVkManager.h"
#import <AFNetworking/AFNetworking.h>

//#define kBaseUrl @"http://vklovers.herokuapp.com/users/"
#define kBaseUrl @"http://localhost:8000/users/"
static const NSString *vk_id = @"vk_id";
static const NSString *mobile = @"mobile";
static const NSString *email = @"email";
static const NSString *who_vk_id = @"who_vk_id";
static const NSString *to_who_vk_id = @"to_who_vk_id";
static const NSString *type = @"type";

@interface IWWebApiManager()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation IWWebApiManager

+ (instancetype)sharedManager {
    static IWWebApiManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self == [super init]) {
        self.manager = [AFHTTPRequestOperationManager manager];
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

//users/
- (void)postUser:(IWUser *)user {
    NSDictionary *params = @{vk_id : user.vk_id,
                             mobile : user.mobile,
                             email : user.email};
    [self.manager POST:kBaseUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST user succsesfull! %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

//users/vk_id/
- (void)deleteUser:(IWUser *)user {
    NSString *url = [kBaseUrl stringByAppendingString:user.vk_id];
    [self.manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

////users/who_vk_id/who_confession/
- (void)getWhoConfessionListForUser:(IWUser *)user {
    NSString *url = [kBaseUrl stringByAppendingFormat:@"%@/who_confession/",user.vk_id];
    [self.manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:k_NotificationGotConfessionsFromServer object:responseObject];
        NSLog(@"Who confession list %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)getWhoConfessionListForCurrentUser {
    IWUser *currentUser = [IWUser userWithVkId:[IWVkManager sharedManager].currentUserVkId mobile:nil email:nil];
    [self getWhoConfessionListForUser:currentUser];
}

- (void)postConfession:(IWConfession *)confession {
    NSString *url = [kBaseUrl stringByAppendingFormat:@"%@/who_confession/",confession.who_vk_id];
    NSDictionary *params = @{who_vk_id : confession.who_vk_id,
                             to_who_vk_id : confession.to_who_vk_id,
                             type : @(confession.type)};
    
    [self.manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

//users/who_vk_id/who_confession/to_who_vk_id/
- (IWConfession *)getConfessionFromUser:(IWUser *)who toUser:(IWUser *)toWho {
    NSString *url = [kBaseUrl stringByAppendingFormat:@"%@/who_confession/%@/",who.vk_id, toWho.vk_id];
    [self.manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    return nil;
}

- (void)putConfession:(IWConfession *)confession; {
    NSString *url = [kBaseUrl stringByAppendingFormat:@"%@/who_confession/%@/",confession.who_vk_id, confession.to_who_vk_id];
    NSDictionary *params = @{who_vk_id : confession.who_vk_id,
                             to_who_vk_id : confession.to_who_vk_id,
                             type : @(confession.type)
                             };
    [self.manager PUT:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)deleteConfession:(IWConfession *)confession {
    NSString *url = [kBaseUrl stringByAppendingFormat:@"%@/who_confession/%@/",confession.who_vk_id, confession.to_who_vk_id];
    
    [self.manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

//users/who_confession/
- (void)postArrayOfConfessions:(NSArray *)confessions {
    NSString *url = [kBaseUrl stringByAppendingString:@"who_confession/"];
    
    [self.manager POST:url parameters:confessions success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
