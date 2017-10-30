//
//  VideoChatViewController.m
//  
//
//  Created by James Scherer on 10/28/17.
//

#import "VideoChatViewController.h"

@interface VideoChatViewController ()

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isZoom = NO;
    self.isAudioMute = NO;
    self.isVideoMute = NO;
    
    [self.audioButton.layer setCornerRadius:20.0f];
    [self.videoButton.layer setCornerRadius:20.0f];
    [self.hangupButton.layer setCornerRadius:20.0f];
    
    //Add Tap to hide/show controls
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleButtonContainer)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Add Double Tap to zoom
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomRemote)];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
    [self.remoteView setDelegate:self];
    [self.localView setDelegate:self];
    
    //Getting Orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    //Connect to the room
    [self disconnect];
    self.client = [[ARDAppClient alloc] initWithDelegate:self];
    [self.client connectToRoomWithId:@"Gertner" settings:self.settingsModel isLoopback:false isAudioOnly:false shouldMakeAecDump:false shouldUseLevelControl:false];
    
    [self.urlLabel setText:@"Gertner"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)audioButtonPressed:(id)sender {
}

- (IBAction)videoButtonPressed:(id)sender {
}

- (IBAction)hangupButtonPressed:(id)sender {
}

- (void)disconnect {
    if (self.client) {
        if (self.localVideoTrack) [self.localVideoTrack removeRenderer:self.localView];
        if (self.remoteVideoTrack) [self.remoteVideoTrack removeRenderer:self.remoteView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
        self.remoteVideoTrack = nil;
        [self.remoteView renderFrame:nil];
        [self.client disconnect];
    }
}

-(void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state {
    switch (state) {
        case kARDAppClientStateConnected:
            NSLog(@"Client connected.");
            break;
        case kARDAppClientStateConnecting:
            NSLog(@"Client connecting.");
            break;
        case kARDAppClientStateDisconnected:
            NSLog(@"Client disconnected.");
            [self remoteDisconnected];
            break;
    }
}

- (void)remoteDisconnected {
    if (self.remoteVideoTrack) [self.remoteVideoTrack removeRenderer:self.remoteView];
    self.remoteVideoTrack = nil;
    [self.remoteView renderFrame:nil];
    [self videoView:self.localView didChangeVideoSize:self.localVideoSize];
    
}

- (void)appClient:(ARDAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    self.localVideoTrack = localVideoTrack;
    [self.localVideoTrack addRenderer:self.localView];
}

- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    self.remoteVideoTrack = remoteVideoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteView];
}

- (void)appClient:(ARDAppClient *)client didError:(NSError *)error {
    /* Handle the error */
    
}

- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    /* resize self.localView or self.remoteView based on the size returned */
}

@end
