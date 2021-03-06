//
//  DoublePhoneCell.h
//  HelloMyWords
//
//  Created by junfengyang on 15/5/27.
//  Copyright (c) 2015年 HSChinese iOS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LearnCollectionViewCell.h"
#import "HSToneView.h"
#import "AudioRecordAndPlayView.h"

@interface DoublePhoneCell : LearnCollectionViewCell<AudioRecordAndPlayDelegate>
@property (weak, nonatomic) IBOutlet HSToneView *toneFirstView;
@property (weak, nonatomic) IBOutlet HSToneView *toneSecondView;
@property (weak, nonatomic) IBOutlet UIView *toneBackgroundView;
@property (weak, nonatomic) IBOutlet HSToneView *toneView;
@property (weak, nonatomic) IBOutlet UIImageView *imgvTone;

@property (weak, nonatomic) IBOutlet UILabel *lblContentFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblContentSecond;
@property (weak, nonatomic) IBOutlet AudioRecordAndPlayView *audioControlView;

@end
