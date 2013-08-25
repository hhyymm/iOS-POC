//---------------------------------------------------------------------------
//
//	File: OpenGLTrackball.mm
//
//  Abstract: Utility class for managing a virtual sphere's (trackball)
//            interaction with an OpenGL world.
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms, 
//  and your use, installation, modification or redistribution of this Apple 
//  software constitutes acceptance of these terms.  If you do not agree with 
//  these terms, please do not use, install, modify or redistribute this 
//  Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Inc. may 
//  be used to endorse or promote products derived from the Apple Software 
//  without specific prior written permission from Apple.  Except as 
//  expressly stated in this notice, no other rights or licenses, express
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
//  Copyright (c) 2003-2009 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//
// The trackball works by assuming that a sphere encloses the 3D view. You 
// roll this virtual sphere with the mouse.  For example, if you click on 
// the center of the sphere and move the mouse straight to the right, you 
// roll the sphere around its Y-axis.  This produces a Y-axis rotation.  
// You can click on the "edge" of the sphere and roll it around in a circle 
// to get a Z-axis rotation.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <math.h>

#include "Vector.hpp"
#include "Quaternion.hpp"

//---------------------------------------------------------------------------

#import "OpenGLTrackball.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#define kPi 3.1415927f // IEEE-754 single precision

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

static const GLfloat kDeltaTolerance  = 0.001;
static const GLfloat kFPTolerance     = 1.0e-7; // IEEE-754 single precision
static const GLfloat kRadians2Degrees = 180.0f/kPi;
static const GLfloat kDegrees2Radians = kPi/180.0f;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

struct OpenGLTrackballAttributes
{
	GLfloat   radius;
	FVector3  center;
	FVector3  start;
	FVector3  end;
};

typedef struct	OpenGLTrackballAttributes OpenGLTrackballAttributes;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLTrackball

//---------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		trackballAttribs = (OpenGLTrackballAttributesRef)malloc(sizeof(OpenGLTrackballAttributes));
		
		if( trackballAttribs != NULL )
		{
			trackballAttribs->radius = 0.0f;
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Trackball - Can not allocate memory for attributes!" );
		} // else
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------

- (void) cleanUpTrackball
{
	if( trackballAttribs != NULL )
	{
		free( trackballAttribs );
		
		trackballAttribs = NULL;
	} // if
} // cleanUpTrackball

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpTrackball];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//
// Start up the trackball.  Inputs are mouse positon and view size.
//
// The math behind the trackball is simple: start with a vector from the 
// first mouse-click on the sphere to the center of the 3D view.  At the  
// same time, set the radius of the sphere to be the smaller dimension of  
// the 3D view.  As you drag the mouse around in the 3D view, a second  
// vector is computed from the surface of the sphere to the center.  The  
// axis of rotation is the cross product of these two vectors, and the   
// angle of rotation is the angle between the two vectors.
//
//---------------------------------------------------------------------------

- (void) start:(const NSPoint *)thePosition 
		origin:(const NSPoint *)theOrigin 
		  size:(const NSSize *)theSize 
{
	FVector3 bounds(0.5f * theSize->width, 0.5f * theSize->height);
	FVector3 position(thePosition->x, thePosition->y);
	FVector3 origin(theOrigin->x, theOrigin->y);
	
    // Compute the center of a view.
	
	trackballAttribs->center = origin + bounds;
    
    // Compute the starting vector from the sphere surface to its center.
	
	trackballAttribs->start = position - trackballAttribs->center;
	
	if( bounds.x > bounds.y )
	{
        trackballAttribs->radius = bounds.y;
	} // if
    else
	{
        trackballAttribs->radius = bounds.x;
	} // else
	
	trackballAttribs->start.z = trackballAttribs->start.IsInsideSphere( trackballAttribs->radius );
} // start

//---------------------------------------------------------------------------
//
// Calculate rotation based on current mouse position.  Output is the 
// rotation angle.
//
//---------------------------------------------------------------------------

- (void) rollTo:(const NSPoint *)thePosition
	   rotation:(GLfloat *)theRotation
{
	FVector3 position(thePosition->x, thePosition->y);

	trackballAttribs->end = position - trackballAttribs->center;
	
	// Has there been a change in the (x,y) componets of our 3-vector?

	FPosition3 d = trackballAttribs->end.diff(trackballAttribs->start);
	
	if( ( d.x >= kDeltaTolerance ) && ( d.y >= kDeltaTolerance ) )
	{
		// There has been sufficent amount of change in our 
		// 3-vector to warrant continuing further.
		
		GLfloat A  = 0.0f;	// sin( angle )
		GLfloat B  = 0.0f;	// cos( angle )
		GLfloat c  = 0.0f;
		GLfloat ls = 0.0f;
		GLfloat le = 0.0f;
		GLfloat lr = 0.0f;
		
		// Compute the end-vector from the surface of the sphere to its center.
		
		trackballAttribs->end.z = trackballAttribs->end.IsInsideSphere( trackballAttribs->radius );
		
		// ls = 1 / || s ||
		
		ls = 1 / trackballAttribs->start.magnitude();
		
		// le = 1 / || e ||
		
		le = 1 / trackballAttribs->end.magnitude();
		
		// c = s * e; interior product
		
		c = trackballAttribs->start * trackballAttribs->end;
		
		// B = cos(a) = (s . e) / (||s|| ||e||)
		
		B = ls * le * c;
		
		// r = s ^ e; exterior product
		
		FVector3 r = trackballAttribs->start ^ trackballAttribs->end;
		
		// lr = || r || = ||(s ^ e)||
		
		lr = r.magnitude();
		
		// A = sin(a) = ||(s ^ e)|| / (||s|| ||e||)
		
		A = ls * le * lr;
		
		// Normalize the rotation axis.
		
		lr = 1 / lr;
		
		// GL rotations are in degrees.
		
		// Use atan for a better angle.  Note that when using acos or asin, 
		// you only get half the possible angles, and you can end up with 
		// rotations that flip around and near the poles.
		
		theRotation[0] = kRadians2Degrees * atan2f( A, B );
		
		theRotation[1] = lr * r.x; 
		theRotation[2] = lr * r.y; 
		theRotation[3] = lr * r.z;
		
		// returns rotation
	} // if
} // rollTo

//---------------------------------------------------------------------------
//
// Determine A' = A . dA
//
// (1) In quaternions: let P <- A, and Q <- dA.
// (2) Compute the Hamilton product, R = P ^ Q.
// (3) Then, A' <- R if R is not identity rotation.
//
//---------------------------------------------------------------------------

- (void) addToRotation:(const GLfloat *)dA
	  existingRotation:(GLfloat *)A
{
	FQuaternion P;
	FQuaternion Q;
	FQuaternion R;
	
	P.RotationToQuaternion(A);
	Q.RotationToQuaternion(dA);
    
	// Avoid floating point errors by renormalizing quaternions
	// if it was necessary
	
	P.renormalize(kFPTolerance);
	Q.renormalize(kFPTolerance);
	
    // Compute the Hamilton product
	
	R =  P ^ Q;
    
    // Check for identity rotation.
	
	if( !R.IsIdentityRotation(kFPTolerance,A) )
	{
		// Encountered a non-identity rotation, hence, the 
		// cosine of the half-angle is non-zero, which implies 
		// that the sine of the angle is also non-zero.  As a 
		// result, it is safe to divide by sine of the angle 
		// theta.
		
		// Turn the quaternion back into an {angle, {axis}} rotation.
		
		R.QuaternionToRotation(A);
	} // if
} // addToRotation

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
