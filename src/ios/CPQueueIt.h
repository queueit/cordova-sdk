#import <Cordova/CDV.h>

#import <QueueITLibrary/QueueITEngine.h>
#import <QUeueITLibrary/QueueService.h>

#define ENQUEUE_STATE(x) \
    (EnqueueState_toString[x])

typedef enum {
    Passed,
    Disabled,
    Unavailable,
    ViewWillOpen,
    CloseClicked
} EnqueueState;

extern NSString * const EnqueueState_toString[];

@interface CPQueueIt : CDVPlugin

- (void)enableTesting : (CDVInvokedUrlCommand*)command;
- (void)runAsync : (CDVInvokedUrlCommand*)command;


@end