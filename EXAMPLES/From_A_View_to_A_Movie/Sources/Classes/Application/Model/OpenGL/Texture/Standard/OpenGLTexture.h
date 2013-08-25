//---------------------------------------------------------------------------
//
//	File: GLSLShaderKit.h
//
//  Abstract: Utility toolkit for handling shader's texture
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//  Computer, Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Computer,
//  Inc. may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2008-2009 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

typedef struct OpenGLTextureAttributes *OpenGLTextureAttributesRef;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@interface OpenGLTexture : NSObject
{
	@private
		OpenGLTextureAttributesRef  textureAttribs;
} // OpenGLTexture

//---------------------------------------------------------------------------
//
// Generate a texture using attributes in the provided dictionary.
// If using this designated initializer, one need to implement the
// data source provider method "texturePixels:height:depth:".
//
//---------------------------------------------------------------------------

- (id) initTextureWithDictionary:(NSDictionary *)theTextureDict;

//---------------------------------------------------------------------------
//
// Generate a texture using attributes in the provided dictionary and the
// given pixels.
//
//---------------------------------------------------------------------------

- (id) initTextureWithDictionary:(NSDictionary *)theTextureDict
						  pixels:(const GLvoid *)thePixels;

//---------------------------------------------------------------------------
//
// Accessor for a texture
//
//---------------------------------------------------------------------------

- (BOOL)   isValid;
- (GLenum) target;
- (GLuint) name;
- (GLenum) active;

//---------------------------------------------------------------------------
//
// Bind the texture held by an instance of this method
//
//---------------------------------------------------------------------------

- (void) bind;

//---------------------------------------------------------------------------
//
// A generic method that provides the pixels for a texture. Once subclassed, 
// one must override this method, so that a particular 1D, 2D, or 3D texture
// will be generated properly using the data source (or pixels) provided by 
// this method.
//
//---------------------------------------------------------------------------

- (GLvoid *) texturePixels:(const NSInteger)theTextureWidth 
					height:(const NSInteger)theTextureHeight 
					 depth:(const NSInteger)theTextureDepth;

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
