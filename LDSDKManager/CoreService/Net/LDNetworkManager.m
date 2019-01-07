//
// Created by majiancheng on 2018/12/11.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDNetworkManager.h"

#import <MCBase/MCLog.h>

@interface LDNetworkManager () <NSURLSessionDelegate>

@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSURLSessionDataTask *task;

@property(nonatomic, strong) NSMutableData *data;

@property(nonatomic, copy) void (^callBack)(BOOL success, id data);

@end

@implementation LDNetworkManager

- (void)dealloc {
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

- (void)dataTaskWithRequest:(NSURLRequest *)request callBack:(nonnull void (^)(BOOL success, id data))callback {
    self.callBack = callback;
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }

    __weak  typeof(self) weakSelf = self;
    self.task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSefl = weakSelf;
        if (self.callBack) {
            if (error) {
                self.callBack(NO, error);
            } else {
                NSError *err;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                if (err) {
                    MCLog(@"[JSON]%@", err);
                }
                self.callBack(YES, dictionary);
            }
        }
    }];

    [self.task resume];
}

#pragma mark - SessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {

}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler {
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cre);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {

}


#pragma mark - getter

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@end