
#import <Foundation/Foundation.h>
#import <zlib.h>

@interface ASIDataCompressor : NSObject {
	BOOL streamReady;
	z_stream zStream;
}


+ (id)compressor;



- (NSData *)compressBytes:(Bytef *)bytes length:(NSUInteger)length error:(NSError **)err shouldFinish:(BOOL)shouldFinish;


+ (NSData *)compressData:(NSData*)uncompressedData error:(NSError **)err;


+ (BOOL)compressDataFromFile:(NSString *)sourcePath toFile:(NSString *)destinationPath error:(NSError **)err;


- (NSError *)setupStream;



- (NSError *)closeStream;

@property (atomic, assign, readonly) BOOL streamReady;
@end
