//
// QSKeyCodeTranslator.m
// Quicksilver
//
// Created by Alcor on 8/12/04.
// Copyright 2004 Blacktree. All rights reserved.
//

// modified according to http://stackoverflow.com/questions/1918841/how-to-convert-ascii-character-to-cgkeycode
// cjsas 20110205
#import "QSKeyCodeTranslator.h"

static CFMutableDictionaryRef charToCodeDict = NULL;

@implementation QSKeyCodeTranslator

+(void)initialize {
	[self InitAscii2KeyCodeTable];
}

/* Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);    
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

+(OSStatus) InitAscii2KeyCodeTable {
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }

	return noErr;
}

- (short) keyCodeForCharacter:(NSString *)character {
	char ascii = *[character UTF8String];
	return [self AsciiToKeyCode:ascii];
}

/* Returns key code for given character via the above function, or UINT16_MAX
 Ê* on error. */
- (short) AsciiToKeyCode:(short)asciiCode {
	if (asciiCode >= 0 && asciiCode <= 255)
    {
        CGKeyCode code;
        UniChar character = (char)asciiCode;
        CFStringRef charStr = NULL;
        
        charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
        
        /* Our values may be NULL (0), so we need to use this function. */
        if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                           (const void **)&code)) {
            code = UINT16_MAX;
        }
        
        CFRelease(charStr);
        return (short)code;
    }
	else return -1;
}

@end
