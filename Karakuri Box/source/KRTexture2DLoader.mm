/*
 *  KRTexture2DLoader.mm
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRTexture2DLoader.h"
#include "KarakuriGlobals.h"
#include "KRPNGLoader.h"
#import "NSImage+CGImageConversion.h"
#import "NSImage+BXEx.h"


#define KRTextureMaxSize    1024


GLuint KRCreateGLTextureFromTexture2DAtlas(BXTexture2DSpec* tex, NSRect atlasRect, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear)
{
    NSImage* mainImage = [tex image72dpi];
    NSImage* nsImage = [mainImage subImageFromRect:atlasRect];
    
    CGImageRef imageRef = [nsImage cgImage];
    
    GLuint textureName = GL_INVALID_VALUE;
    
    imageSize->x = CGImageGetWidth(imageRef);
    imageSize->y = CGImageGetHeight(imageRef);
    textureSize->x = 1.0;
    textureSize->y = 1.0;
    
    // Adjust image size for texture
    KRVector2D revisedSize = *imageSize;
    int rwidth = imageSize->x;
    if ((rwidth != 1) && (rwidth & (rwidth - 1))) {
        int i = 1;
        while (i < rwidth) {
            i *= 2;
        }
        rwidth = i;
    }
    
    int rheight = imageSize->y;
    if ((rheight != 1) && (rheight & (rheight - 1))) {
        int i = 1;
        while (i < rheight) {
            i *= 2;
        }
        rheight = i;
    }
    
    revisedSize.x = (float)rwidth;
    revisedSize.y = (float)rheight;
    
    if (revisedSize.x > KRTextureMaxSize) {
        NSLog(@"Failed to load a texture.");
    } else if (revisedSize.y > KRTextureMaxSize) {
        NSLog(@"Failed to load a texture.");
    }
    
    textureSize->x = (float)imageSize->x / revisedSize.x;
    textureSize->y = (float)imageSize->y / revisedSize.y;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    void *imageData = malloc(revisedSize.x * revisedSize.y * 4);
    if (imageData != NULL) {
        CGContextRef bitmapContext = CGBitmapContextCreate(imageData, revisedSize.x, revisedSize.y, 8,
                                                           revisedSize.x * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
        
		CGContextClearRect(bitmapContext, CGRectMake(0, 0, revisedSize.x, revisedSize.y));
		CGContextTranslateCTM(bitmapContext, 0, revisedSize.y - imageSize->y);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0, imageSize->x, imageSize->y), imageRef);
        
        // Create new texture
        if (!_KRTexture2DEnabled) {
            _KRTexture2DEnabled = true;
            glEnable(GL_TEXTURE_2D);
        }
        
        glPixelStorei(GL_UNPACK_ROW_LENGTH, revisedSize.x);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glGenTextures(1, &textureName);
        
        if (textureName != GL_INVALID_VALUE && textureName != GL_INVALID_OPERATION) {
            glBindTexture(GL_TEXTURE_2D, textureName);
            
#ifdef __LITTLE_ENDIAN__
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, revisedSize.x, revisedSize.y, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
#else
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, revisedSize.x, revisedSize.y, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
#endif
            
            if (scalesLinear) {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            } else {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            }
        } else {
            textureName = GL_INVALID_VALUE;
        }
        
        /*{
         CGImageRef testImageRef = CGBitmapContextCreateImage(bitmapContext);
         NSURL *destUrl = [NSURL fileURLWithPath:[@"~/Desktop/test.png" stringByExpandingTildeInPath]];
         CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL((CFURLRef)destUrl, kUTTypePNG, 1, NULL);
         CGImageDestinationAddImage(imageDest, testImageRef, nil);
         CGImageDestinationFinalize(imageDest);
         CFRelease(imageDest);
         CFRelease(testImageRef);
         }*/
        
        // Clean up
        CGContextRelease(bitmapContext);
        free(imageData);                
    }
    CGColorSpaceRelease(colorSpaceRef);    
    
    CGImageRelease(imageRef);
    
    return textureName;    
}

GLuint KRCreateGLTextureFromImageWithName(NSString *imageName, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear)
{
    static BOOL hasFailedInternalPNGLoading = NO;

    NSString *imagePath = imageName;
    if (![imagePath hasPrefix:@"/"]) {
        imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    }
    if (!imagePath) {
        return GL_INVALID_VALUE;
    }
    
    if (!hasFailedInternalPNGLoading && [[imageName pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        GLuint textureName = KRCreatePNGGLTextureFromImageAtPath(imagePath, imageSize, textureSize, scalesLinear);
        if (textureName != GL_INVALID_VALUE) {
            *textureTarget = GL_TEXTURE_2D;
            return textureName;
        }
        hasFailedInternalPNGLoading = YES;
    }

    // Build up bitmap data
    CFURLRef fileURLRef = CFURLCreateWithFileSystemPath(NULL, (CFStringRef) imagePath, kCFURLPOSIXPathStyle, 0);
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL(fileURLRef, NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    
    GLuint textureName = GL_INVALID_VALUE;

    imageSize->x = CGImageGetWidth(imageRef);
    imageSize->y = CGImageGetHeight(imageRef);
    textureSize->x = 1.0;
    textureSize->y = 1.0;
    
    // Adjust image size for texture
    KRVector2D revisedSize = *imageSize;
    int rwidth = imageSize->x;
    if ((rwidth != 1) && (rwidth & (rwidth - 1))) {
        int i = 1;
        while (i < rwidth) {
            i *= 2;
        }
        rwidth = i;
    }

    int rheight = imageSize->y;
    if ((rheight != 1) && (rheight & (rheight - 1))) {
        int i = 1;
        while (i < rheight) {
            i *= 2;
        }
        rheight = i;
    }
    
    revisedSize.x = (float)rwidth;
    revisedSize.y = (float)rheight;
    
    if (revisedSize.x > KRTextureMaxSize) {
        const char *errorFormat = "Failed to load \"%s\". Texture width should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。テクスチャの横幅は %d ピクセル以下でなければいけません。";
        }
        NSLog(@"%s", KRFS(errorFormat, [imageName cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize).c_str());
    } else if (revisedSize.y > KRTextureMaxSize) {
        const char * errorFormat = "Failed to load \"%s\". Texture height should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。テクスチャの高さは %d ピクセル以下でなければいけません。";
        }
        NSLog(@"%s", KRFS(errorFormat, [imageName cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize).c_str());
    }
    
    textureSize->x = (float)imageSize->x / revisedSize.x;
    textureSize->y = (float)imageSize->y / revisedSize.y;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    void *imageData = malloc(revisedSize.x * revisedSize.y * 4);
    if (imageData != NULL) {
        CGContextRef bitmapContext = CGBitmapContextCreate(imageData, revisedSize.x, revisedSize.y, 8,
                                                           revisedSize.x * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);

		CGContextClearRect(bitmapContext, CGRectMake(0, 0, revisedSize.x, revisedSize.y));
		CGContextTranslateCTM(bitmapContext, 0, revisedSize.y - imageSize->y);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0, imageSize->x, imageSize->y), imageRef);
        
        // Create new texture
        if (!_KRTexture2DEnabled) {
            _KRTexture2DEnabled = true;
            glEnable(GL_TEXTURE_2D);
        }

        glPixelStorei(GL_UNPACK_ROW_LENGTH, revisedSize.x);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glGenTextures(1, &textureName);
        
        if (textureName != GL_INVALID_VALUE && textureName != GL_INVALID_OPERATION) {
            glBindTexture(GL_TEXTURE_2D, textureName);
            
#ifdef __LITTLE_ENDIAN__
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, revisedSize.x, revisedSize.y, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
#else
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, revisedSize.x, revisedSize.y, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
#endif
            
            if (scalesLinear) {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            } else {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            }
        } else {
            textureName = GL_INVALID_VALUE;
        }
        
        /*{
            CGImageRef testImageRef = CGBitmapContextCreateImage(bitmapContext);
            NSURL *destUrl = [NSURL fileURLWithPath:[@"~/Desktop/test.png" stringByExpandingTildeInPath]];
            CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL((CFURLRef)destUrl, kUTTypePNG, 1, NULL);
            CGImageDestinationAddImage(imageDest, testImageRef, nil);
            CGImageDestinationFinalize(imageDest);
            CFRelease(imageDest);
            CFRelease(testImageRef);
        }*/

        // Clean up
        CGContextRelease(bitmapContext);
        free(imageData);                
    }
    CGColorSpaceRelease(colorSpaceRef);    

    CGImageRelease(imageRef);
    CFRelease(imageSourceRef);
    CFRelease(fileURLRef);
    
    // Return
    return textureName;
}

GLuint KRCreateGLTextureFromString(NSString *str, void *fontObj, const KRColor& color, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize)
{
    NSDictionary *attrDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              (NSFont *)fontObj, NSFontAttributeName,
                              [NSColor colorWithCalibratedRed:color.r green:color.g blue:color.b alpha:color.a], NSForegroundColorAttributeName,
                              nil];
    
    NSSize size;
    if ([str length] > 0) {
        size = [str sizeWithAttributes:attrDict];
    } else {
        size = NSMakeSize(1.0f, 1.0f);
    }
    
    NSSize revisedSize = size;
    int rwidth = revisedSize.width;
    if ((rwidth != 1) && (rwidth & (rwidth - 1))) {
        int i = 1;
        while (i < rwidth) {
            i *= 2;
        }
        rwidth = i;
    }
    
    int rheight = revisedSize.height;
    if ((rheight != 1) && (rheight & (rheight - 1))) {
        int i = 1;
        while (i < rheight) {
            i *= 2;
        }
        rheight = i;
    }
    
    revisedSize.width = (float)rwidth;
    revisedSize.height = (float)rheight;
    
    if (revisedSize.width > KRTextureMaxSize) {
        const char *errorFormat = "Failed to create a string texture (\"%s\"). Texture width should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "文字列テクスチャの生成に失敗しました（\"%s\"）。テクスチャの横幅は %d ピクセル以下でなければいけません。";
        }
        NSLog(@"%s", KRFS([str cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize).c_str());
    } else if (revisedSize.height > KRTextureMaxSize) {
        const char *errorFormat = "Failed to create a string texture (\"%s\"). Texture height should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "文字列テクスチャの生成に失敗しました（\"%s\"）。テクスチャの高さは %d ピクセル以下でなければいけません。";
        }
        NSLog(@"%s", KRFS(errorFormat, [str cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize).c_str());
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:revisedSize];
    [image lockFocus];
    if ([str length] > 0) {
        [str drawAtPoint:NSMakePoint(0, revisedSize.height-size.height) withAttributes:attrDict];
    }
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0f, 0.0f, revisedSize.width, revisedSize.height)];
    [image unlockFocus];

    GLuint texName = GL_INVALID_VALUE;
    *textureTarget = GL_TEXTURE_2D;
    
	glEnable(GL_TEXTURE_2D);
    if (!_KRTexture2DEnabled) {
        _KRTexture2DEnabled = true;
        glEnable(GL_TEXTURE_2D);
    }
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, revisedSize.width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &texName);
    
    if (texName != GL_INVALID_VALUE && texName != GL_INVALID_OPERATION) {
        glBindTexture(GL_TEXTURE_2D, texName);

        unsigned *p = (unsigned *)[bitmap bitmapData];
        for (int i = 0; i < rwidth * rheight; i++) {
#ifdef __LITTLE_ENDIAN__
            p[i] |= 0x00ffffff;
#else
            p[i] |= 0xffffff00;
#endif
        }
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, revisedSize.width, revisedSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [bitmap bitmapData]);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    } else {
        texName = GL_INVALID_VALUE;
    }
    
	//glDisable(GL_TEXTURE_2D);
    
    //[[bitmap TIFFRepresentation] writeToFile:[@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:NO];
    
    [bitmap release];
	[image release];
    
    imageSize->x = size.width;
    imageSize->y = size.height;
    textureSize->x = (float)imageSize->x / revisedSize.width;
    textureSize->y = (float)imageSize->y / revisedSize.height;
    
    [attrDict release];

    return texName;
}





