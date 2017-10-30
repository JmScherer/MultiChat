//
//  VideoChatViewController.h
//  
//
//  Created by James Scherer on 10/28/17.
//

#import <UIKit/UIKit.h>
#import <webRTC/RTCEAGLVideoView.h>
#import "ARDAppClient.h"

// Views, Labels, and Buttons

@interface VideoChatViewController : UIViewController <ARDAppClientDelegate, RTCEAGLVideoViewDelegate>

@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (strong, nonatomic) NSString *roomURL;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) ARDAppClient *client;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;
@property (assign, nonatomic) BOOL isZoom;

@property (strong, nonatomic) ARDSettingsModel *settingsModel;

// Toggle Button Parameters

@property (assign, nonatomic) BOOL isAudioMute;
@property (assign, nonatomic) BOOL isVideoMute;

- (IBAction)audioButtonPressed:(id)sender;
- (IBAction)videoButtonPressed:(id)sender;
- (IBAction)hangupButtonPressed:(id)sender;

@end
