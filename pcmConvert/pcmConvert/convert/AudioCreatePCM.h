//
//  AudioCreatePCM.h
//  pcmConvert
//
//  Created by 李博 on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioCreatePCM : NSObject

/// 传入想要转换的音乐文件路径，第二个参数传入转换成pcm格式的文件路径
+ (void)getPcmWithFilePath:(NSString *)filePath PcmFile:(NSString *)Pcmfile sampleRate:(Float64) sampleRate;

@end

NS_ASSUME_NONNULL_END
