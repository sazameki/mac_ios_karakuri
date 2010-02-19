/*
 *  KRTexture2DLoader.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRTexture2DLoader.h>

#include "KRPNGLoader.h"

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


#define KRTextureMaxSize    1024


typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGBA5551,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_RGB888,
	kTexture2DPixelFormat_L8,
	kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
	kTexture2DPixelFormat_RGB_PVRTC2,
	kTexture2DPixelFormat_RGB_PVRTC4,
	kTexture2DPixelFormat_RGBA_PVRTC2,
	kTexture2DPixelFormat_RGBA_PVRTC4
} Texture2DPixelFormat;


static GLuint _KRCreateGLTextureFromData(const void *data, Texture2DPixelFormat pixelFormat, NSUInteger width, NSUInteger height, CGSize contentSize, KRVector2D *imageSize_, KRVector2D *textureSize_, BOOL isFont)
{
    GLuint  _name;
	GLint   saveName;
	
    glGenTextures(1, &_name);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
    glBindTexture(GL_TEXTURE_2D, _name);
    if (isFont) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    }
    switch (pixelFormat) {
        case kTexture2DPixelFormat_RGBA8888:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
            break;
            
        case kTexture2DPixelFormat_RGBA4444:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
            break;
            
        case kTexture2DPixelFormat_RGBA5551:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
            break;
            
        case kTexture2DPixelFormat_RGB565:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
            break;
            
        case kTexture2DPixelFormat_RGB888:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
            break;
            
        case kTexture2DPixelFormat_L8:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
            break;
            
        case kTexture2DPixelFormat_A8:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
            break;
            
        case kTexture2DPixelFormat_LA88:
            glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
            break;
            
        case kTexture2DPixelFormat_RGB_PVRTC2:
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
            break;
            
        case kTexture2DPixelFormat_RGB_PVRTC4:
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
            break;
            
        case kTexture2DPixelFormat_RGBA_PVRTC2:
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
            break;
            
        case kTexture2DPixelFormat_RGBA_PVRTC4:
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@""];
            
    }
    glBindTexture(GL_TEXTURE_2D, saveName);
    
    GLenum error = glGetError();
    if (error) {
        NSLog(@"KRTexture2DLoader: OpenGL error 0x%04X", error);
        return GL_INVALID_VALUE;
    }
    
    imageSize_->x = width * contentSize.width / (float)width;
    imageSize_->y = height * contentSize.height / (float)height;
    
    textureSize_->x = contentSize.width / (float)width;
    textureSize_->y = contentSize.height / (float)height;
    
    return _name;
}

static GLuint _KRCreateGLTextureFromCGImage(CGImageRef imageRef, UIImageOrientation orientation, BOOL sizeToFit, Texture2DPixelFormat pixelFormat, KRVector2D *imageSize_, KRVector2D *textureSize_, NSString *imageName)
{
    NSUInteger				width;
    NSUInteger              height;
    NSUInteger              i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned char*			inPixel8;
	unsigned int*			inPixel32;
	unsigned char*			outPixel8;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	
	if (imageRef == NULL) {
        return GL_INVALID_VALUE;
	}
	
	if (pixelFormat == kTexture2DPixelFormat_Automatic) {
		info = CGImageGetAlphaInfo(imageRef);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if (CGImageGetColorSpace(imageRef)) {
			if (CGColorSpaceGetModel(CGImageGetColorSpace(imageRef)) == kCGColorSpaceModelMonochrome) {
				if (hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
				}
			}
			else {
				if((CGImageGetBitsPerPixel(imageRef) == 16) && !hasAlpha)
                    pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if(hasAlpha)
                        pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGB565;
					}
				}
			}		
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
		}
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
	switch (orientation) {
		case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
		case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
		case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
		case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
		case UIImageOrientationLeftMirrored: //EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
		case UIImageOrientationLeft: //EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
		case UIImageOrientationRightMirrored: //EXIF = 7
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
		case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
		default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
	}
	if ((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) ||
        (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
    {
        imageSize = CGSizeMake(imageSize.height, imageSize.width);
    }
	
	width = imageSize.width;
	if ((width != 1) && (width & (width - 1))) {
		i = 1;
		while ((sizeToFit ? 2 * i : i) < width) {
            i *= 2;
        }
		width = i;
	}
	height = imageSize.height;
	if ((height != 1) && (height & (height - 1))) {
		i = 1;
		while ((sizeToFit ? 2 * i : i) < height)
            i *= 2;
		height = i;
	}

	if (width > KRTextureMaxSize) {
        const char *errorFormat = "Failed to load \"%s\". Texture width should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。テクスチャの横幅は %d ピクセル以下でなければいけません。";
        }
        throw KRRuntimeError(errorFormat, [imageName cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize);
	}
	if (height > KRTextureMaxSize) {
        const char *errorFormat = "Failed to load \"%s\". Texture height should be equal to or lower than %d pixels.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。テクスチャの高さは %d ピクセル以下でなければいけません。";
        }
        throw KRRuntimeError(errorFormat, [imageName cStringUsingEncoding:NSUTF8StringEncoding], KRTextureMaxSize);
	}

	switch (pixelFormat) {
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_RGBA5551:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 2);
            context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_RGB888:
		case kTexture2DPixelFormat_RGB565:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_L8:
            colorSpace = CGColorSpaceCreateDeviceGray();
            data = malloc(height * width);
            context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_A8:
            data = malloc(height * width);
            context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
            break;
            
		case kTexture2DPixelFormat_LA88:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
            
	}
	if (context == NULL) {
		NSLog(@"KRTexture2DLoader: Failed creating CGBitmapContext.");
		free(data);
		return GL_INVALID_VALUE;
	}
	
	if(sizeToFit)
        CGContextScaleCTM(context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
	else {
		CGContextClearRect(context, CGRectMake(0, 0, width, height));
		CGContextTranslateCTM(context, 0, height - imageSize.height);
	}
	if (!CGAffineTransformIsIdentity(transform)) {
        CGContextConcatCTM(context, transform);
    }
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
	
	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if (pixelFormat == kTexture2DPixelFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for (i = 0; i < width * height; ++i, ++outPixel16) {
            *outPixel16 = *outPixel16 << 1 | 0x0001;
        }
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if (pixelFormat == kTexture2DPixelFormat_RGB888) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if (pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32) {
            *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
        }
		free(data);
		data = tempData;
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for (i = 0; i < width * height; ++i, ++inPixel32) {
            *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
        }
		free(data);
		data = tempData;
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if (pixelFormat == kTexture2DPixelFormat_LA88) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for (i = 0; i < width * height; i++) {
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
	}
    
    GLuint ret = _KRCreateGLTextureFromData(data, pixelFormat, width, height, imageSize, imageSize_, textureSize_, NO);
	
	CGContextRelease(context);
	free(data);
	
	return ret;
}

GLuint KRCreateGLTextureFromImageWithName(NSString *imageName, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear)
{
    static BOOL hasFailedInternalPNGLoading = NO;
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];

    if (!hasFailedInternalPNGLoading && [[imageName pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        GLuint textureName = KRCreatePNGGLTextureFromImageAtPath(imagePath, imageSize, textureSize, scalesLinear);
        if (textureName != GL_INVALID_VALUE) {
            *textureTarget = GL_TEXTURE_2D;
            return textureName;
        }
        hasFailedInternalPNGLoading = YES;
    }
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    GLuint ret = _KRCreateGLTextureFromCGImage([image CGImage], [image imageOrientation], NO, kTexture2DPixelFormat_Automatic, imageSize, textureSize, imageName);
    
    [image release];
    
    return ret;
}

GLuint KRCreateGLTextureFromString(NSString *str, void *fontObj, const KRColor& color, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize)
{
    CGColorSpaceRef			colorSpace;
	void*					data;
	CGContextRef			context;
    
    CGSize size = [str sizeWithFont:(UIFont *)fontObj];
    CGSize revisedSize = size;
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

    colorSpace = CGColorSpaceCreateDeviceRGB();
	data = malloc((int)revisedSize.width * (int)revisedSize.height * 4);
	context = CGBitmapContextCreate(data, (int)revisedSize.width, (int)revisedSize.height, 8, (int)revisedSize.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, revisedSize.width, revisedSize.height));
	CGColorSpaceRelease(colorSpace);
	if (context == NULL) {
		NSLog(@"Failed creating CGBitmapContext!!");
		free(data);
		return GL_INVALID_VALUE;
	}
    
	CGContextTranslateCTM(context, 0.0, revisedSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	UIGraphicsPushContext(context);
    CGContextSetRGBFillColor(context, color.r, color.g, color.b, color.a);
    [str drawAtPoint:CGPointMake(0.0, 0.0f) withFont:(UIFont *)fontObj];
	UIGraphicsPopContext();

    *textureTarget = GL_TEXTURE_2D;
    
    unsigned *p = (unsigned *)data;
    for (int i = 0; i < rwidth * rheight; i++) {
        p[i] |= 0x00ffffff;
    }    

	GLuint ret = _KRCreateGLTextureFromData(data, kTexture2DPixelFormat_RGBA8888, revisedSize.width, revisedSize.height, size, imageSize, textureSize, YES);
	
    imageSize->x = size.width;
    imageSize->y = size.height;
    textureSize->x = size.width / revisedSize.width;
    textureSize->y = size.height / revisedSize.height;

	CGContextRelease(context);
	free(data);

    return ret;
}



