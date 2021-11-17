//
//  main.m
//  ResizeImage
//
//  Created by Jerry.Yang on 2020/6/9.
//  Copyright © 2020 Jerry.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
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


NSImage * zoom(NSImage *image,CGFloat width){
    //        NSImage *image = ...
    // 缩放 image
    NSImage *smallImage = [[NSImage alloc] initWithSize: CGSizeMake(width, width)];
    [smallImage lockFocus];
    [image setSize: CGSizeMake(width, width)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, width, width) operation:NSCompositingOperationCopy fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
}


/*
 * 8 = 16 x 16
 * 16 = 32 x 32
 * 512 = 1024 x 1024
 */
/*
 argv[0] : 程序本身的fullpath
 argv[1] : 第一个参数
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        NSLog(@"Hello, World!");
        if (argc<2 || argc>3){
//            NSLog(@"Just Need 1 argument: image_file_path");
            printf("when ther is 1 argument, appicon   : image_file_path\n");
            printf("when ther is 2 argument, image sets: image_file_path base_pixels\n");
            printf("use option -h can get more information\n");
            return -1;
        }
        NSString *toolpath = [NSString stringWithUTF8String:argv[0]];
        NSURL *toolURL = [NSURL URLWithString:toolpath];
        NSString *toolName = [toolURL lastPathComponent];
        NSString *file = [NSString stringWithUTF8String:argv[1]];
        if ([file isEqualToString:@"-h"]) {
            printf("Usage: %s Image_file_path [base_pixels]\n",toolName.UTF8String);
            return 0;
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
            printf("the file don't exists:%s\n",file.UTF8String);
//            NSLog(@"the file don't exists:%@",file);
            return -2;
        }
        NSURL *fileURL = [NSURL URLWithString:file];
//        NSString *fullname = [fileURL lastPathComponent];
        NSString *path = [fileURL URLByDeletingLastPathComponent].path;
//        NSString *extention = [fileURL pathExtension];
        NSString *name=[[fileURL URLByDeletingPathExtension] lastPathComponent];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
        if (argc==2){
            for (int i=8; i<1024; i=i*2) {
                NSImage *small = zoom(image, i);
                NSString *savePath = [NSString stringWithFormat:@"%@/%@_%dx%d.png",path,name,i*2,i*2];
                NSURL *saveURL = [NSURL URLWithString:savePath];
                printf("create: %s\n",saveURL.lastPathComponent.UTF8String);
                saveImage_png(small, savePath);
            }
        }
        else if (argc==3){
            NSString *base = [NSString stringWithUTF8String:argv[2]];
            if (base && base.length>0 && [base stringByReplacingOccurrencesOfString:@" " withString:@""]>0){
                float b = [base floatValue];
                float halfb = b/2;
                for (int i=1;i<=3;i++){
                    float s=halfb*i;
                    NSImage *small = zoom(image, s);
                    NSString *savePath = [NSString stringWithFormat:@"%@/%@_icon_%dx%d.png",path,name,(int)b*i,(int)b*i];
                    NSURL *saveURL = [NSURL URLWithString:savePath];
                    printf("create: %s\n",saveURL.lastPathComponent.UTF8String);
                    saveImage_png(small, savePath);
                }
            }
        }
    }
    return 0;
}
