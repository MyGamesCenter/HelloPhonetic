//
//  NSString+expand.h
//

#import <Foundation/Foundation.h>

@interface NSString (expand)

- (NSString *)MD5EncodedString;
+ (NSString *)stringWithUUID_i8;

+(NSString *)safeString:(NSString *)str;
+(BOOL)isNullString:(NSString *)string;
//+(NSString *)stringFromInt:(NSInteger)integer;

- (BOOL)isWhitespaceAndNewlines;

/*!
 *  不区分大小写比较字符串
 *
 *  @param string 另一个字符串
 *
 *  @return 相同返回YES，否则返回NO
 */
- (BOOL)isEqualForCaseInsensitive:(NSString *)string;



/*!
 *  判断一个字符串中是否包含另一个字符串
 *
 *  @param string 另一个字符串
 *
 *  @return 符合返回YES，否则返回NO
 */

-(BOOL)isContainStr:(NSString *)str;

/**
 *  去除字符串中不规则的字符。
 *  -- 不规则的字符指的是除中、英、数字外的字符。
 *
 *  @return 返回规则字符
 */
+ (NSString *)stringByRemoverIrregularSymbol;


@end