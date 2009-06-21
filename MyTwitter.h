//
//  MyTwitter.h
//  TwitKwik2
//
//  Created by Chris Kimpton on 26/04/2009.
//

#import <Foundation/Foundation.h>

#import "MGTwitterEngine.h"
#import "MyTwitterDelegate.h"
#import "OAToken.h"

@interface MyTwitter : NSObject<MGTwitterEngineDelegate> {
	MGTwitterEngine* twitter_;
	OAToken* requestToken_;
	OAToken* accessToken_;
	OAConsumer *consumer_;
	id <MyTwitterDelegate> delegate_;
}

- (BOOL)isUserAuthorized;
- (MyTwitter*)init;
- (NSString *)sendUpdate:(NSString *)status;
- (void) askForAccessToken: (NSString*) pincode ;
- (void) askForRequestToken ;
- (NSURLRequest*) authorizeURL;

- (void) askForPinCode;


@property(nonatomic,retain)TwitAccount *currentAccount;



@property(nonatomic,retain)id<MyTwitterDelegate> twitDelegate;

@property(nonatomic,retain)OAConsumer *consumer;
@property(nonatomic,retain)OAToken *requestToken;
@property(nonatomic,retain)OAToken *accessToken;

@property(nonatomic,retain)MGTwitterEngine *twitter;

@end
