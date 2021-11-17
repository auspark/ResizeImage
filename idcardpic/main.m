//
//  main.m
//  idcardpic
//
//  Created by Jerry.Yang on 2020/10/22.
//  Copyright © 2020 Jerry.Yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>


void saveImage_png(NSImage *image,NSString *name){
//    NSImage *image = [[NSImage alloc] initWithContentsOfFile:@"filePath"];
    NSData *data = [image TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgimage];
    // rep.size = CGSizeMake(width, width);
    NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    // pngData 写入磁盘 or 其他处理
    /*
     - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
     这个参数为NO和YES都能写入文件
     YES:保证文件的写入原子性,
         会先创建一个临时文件,直到文件内容写入成功再导入到目标文件里.
     NO:则直接写入目标文件里.
     */
    [pngData writeToFile:name atomically:NO];
}


NSImage * zoom(NSImage *image,CGFloat width,CGFloat hight){
    //        NSImage *image = ...
    // 缩放 image
    NSImage *smallImage = [[NSImage alloc] initWithSize: CGSizeMake(width, hight)];
    [smallImage lockFocus];
    [image setSize: CGSizeMake(width, hight)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, width, hight) operation:NSCompositingOperationCopy fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSString *file=@"/Users/jerry.yang/Documents/idcard.png";
        NSURL *fileURL = [NSURL URLWithString:file];
        NSString *path = [fileURL URLByDeletingLastPathComponent].path;
        NSString *name=[[fileURL URLByDeletingPathExtension] lastPathComponent];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
        // 358 * 441
        CGFloat width=358/2;
        CGFloat hight=441.0/2.0;
        NSImage *small = zoom(image, width,hight);
        NSString *savePath = [NSString stringWithFormat:@"%@/%@_%dx%d.png",path,name,width,hight];
        NSURL *saveURL = [NSURL URLWithString:savePath];
        printf("create: %s\n",saveURL.lastPathComponent.UTF8String);
        saveImage_png(small, savePath);
    }
    return 0;
}
