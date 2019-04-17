//
//  ANSVideoView.h
//  ansible
//
//  Created by Phani Yarlagadda on 10/30/18.
//  Copyright (c) 2018 ATOS. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class ANSVideoView;

@protocol ANSVideoViewDelegate<NSObject>

- (void)setVideoFrame:(ANSVideoView *)videoView;

@end

@class RTCVideoTrack;

@interface ANSVideoView : NSObject

@property (nonatomic, weak) id<ANSVideoViewDelegate> delegate;

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, assign) CGSize streamSize;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)setRendererFrame:(CGRect)frame;
- (void)stopVideoRenderer;
- (void)setVideoTrackByString:(NSString *)videoTrackID;
- (RTCVideoTrack *)getRTCVideoTrack;

- (AVCaptureSession *)getAVCaptureSession;

@end
