#import <UIKit/UIKit.h>
#import <Security/Security.h>

#define SERVICE_NAME    @"com.ksks.ksks"

extern "C" {
char* _Get(const char *cdataType);
int _AddItem(const char *dataType, const char *value);
}


//検索の際にkSecAttrService, kSecAttrAccountの二つがユニークな値として扱われる。
/// <param name="dataType">Type of data. emailAddress, 'token', 'refreshToken'</param>
/// <returns>value(pass, token) if NULL = error</returns>
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

//kSecAttrServiceにはbundleidentifer, kSecAttrAccountには検索のための情報を入れておくのが良さそう
//exp.)emailAddress, 'token', 'refreshToken'
//emailAddressとパスワードの組み合わせが一般的
/// <param name="dataType">Type of data. emailAddress, 'token', 'refreshToken'</param>
/// <param name="password">password or token</param>
/// <returns>status 0 = noERR</returns>
int _AddItem(const char *dataType, const char *value)
{
    NSMutableDictionary* attributes = nil;
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    NSData* sata = [[NSString stringWithCString:value encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];


    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    //アカウントID（emailアドレスの受けとり）
    [query setObject:(id)[NSString stringWithCString:dataType encoding:NSUTF8StringEncoding] forKey:(id)kSecAttrAccount];
    [query setObject:SERVICE_NAME forKey:(id)kSecAttrService];
    
    //アカウント名で検索
    OSStatus err = SecItemCopyMatching((CFDictionaryRef)query, NULL);
    
    //エラーがない=すでにデータが存在している場合はpasswaordと日時指定くらい
    if (err == noErr) {
        // update item
        attributes = [NSMutableDictionary dictionary];
        [attributes setObject:sata forKey:(id)kSecValueData];
        [attributes setObject:[NSDate date] forKey:(id)kSecAttrModificationDate];
        
        err = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
        return (int)err;

    //エラーがある=データの最初の登録では設定すべき事項がいくつかある
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
