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
    BOOL value = [[command arguments] objectAtIndex:0];
    [QueueService setTesting: value];
}

- (void)runAsync:(CDVInvokedUrlCommand*)command
{
    NSArray *arguments = [command arguments];
    NSString* customerId = arguments[0];
    NSString* waitingRoomIdOrAlias = arguments[1];
    NSString* layoutName = arguments[2];
    NSString* language = arguments[3];
    
    UIViewController* vc = [self viewController];
    
    self.engine = [[QueueITEngine alloc] initWithHost: vc
     customerId: customerId
     eventOrAliasId: waitingRoomIdOrAlias
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
        if(!success){
            if([error code] == NetworkUnavailable){
                NSLog(@"%ld", (long)[error code]);
                NSLog(@"isRequestInProgress - %@", self.engine.isRequestInProgress ? @"YES" : @"NO");
            }else if([error code] == RequestAlreadyInProgress){
                //Thrown when request to Queue-It has already been made and currently in progress. This can be ignored.
            }else {
                [self callbackOnError: error.description message:@"Error ocurred while queueing"];
            }
        }
    } @catch (NSException *exception) {
        [self callbackOnError: exception.description message:@"Unexpected error ocurred while queueing"];
    }
}

-(void) callbackOnError:(NSString*) errorString
                message:(NSString*) message
{
    NSDictionary* dict = @{
        @"Error": errorString,
        @"Message": message
    };
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
    CDVInvokedUrlCommand* command = self.command;
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void) callbackOnSuccess:(NSString*) token
                    state:(EnqueueState) state {
    if(token==nil){
        token = @"";
    }
    NSDictionary *dict = @{
        @"QueueITToken": token,
        @"State":EnqueueResult_toString[state]
    };
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: dict];
    CDVInvokedUrlCommand* command = self.command;
    [result setKeepCallbackAsBool: YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)notifyYourTurn:(QueuePassedInfo *)queuePassedInfo {
    if(queuePassedInfo==nil){
        [self callbackOnSuccess:@"" state:Passed];
    }else{
        [self callbackOnSuccess:queuePassedInfo.queueitToken state:Passed];
    }
}

- (void)notifyQueueViewWillOpen { 
    [self callbackOnSuccess:@"" state:ViewWillOpen];
}

- (void)notifyQueueDisabled:(QueueDisabledInfo * _Nullable)queueDisabledInfo { 
    [self callbackOnSuccess:@"" state:Disabled];
}

- (void)notifyQueueITUnavailable:(NSString *)errorMessage { 
    [self callbackOnSuccess:@"" state:Unavailable];
}

- (void)notifyUserExited {
}

- (void)notifyViewClosed { 
    [self callbackOnSuccess:@"" state:CloseClicked];
}

@end
