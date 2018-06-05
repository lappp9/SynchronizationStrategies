
#import <Foundation/Foundation.h>

@interface Cache : NSObject
- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObject:(id)object forKey:(NSString *)key;
@end
