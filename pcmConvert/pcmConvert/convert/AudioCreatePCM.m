//
//  AudioCreatePCM.m
//  pcmConvert
//
//  Created by 李博 on 2021/4/30.
//

#import "AudioCreatePCM.h"
#import <AudioToolbox/AudioToolbox.h>
#import <pthread/pthread.h>

const uint32_t CONST_BUFFER_SIZE = 0x10000;

@implementation AudioCreatePCM

static pthread_mutex_t sLock;

+ (void)getPcmWithFilePath:(NSString *)filePath PcmFile:(NSString *)Pcmfile sampleRate:(Float64) sampleRate {
    pthread_mutex_lock(&sLock);
    if ([[NSFileManager defaultManager] isReadableFileAtPath:Pcmfile]) {
        pthread_mutex_unlock(&sLock);
        return;
    }
    NSURL *exportURL = [NSURL fileURLWithPath:filePath];
    
    ExtAudioFileRef inputFile;
    ExtAudioFileOpenURL((__bridge CFURLRef)exportURL, &inputFile);
    
    /// BUFFER
    AudioBufferList *buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    buffList->mNumberBuffers = 1;
    buffList->mBuffers[0].mNumberChannels = 1;
    buffList->mBuffers[0].mDataByteSize = CONST_BUFFER_SIZE;
    buffList->mBuffers[0].mData = malloc(CONST_BUFFER_SIZE);
    
    uint32_t size = sizeof(AudioStreamBasicDescription);
    
    /// initFormat
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    int bytePerChannel = sizeof(SInt16);
    outputFormat.mSampleRate       = sampleRate;
    outputFormat.mFormatID         = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    outputFormat.mChannelsPerFrame = 1;
    outputFormat.mBytesPerFrame    = bytePerChannel * outputFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket  = 1;
    outputFormat.mBitsPerChannel   = bytePerChannel * 8;
    outputFormat.mBytesPerPacket   = outputFormat.mBytesPerFrame * outputFormat.mFramesPerPacket;
    
    /// 设置
    ExtAudioFileSetProperty(inputFile, kExtAudioFileProperty_ClientDataFormat, size, &outputFormat);
    
    UInt32 sizePerPacket = outputFormat.mBytesPerPacket;
    UInt32 packetsPerBuffer = CONST_BUFFER_SIZE / sizePerPacket;
    
    /// 文件
    FILE *pcm = fopen(Pcmfile.UTF8String, "w");
    
    /// 转换
    while (true) {
        UInt32 frameCount = packetsPerBuffer;
        
        OSStatus status = ExtAudioFileRead(inputFile, &frameCount, buffList);
        
        if (status) {
            NSLog(@"转换格式失败");
            //            fclose(pcm);
        }
        
        fwrite(buffList->mBuffers[0].mData, buffList->mBuffers[0].mDataByteSize, 1, pcm);
        
        if (frameCount == 0) {
            printf ("done reading from file");
            break;
        }
    }
    fclose(pcm);
    free(buffList);
    ExtAudioFileDispose(inputFile);
    
    pthread_mutex_unlock(&sLock);
}

@end
