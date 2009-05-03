//
//  MyTwitter.m
//  TwitKwik2
//
//  Created by Chris Kimpton on 26/04/2009.
//

#import "MyTwitter.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

#import "Tweetum.h"

#define kOAuthAccessTokenKey @"kOAuthAccessTokenKey"
#define kOAuthAccessTokenSecret @"kOAuthAccessTokenSecret"
#define kOAuthConsumerKey		@"<your key from twitter>"
#define kOAuthConsumerSecret	@"<your secret from twitter>"

@implementation MyTwitter

@synthesize requestToken = requestToken_;
@synthesize accessToken = accessToken_;
@synthesize consumer = consumer_;
@synthesize twitter = twitter_;
@synthesize twitDelegate = delegate_;


- (MyTwitter*)init;
{
	NSLog(@"MyTwitter init");
	if (self = [super init])
	{
		self.consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
												 secret:kOAuthConsumerSecret];
		
		self.twitter = [MGTwitterEngine twitterEngineWithDelegate:self];
		[self.twitter setOaConsumer:self.consumer];
		// turn off secure connection when debbugging via packet sniffer :)
		//	[self.twitter setUsesSecureConnection:NO];
		// TODO - get version from plist, get token from twitter peeps
		
		[self.twitter setClientName:@"<your client>" 
		 version:@"1" 
		 URL:@"<your url>" 
		 token:@"<your token>"];
		
		
	}
	return self;
}

- (BOOL)isUserAuthorized;
{
	// see if the delegate has an access token already
	NSString* tokenKey = [self.twitDelegate configForKey:kOAuthAccessTokenKey];
	if (nil != tokenKey)
	{
		self.accessToken = [[[OAToken alloc] initWithKey:tokenKey
												  secret:[self.twitDelegate configForKey:kOAuthAccessTokenSecret]] autorelease];

		[self.twitter setOaToken:self.accessToken];

		return YES;
	}
	return NO;
}

// delegate must get user to go to this url and approve their account for this client
- (NSURLRequest*) authorizeURL;
{
	NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/authorize"];
	OAMutableURLRequest* urlReq = [[[OAMutableURLRequest alloc] initWithURL:url 
																   consumer:nil token:self.requestToken realm:nil 
														  signatureProvider:nil] autorelease];
	OARequestParameter *requestTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token"
																			   value:self.requestToken.key];
	NSArray *params = [NSArray arrayWithObjects:requestTokenParam, nil];
	[urlReq setParameters:params];	
	return urlReq;
}

- (void) askForAccessToken ;
{
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/access_token"];
	
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.requestToken   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"POST"];
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	
}

- (void) askForRequestToken ;
{
	
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
	
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"POST"];
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSData *)data {
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		[self.twitDelegate setConfig:[self.accessToken key] forKey:kOAuthAccessTokenKey];
		[self.twitDelegate setConfig:[self.accessToken secret] forKey:kOAuthAccessTokenSecret];
		[self.twitter setOaToken:self.accessToken];
		
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSData *)data {
}
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		self.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
	}
}

- (void)requestSucceeded:(NSString *)requestIdentifier;
{
	NSLog(@"requestSucceeded");
	[self.twitDelegate tweetSucceeded:requestIdentifier];
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error;
{
	NSLog(@"requestFailed:%@", error);
	[self.twitDelegate tweetFailed: requestIdentifier withError: error];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier;
{
	NSLog(@"statusesReceived");
	[self.twitDelegate tweetsReceived:statuses forRequest:identifier];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier;
{
	NSLog(@"directMessagesReceived");

}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier;
{
	NSLog(@"userInfoReceived");

}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier;
{
	NSLog(@"miscInfoReceived");

}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier;
{
	NSLog(@"imageReceived");

}



- (void)dealloc {
	[currentAccount_ release];
	currentAccount_ = nil;

	[accounts_ release];
	accounts_ = nil;

//	[delegate_ release];
	delegate_ = nil;
	
	
	[twitter_ release];
	twitter_ = nil;
	
	[consumer_ release];
	consumer_ = nil;
	
	[requestToken_ release];
	requestToken_ = nil;
	
	[accessToken_ release];
	accessToken_ = nil;
	
    [super dealloc];
}


@end
