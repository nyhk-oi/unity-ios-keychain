#import <UIKit/UIKit.h>
#import <Security/Security.h>

#define SERVICE_NAME    @"ServiceName"

extern "C" {
char* _Get(const char *cdataType);
int _AddItem(const char *dataType, const char *value);
int _Delete(const char *dataType);
}


//When searching, "kSecAttrService, kSecAttrAccount" will be used as a unique value.
char* _Get(const char *dataType)
{
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setObject:(id)[NSString stringWithCString:dataType encoding:NSUTF8StringEncoding] forKey:(id)kSecAttrAccount];
    [query setObject:SERVICE_NAME forKey:(id)kSecAttrService];
    [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    CFDataRef cfresult = NULL;
    OSStatus err = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&cfresult);
    
    if (err == noErr) {
        NSData* passwordData = (__bridge_transfer NSData *)cfresult;
        const char* value = [[[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding] UTF8String];
        char *str = strdup(value);
        return str;
        NSLog(@"create uuid");
    } else {
        return NULL;
    }
}


int _AddItem(const char *dataType, const char *value)
{
    NSMutableDictionary* attributes = nil;
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    NSData* sata = [[NSString stringWithCString:value encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];


    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setObject:(id)[NSString stringWithCString:dataType encoding:NSUTF8StringEncoding] forKey:(id)kSecAttrAccount];
    [query setObject:SERVICE_NAME forKey:(id)kSecAttrService];

    OSStatus err = SecItemCopyMatching((CFDictionaryRef)query, NULL);
    
    //if noErr, only update dateTime
    if (err == noErr) {
        // update item
        attributes = [NSMutableDictionary dictionary];
        [attributes setObject:sata forKey:(id)kSecValueData];
        [attributes setObject:[NSDate date] forKey:(id)kSecAttrModificationDate];
        
        err = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
        return (int)err;

    //if err = errSecItemNotFound, item is not registered. make new item
    } else if (err == errSecItemNotFound) {

        attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [attributes setObject:(id)[NSString stringWithCString:dataType encoding:NSUTF8StringEncoding] forKey:(id)kSecAttrAccount];
        [attributes setObject:sata forKey:(id)kSecValueData];
        [attributes setObject:SERVICE_NAME forKey:(id)kSecAttrService];
        [attributes setObject:[NSDate date] forKey:(id)kSecAttrCreationDate];
        [attributes setObject:[NSDate date] forKey:(id)kSecAttrModificationDate];
        err = SecItemAdd((CFDictionaryRef)attributes, NULL);
        return (int)err;
        
    } else {
        return (int)err;
    }
}

int _Delete(const char *dataType)
{
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setObject:(id)[NSString stringWithCString:dataType encoding:NSUTF8StringEncoding] forKey:(id)kSecAttrAccount];

    OSStatus err = SecItemDelete((CFDictionaryRef)query);

    if (err == noErr) {
        return 0;
    } else {
        return (int)err
    }


}
