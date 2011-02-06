

#import <Foundation/Foundation.h>

#import "QSActionProvider.h"

typedef struct {
	short kchrID;
	Str255 KCHRname;
	short transtable[256];
} Ascii2KeyCodeTable;
enum {
	kTableCountOffset = 256+2,
	kFirstTableOffset = 256+4,
	kTableSize = 128
} ;

@interface QSTextActions : QSActionProvider
{

}
- (void)typeString2:(NSString *)string;


@end


