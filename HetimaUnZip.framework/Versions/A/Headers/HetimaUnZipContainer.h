
/*

unZipObjectWithZipFile: か initWithZipFile: で生成
- (NSMutableArray*)contents で一覧

画像をフィルタリングとか付したい場合は setListOnlyRealFile: を YES
setExtensionFilter: に画像の拡張子(小文字)を設定します

NSArray* extArray=[NSArray arrayWithObjects:@"jpg",@"jpeg",@"tif",@"tiff",@"png",nil];
HetimaUnZipContainer* container=[HetimaUnZipContainer
    unZipObjectWithZipFile:filePath listOnlyRealFile:YES extensionFilter:extArray];
[container retain];

てな感じで

*/

#import <Foundation/Foundation.h>

#ifndef HETIMA_UNZIP_FRAMEWORK
    typedef void* unzFile;
#else
    #import "unzip.h"
#endif


@interface HetimaUnZipContainer : NSObject {
    unzFile     uf;
    Class       _itemClass;
    NSString*   _file;
    NSMutableArray*    _contents;
    BOOL                _crypted;
    NSStringEncoding   _encoding;
    BOOL        _keepData;
    NSString*   _password;
    char*       _rawPassword;
    NSArray*    _extensionFilter;
    BOOL        _listOnlyRealFile;
	NSLock*		_loadDataLock;
}

+ (id)unZipContainerWithZipFile:(NSString*)file;
//オプションを設定しつつ初期化。 inArray は nil でもよい
+ (id)unZipContainerWithZipFile:(NSString*)file listOnlyRealFile:(BOOL)inBool extensionFilter:(NSArray*)inArray;
- (id)initWithZipFile:(NSString*)file;

// ---- 設定するなら生成した直後に ----
// フォルダを除外するかどうか default=NO
- (BOOL)listOnlyRealFile;
- (void)setListOnlyRealFile:(BOOL)inBool;
// これらの拡張子だけリストアップ
- (NSArray*)extensionFilter;
- (void)setExtensionFilter:(NSArray*)inArray;
// HetimaUnZipItem 以外のitemClass を使いたいとき
// HetimaUnZipItem のサブクラス（あるいは initWithContainer:rawName:zipInfo: が実装されているクラス）を指定してください
- (Class)itemClass;
- (void)setItemClass:(Class)aClass;


// 中身のリスト。HetimaUnZipItem の array。いらないものは removeObject: しても良いです。
- (NSMutableArray*)contents;

// 内部パスの文字コード
- (NSStringEncoding)encoding;
// 手動で設定したいときはこれで
- (void)setEncoding:(NSStringEncoding)inEncoding;

// ----パスワード付きzip用 ----
// パスワード付きならYES
- (BOOL)crypted;
// パスワードを設定
- (void)setPassword:(NSString*)newPassword;
- (NSString*)password;
// これは内部利用、
- (const char*)_rawPassword;

// 解凍データをHetimaUnZipItemに保持しておくかどうか default=YES
- (BOOL)keepData;
- (void)setKeepData:(BOOL)inBool;


// 以下は内部利用、
- (unzFile)_ref;

- (void)loadDataLock;
- (void)loadDataUnlock;
@end

