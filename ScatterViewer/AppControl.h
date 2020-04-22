//
//  AppControl.h
//  ScatterViewer
//
//  Created by Koichi Oshio on 3/24/20.
//  Copyright © 2020 Koichi Oshio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RecKit/RecKit.h>
#import "KOImageControl.h"
#import "KOWindowControl.h"

@interface AppControl : KOWindowControl
{
	IBOutlet	KOImageControl		*control1;
	IBOutlet	KOImageControl		*control2;
	IBOutlet	KOImageControl		*controlSct;
	IBOutlet	NSPopUpButton		*vGainButton;
	float		vGain;
	
}

- (IBAction)open:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)updateSct:(id)sender;
- (IBAction)vGainChanged:(id)sender;
- (float)vGain;
- (void)reportCursorAt:(NSPoint)whereInImage from:(id)sender;
- (void)moveByX:(int)x andY:(int)y from:(id)sender;
- (void)imageChanged:(id)sender;
- (id)profile;

@end

