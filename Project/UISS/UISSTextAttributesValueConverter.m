//
//  UISSTextAttributesValueConverter.m
//  UISS
//
//  Created by Robert Wijas on 5/9/12.
//  Copyright (c) 2012 57things. All rights reserved.
//

#import "UISSTextAttributesValueConverter.h"
#import "UISSFontValueConverter.h"
#import "UISSColorValueConverter.h"
#import "UISSOffsetValueConverter.h"
#import "UISSArgument.h"

@interface UISSTextAttributesValueConverter ()

@property(nonatomic, strong) UISSFontValueConverter *fontConverter;
@property(nonatomic, strong) UISSColorValueConverter *colorConverter;
@property(nonatomic, strong) UISSOffsetValueConverter *offsetConverter;

@end

@implementation UISSTextAttributesValueConverter

@synthesize fontConverter;
@synthesize colorConverter;
@synthesize offsetConverter;

- (id)init
{
    self = [super init];
    if (self) {
        self.fontConverter = [[UISSFontValueConverter alloc] init];
        self.colorConverter = [[UISSColorValueConverter alloc] init];
        self.offsetConverter = [[UISSOffsetValueConverter alloc] init];
    }
    return self;
}

- (BOOL)canConvertPropertyWithName:(NSString *)name value:(id)value argumentType:(NSString *)argumentType;
{
    return [argumentType hasPrefix:@"@"] && [[name lowercaseString] hasSuffix:@"textattributes"] && [value isKindOfClass:[NSDictionary class]];
}

- (void)convertProperty:(NSString *)propertyName fromDictionary:(NSDictionary *)dictionary
           toDictionary:(NSMutableDictionary *)converterDictionary withKey:(NSString *)key
         usingConverter:(id <UISSPropertyValueConverter>)converter;
{
    id value = [dictionary objectForKey:propertyName];
    if (value) {
        id converted = [converter convertPropertyValue:value];
        if (converted) {
            [converterDictionary setObject:converted forKey:key];
        }
    }
}

- (id)convertPropertyValue:(id)value;
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *) value;

        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [self convertProperty:UISS_FONT_KEY fromDictionary:dictionary toDictionary:attributes withKey:UITextAttributeFont
               usingConverter:self.fontConverter];

        [self convertProperty:UISS_TEXT_COLOR_KEY fromDictionary:dictionary toDictionary:attributes withKey:UITextAttributeTextColor
               usingConverter:self.colorConverter];

        [self convertProperty:UISS_TEXT_SHADOW_COLOR_KEY fromDictionary:dictionary toDictionary:attributes withKey:UITextAttributeTextShadowColor
               usingConverter:self.colorConverter];

        [self convertProperty:UISS_TEXT_SHADOW_OFFSET_KEY fromDictionary:dictionary toDictionary:attributes withKey:UITextAttributeTextShadowOffset
               usingConverter:self.offsetConverter];

        if (attributes.count) {
            return attributes;
        }
    }

    return nil;
}

- (NSString *)generateCodeForPropertyValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *) value;

        NSMutableString *objectAndKeys = [NSMutableString string];

        id fontValue = [dictionary objectForKey:UISS_FONT_KEY];
        if (fontValue) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.fontConverter generateCodeForPropertyValue:fontValue], @"UITextAttributeFont"];
        }

        id textColorValue = [dictionary objectForKey:UISS_TEXT_COLOR_KEY];
        if (textColorValue) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.colorConverter generateCodeForPropertyValue:textColorValue], @"UITextAttributeTextColor"];
        }

        id textShadowColor = [dictionary objectForKey:UISS_TEXT_SHADOW_COLOR_KEY];
        if (textShadowColor) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.colorConverter generateCodeForPropertyValue:textShadowColor], @"UITextAttributeTextShadowColor"];
        }

        id textShadowOffset = [dictionary objectForKey:UISS_TEXT_SHADOW_OFFSET_KEY];
        if (textShadowOffset) {
            [objectAndKeys appendFormat:@"[NSValue valueWithUIOffset:%@], %@,", [self.offsetConverter generateCodeForPropertyValue:textShadowOffset], @"UITextAttributeTextShadowOffset"];
        }

        if (objectAndKeys.length) {
            return [NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:%@ nil]", objectAndKeys];
        }
    }

    return nil;
}

- (BOOL)canConvertValueForArgument:(UISSArgument *)argument
{
    return [self canConvertPropertyWithName:argument.name value:argument.value argumentType:argument.type];
}

- (NSString *)generateCodeForArgument:(UISSArgument *)argument
{
    return [self generateCodeForPropertyValue:argument.value];
}

- (id)convertValueForArgument:(UISSArgument *)argument
{
    return [self convertPropertyValue:argument.value];
}

@end
