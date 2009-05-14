//
//  MyTwitterDelegate.h
//  TwitKwik2
//
//  Created by Chris Kimpton on 26/04/2009.
//

#import <Foundation/Foundation.h>


@protocol MyTwitterDelegate 

@optional
// the set/get config methods are used to interact with your app so that things like the OAuth token can be saved for later re-use.
	- (void) setConfig:(NSString*) value forKey:(NSString*) key;
	- (NSString*) configForKey:(NSString*) key;
	
// called when a tweet is successfully sent
	- (void)tweetSucceeded:(NSString *)requestIdentifier;
// called when a tweet fails
	- (void)tweetFailed:(NSString *)requestIdentifier withError:(NSError *)error;
// called with the tweets following a timeline request 
	- (void)tweetsReceived:(NSArray *)statuses forRequest:(NSString *)identifier;

@end
