//
//  AppDelegate.m
//  ScatterViewer
//
//  Created by Koichi Oshio on 3/24/20.
//  Copyright © 2020 Koichi Oshio. All rights reserved.
//

#import "AppControl.h"

@class RecImage;

@implementation AppControl

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
//	[NSApp setDelegate:self];
	control1 = [control1 init];
	control2 = [control2 init];
	controlSct = [controlSct init];
	[control1 setTag:1];
	[control2 setTag:2];
	[controlSct setTag:3];
	
	[[control1 view] setTag:1];
	[[control2 view] setTag:2];
	[[controlSct view] setTag:3];
	vGain = 1.0;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

- (void)open:(id)sender
{
	// open image#1 or Image#2 according to tag of sender
	if ([(NSButton *)sender tag] == 1) {
		[control1 open];
	} else {
		[control2 open];
	}
	[self updateSct:self];
}

- (IBAction)next:(id)sender
{
	[control1 forward:self];
	[control2 forward:self];
}

- (IBAction)prev:(id)sender
{
	[control1 backward:self];
	[control2 backward:self];
}

- (IBAction)zoomIn:(id)sender
{
	[control1 zoomIn:self];
	[control2 zoomIn:self];
}

- (IBAction)zoomOut:(id)sender
{
	[control1 zoomOut:self];
	[control2 zoomOut:self];
}

- (IBAction)updateSct:(id)sender
{
	RecImage	*img1, *img2;
	RecImage	*sct;
	int			dim = 256;
	float		mx, my;

// get images
	if ([control1 nImages] == 0 || [control2 nImages] == 0) {
		return;
	}
	img1 = [control1 selectedImage];
	img2 = [control2 selectedImage];
	if ([img1 xDim] != [img2 xDim] || [img2 yDim] != [img2 yDim]) {
		return;
	}
	mx = [img1 maxVal];
	my = mx / vGain;

// calc hist
	sct = [RecImage imageOfType:RECIMAGE_REAL xDim:dim yDim:dim];
	[sct histogram2dWithX:img1 andY:img2 xMin:0 xMax:mx yMin:0 yMax:my];

// normalize
	mx = [sct maxVal];
	[sct multByConst:1000.0/mx];

// set image
    [controlSct setImage:sct];
    [controlSct setDispBuf];
    [[controlSct view] initImage:[sct xDim]:[sct yDim]];
	[controlSct updateWinLev];
	[controlSct displayImage];
}

- (IBAction)vGainChanged:(id)sender
{
	vGain = [self vGain];
	[self updateSct:self];
}

- (float)vGain
{
	return exp((float)[(NSMenuItem *)[vGainButton selectedCell] tag]);
}

- (void)reportCursorAt:(NSPoint)pos from:(id)sender
{
	int				tag = (int)[(KOImageControl *)sender tag];
	RecImage		*img1, *img2;
    KOImageView     *view1, *view2;
	float			*p1, *p2;
	float			mx;
	int				hx, hy;
	BOOL			on1, on2;
	NSPoint			histPos;
	unsigned char	*ovr1;
	unsigned char	*ovr2;
	int				i, j, d = 5;

	img1 = [control1 selectedImage];
	img2 = [control2 selectedImage];
    view1 = [control1 view];
    view2 = [control2 view];

    // img1 & img2
	if (tag == 1 || tag == 2) {
		[view1 enableOver:NO];
		[view2 enableOver:NO];
		// cross-hair cursor
//		[controlSct clearCursor];
		[control1 reportCursorAt:pos from:self];
		[control2 reportCursorAt:pos from:self];

		// calc position in sctView
		p1 = [img1 data];
		p2 = [img2 data];
		mx = [img1 maxVal];
		
		// set cursor
		hx = p1[(int)pos.y * [img1 xDim] + (int)pos.x];
		hy = p2[(int)pos.y * [img1 xDim] + (int)pos.x];
		hx = hx * 256.0 / mx;
		hy = 255.0 - hy * 256.0 / mx * vGain;
		if (hx < 0) hx = 0;
		if (hx > 255) hx = 255;
		if (hy < 0) hy = 0;
		if (hy > 255) hy = 255;
		histPos.x = hx;
		histPos.y = hy;
		[controlSct reportCursorAt:histPos from:self];
	}
    // sct
	if (tag == 3) {
		[control1 clearCursor];
		[control2 clearCursor];
		// cross-hair cursor
		[controlSct reportCursorAt:pos from:self];
		// proc sct view
		[view1 enableOver:YES];
		[view2 enableOver:YES];
		ovr1 = [[view1 overlay] bitmapData];
		ovr2 = [[view2 overlay] bitmapData];

		p1 = [img1 data];
		p2 = [img2 data];
		mx = [img1 maxVal];
		for (i = j = 0; i < [img1 xDim] * [img1 yDim]; i++, j+=3) {
			hx = p1[i] * 256 / mx;
			hy = 255 - p2[i] * 256 / mx;
			on1 =  ((pos.x > (hx - d)) && (pos.x < (hx + d)));
			on2 =  ((pos.y > (hy - d)) && (pos.y < (hy + d)));
			if (on1 && on2) {
				ovr1[j]		= 255; //255;
				ovr1[j+1]	= 100; //100;
				ovr1[j+2]	= 0;
				ovr2[j]		= 255; //255;
				ovr2[j+1]	= 100; //100;
				ovr2[j+2]	= 0;
			} else {
				ovr1[j]		= 0;
				ovr1[j+1]	= 0;
				ovr1[j+2]	= 0;
				ovr2[j]		= 0;
				ovr2[j+1]	= 0;
				ovr2[j+2]	= 0;
			}
		}
		[control1 displayImage];
		[control2 displayImage];
	}
}

- (void)moveByX:(int)x andY:(int)y from:(id)sender
{
	int			tag = (int)[(KOImageView *)sender tag];
	if (tag == 1 || tag == 2) {
		[control1 moveByX:x andY:y from:self];
		[control2 moveByX:x andY:y from:self];
	} else {
	//	[sender moveByX:x andY:y from:self];
	}
}

- (void)imageChanged:(id)sender
{
	[self updateSct:self];
}

- (id)profile
{
	return nil;
}

@end
