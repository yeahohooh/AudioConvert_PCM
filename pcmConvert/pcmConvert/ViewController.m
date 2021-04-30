//
//  ViewController.m
//  pcmConvert
//
//  Created by 李博 on 2021/4/30.
//

#import "ViewController.h"
#import "AudioCreatePCM.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // example
    NSString *path = [[NSBundle mainBundle] pathForResource:@"和田光司 (わだ こうじ)-Butter-Fly" ofType:@"mp3"];
    NSString *pcmPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"convert.pcm"];
    [AudioCreatePCM getPcmWithFilePath:path PcmFile:pcmPath sampleRate:48000];
}


@end
