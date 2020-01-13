//
//  NSBezierPath_Adding.m
//  cooViewer
//
//  Created by coo on 08/02/11.
//  Copyright 2008 coo. All rights reserved.
//

#import "NSBezierPath_Adding.h"


@implementation NSBezierPath (Adding)
+ (NSBezierPath*)bezierPathWithRectWithDoubleArc:(NSRect)rect
{
	int rad = (rect.size.height/2)+0.5;
	NSBezierPath *bezier = [NSBezierPath bezierPath];
	
	[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rad,rect.origin.y+rad)
									   radius:rad
								   startAngle:90
									 endAngle:270
		];	
	[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rect.size.width-rad,rect.origin.y+rad)
									   radius:rad
								   startAngle:270
									 endAngle:90
		];	
	[bezier setLineWidth:1.5];
	return bezier;
}

+ (NSBezierPath*)bezierPathWithRectWithArc:(NSRect)rect rad:(int)rad open:(int)open
{
	NSBezierPath *bezier = [NSBezierPath bezierPath];	
	
	NSPoint ld,lu,ru,rd;
	ld = rect.origin;
	lu = NSMakePoint(ld.x,ld.y+rect.size.height);
	ru = NSMakePoint(lu.x+rect.size.width,lu.y);
	rd = NSMakePoint(ru.x,ru.y-rect.size.height);
	
	switch (open) {
		case 0:
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ru.x-rad,ru.y-rad)
											   radius:rad
										   startAngle:0
											 endAngle:90
				];	
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(lu.x+rad,lu.y-rad)
											   radius:rad
										   startAngle:90
											 endAngle:180
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ld.x+rad,ld.y+rad)
											   radius:rad
										   startAngle:180
											 endAngle:270
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rd.x-rad,rd.y+rad)
											   radius:rad
										   startAngle:270
											 endAngle:0
				];
		break;
		case 1:
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(lu.x+rad,lu.y-rad)
											   radius:rad
										   startAngle:90
											 endAngle:180
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ld.x+rad,ld.y+rad)
											   radius:rad
										   startAngle:180
											 endAngle:270
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rd.x-rad,rd.y+rad)
											   radius:rad
										   startAngle:270
											 endAngle:0
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ru.x-rad,ru.y-rad)
											   radius:rad
										   startAngle:0
											 endAngle:90
				];	
		break;
		case 2:
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ld.x+rad,ld.y+rad)
											   radius:rad
										   startAngle:180
											 endAngle:270
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rd.x-rad,rd.y+rad)
											   radius:rad
										   startAngle:270
											 endAngle:0
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ru.x-rad,ru.y-rad)
											   radius:rad
										   startAngle:0
											 endAngle:90
				];	
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(lu.x+rad,lu.y-rad)
											   radius:rad
										   startAngle:90
											 endAngle:180
				];
		break;
		case 3:
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rd.x-rad,rd.y+rad)
											   radius:rad
										   startAngle:270
											 endAngle:0
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ru.x-rad,ru.y-rad)
											   radius:rad
										   startAngle:0
											 endAngle:90
				];	
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(lu.x+rad,lu.y-rad)
											   radius:rad
										   startAngle:90
											 endAngle:180
				];
			[bezier appendBezierPathWithArcWithCenter:NSMakePoint(ld.x+rad,ld.y+rad)
											   radius:rad
										   startAngle:180
											 endAngle:270
				];
		break;
	default:
		break;
	}
	[bezier setLineWidth:1.5];
	return bezier;
}

@end
