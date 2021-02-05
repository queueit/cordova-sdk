#import "CPQueueIt.h"

@interface CPQueueIt ()
@property (nonatomic, strong) QueueITEngine* engine;
@property CDVInvokedUrlCommand* command;
@end

NSString * const EnqueueResult_toString[] = {
    [Passed] = @"Passed",
    [Disabled] = @"Disabled",
    [Unavailable] = @"Unavailable",
    [ViewWillOpen] = @"ViewWillOpen",
    [CloseClicked] = @"CloseClicked"
};

@implementation CPQueueIt

- (void)enableTesting:(CDVInvokedUrlCommand*)command
{
    BOOL value = [command arguments] objectAtIndex:0];
    [QueueService setTesting: value];

    NSString* callbackId = [command callbackId];
    NSString* msg = [NSString stringWithFormat: @"Echo: %@", [[command arguments] objectAtIndex:0]];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)runAsync:(CDVInvokedUrlCommand*)command
{
    arguments = [command arguments];
    self.engine = [[QueueITEngine alloc] initWithHost: vc
     customerId: customerId
     eventOrAliasId: eventOrAliasId
     layoutName: layoutName
     language: language];

    self.engine.queuePassedDelegate = self;
    self.engine.queueViewWillOpenDelegate = self;
    self.engine.queueDisabledDelegate = self;
    self.engine.queueITUnavailableDelegate = self;
    self.engine.queueUserExitedDelegate = self;
    self.engine.queueViewClosedDelegate = self;
    self.command = command;
    
    NSError* error = nil;
    @try{
        BOOL success = [self.engine run:&error];
        if([error code] == NetworkUnavailable){
            
        }else if([error code] == RequestAlreadyInProgress){
            //Thrown when request to Queue-It has already been made and currently in progress. This can be ignored.
        }else {
            error..
        }
    } @catch (NSException *exception) {
        //Error error
    }
}

@end
