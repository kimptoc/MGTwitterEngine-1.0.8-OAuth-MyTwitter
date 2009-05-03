//
//  MyTwitterDelegate.h
//  TwitKwik2
//
//  Created by Chris Kimpton on 26/04/2009.
//

#import <Foundation/Foundation.h>


@protocol MyTwitterDelegate 

@optional
	- (void) setConfig:(NSString*) value forKey:(NSString*) key;
	- (NSString*) configForKey:(NSString*) key;
	- (void)tweetSucceeded:(NSString *)requestIdentifier;
	- (void)tweetFailed:(NSString *)requestIdentifier withError:(NSError *)error;
	- (void)tweetsReceived:(NSArray *)statuses forRequest:(NSString *)identifier;

@end
