//
//  ImportOperation.m
//  LiveInShanghai
//
//  Created by junfengyang on 15/3/18.
//  Copyright (c) 2015年 junfengyang. All rights reserved.
//

#import "ImportOperation.h"
#import <CoreData/CoreData.h>
#import "Store.h"
#import "NSString+ParseCSV.h"
#import "Reader.h"
#import "Record.h"
#import "Record+Import.h"
#import "ToneKnowledge.h"
#import "ToneKnowledge+Record.h"

static const int ImportBatchSize = 250;

@interface ImportOperation ()
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) Reader *reader;
@property (nonatomic) NSInteger type;

@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isConcurrent;
@property (nonatomic) BOOL isFineshed;

@end

@implementation ImportOperation
- (id)initWithStore:(Store *)store fileName:(NSString *)name
{
    return [self initWithStore:store fileName:name type:DataImportTypeNormal];
}

- (id)initWithStore:(Store *)store fileName:(NSString *)name type:(DataImportType)aType
{
    if (self = [super init]) {
        self.store = store;//[[Store alloc] init];
        self.fileName = name;
        self.type = aType;
    }
    return self;
}

/*
- (void)main
{
    self.context = [self.store privateContext];
    self.context.undoManager = nil;
    [self.context performBlockAndWait:^{
        [self import];
    }];
}
 */

- (void)start
{
    self.isExecuting = YES;
    self.isConcurrent = YES;
    self.isFineshed = NO;
    
    self.context = [self.store privateContext];
    self.context.undoManager = nil;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // NSInputStream 需要在主线程中操作
        [self streamImport];
    }];
}

- (void)streamImport
{
    NSURL *fileURL = [NSURL fileURLWithPath:self.fileName];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]], @"please download the sample data");
    self.reader = [[Reader alloc] initWithFileAtURL:fileURL];
    [self.reader enumarateLinesWithBlock:^(NSUInteger lineNumber, NSString *line) {
        NSArray *components = [line csvComponents];
        
        if (self.type == DataImportTypeNormal)
        {
            if (lineNumber <= 1) {
                return ;
            }
            if ([components count] < 7 || [components count] > 8 ) {
                //NSLog(@"could't parse: %@", components);
                return;
            }
            [Record importCSVComponents:components intoContext:self.context];
        }
        else if (self.type == DataImportTypeToneKnowledge)
        {
            if (lineNumber <= 1) {
                return ;
            }
            if ([components count] < 5 || [components count] > 7 ) {
                //NSLog(@"could't parse: %@", components);
                return;
            }
            [ToneKnowledge importToneKnowledgeComponents:components intoContext:self.context];
        }
        
        self.progressCallback(lineNumber / (float)10000);
        if (lineNumber % ImportBatchSize == 0) {
            [self.context save:NULL];
        }
        
    } completionHandler:^(NSUInteger numberOfLines) {
        self.progressCallback(1);
        [self.context save:NULL];
    }];
}

- (void)import
{
    // 对于小文件，一次性读取到内存中是可以的。对于大的文件，需要一次一行地读取。
    // 为了达到这个目的，我们使用能让我们异步处理文件的 NSInputStream 。根据官方文档的描述：
    
    // 如果你总是需要从头到尾来读/写文件的话，streams 提供了一个简单的接口来异步完成这个操作
    
    // 不管你是否使用 streams，大体上逐行读取一个文件的模式是这样的：
    
    // 建立一个中间缓冲层以提供，当没有找到换行符号的时候可以向其中添加数据
    // 从 stream 中读取一块数据
    // 对于这块数据中发现的每一个换行符，取中间缓冲层，向其中添加数据，直到（并包括）这个换行符，并将其输出
    // 将剩余的字节添加到中间缓冲层去
    // 回到 2，直到 stream 关闭
    NSString *fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger count = [lines count];
    NSInteger progressGranularity = count/100;
    __block NSInteger idx = 1;
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        idx++;
        if (idx == 0) {
            return;// header line
        }
        
        if (self.isCancelled) {
            *stop = YES;
            return;
        }
        
        NSArray *components = [line csvComponents];
        
        if ([components count] < 5) {
            NSLog(@"Couldn't parse: %@", components);
            return;
        }
        
        // 添加数据
        [Record importCSVComponents:components intoContext:self.context];
        
        //返回进度、保存数据。
        if (idx % progressGranularity == 0) {
            self.progressCallback(idx/(float)count);
        }
        
        if (idx % ImportBatchSize == 0) {
            [self.context save:NULL]; // 保存数据
        }
    }];
    
    self.progressCallback(1);
    [self.context save:NULL];
}

- (void)setIsExecuting:(BOOL)isExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsFineshed:(BOOL)isFineshed
{
    [self willChangeValueForKey:@"isFinished"];
    _isFineshed = isFineshed;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel
{
    [super cancel];
    
    self.isFineshed = YES;
    self.isExecuting = NO;
}

@end
