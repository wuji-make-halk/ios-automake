//
//  DCRoundSwitch.m
//
//  Created by Patrick Richards on 28/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitch.h"
#import "DCRoundSwitchToggleLayer.h"
#import "DCRoundSwitchOutlineLayer.h"
#import "DCRoundSwitchKnobLayer.h"

@interface DCRoundSwitch ()

- (void)setup;
- (void)useLayerMasking;
- (void)removeLayerMask;
- (void)positionLayersAndMask;

@end

@implementation DCRoundSwitch
@synthesize on, onText, offText;
@synthesize onTintColor;
@synthesize offTintColor;
@synthesize knobColor;
@synthesize onKnobColor;
@synthesize offKnobColor;

#pragma mark -
#pragma mark Init & Memory Managment

- (void)dealloc
{
//	[onTintColor release];
//	[onText release];
//	[offText release];
//
//	[super dealloc];
}

- (id)init
{
	if ((self = [super init]))
	{
		self.frame = CGRectMake(0, 0, 77, 27);
		[self setup];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setup];
	}

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setup];
	}
    

	return self;
}

- (void)setup
{
	// this way you can set the background color to black or something similar so it can be seen in IB
	self.backgroundColor = [UIColor clearColor];

	// remove the flexible width/height autoresizing masks if they have been set
	UIViewAutoresizing mask = (int)self.autoresizingMask;
	if (mask & UIViewAutoresizingFlexibleHeight)
		self.autoresizingMask ^= UIViewAutoresizingFlexibleHeight;

	if (mask & UIViewAutoresizingFlexibleWidth)
		self.autoresizingMask ^= UIViewAutoresizingFlexibleWidth;

	// setup default texts
    //默认隐藏
    /*
	NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
	self.onText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"ON" value:nil table:nil] : @"ON";
	self.offText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"OFF" value:nil table:nil] : @"OFF";
*/
	// the switch has three layers, (ordered from bottom to top):
	//
	// * toggleLayer * (bottom of the layer stack)
	// this layer contains the onTintColor (blue by default), the text, and the shadown for the knob.  the knob shadow is
	// on this layer because it needs to go under the outlineLayer so it doesn't bleed out over the edge of the control.
	// this layer moves when the switch moves

	// * outlineLayer * (middle of the layer stack)
	// this is the outline of the control, it's inner shadow, and the inner gloss.  the inner shadow is on this layer
	// because it must stay still while the switch animates.  the inner gloss is also here because it doesn't move, and also
	// because it needs to go uner the knobLayer.
	// this layer appears to always stay in the same spot.

	// * knobLayer * (top of the layer stack)
	// this is the knob, and sits on top of the layer stack. note that the knob shadow is NOT drawn here, it is drawn on the
	// toggleLayer so it doesn't bleed out over the outlineLayer.

    //修改on状态的背景颜色
	//toggleLayer = [[DCRoundSwitchToggleLayer alloc] initWithOnString:self.onText offString:self.offText onTintColor:[UIColor colorWithRed:0.000 green:0.478 blue:0.882 alpha:1.0]];
    
    //默认on状态和off状态背景颜色：白色
    toggleLayer = [[DCRoundSwitchToggleLayer alloc] initWithOnString:nil offString:nil onTintColor:[UIColor whiteColor] offTintColor:[UIColor whiteColor]];
    
    
	toggleLayer.drawOnTint = NO;
	toggleLayer.clip = YES;
	[self.layer addSublayer:toggleLayer];
	[toggleLayer setNeedsDisplay];

	outlineLayer = [DCRoundSwitchOutlineLayer layer];
	[toggleLayer addSublayer:outlineLayer];
	[outlineLayer setNeedsDisplay];

	knobLayer = [DCRoundSwitchKnobLayer layer];

	[self.layer addSublayer:knobLayer];
	[knobLayer setNeedsDisplay];

	toggleLayer.contentsScale = outlineLayer.contentsScale = knobLayer.contentsScale = [[UIScreen mainScreen] scale];

	// tap gesture for toggling the switch
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						   action:@selector(tapped:)];
	[self addGestureRecognizer:tapGestureRecognizer];

	// pan gesture for moving the switch knob manually
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
																				 action:@selector(toggleDragged:)];
	[self addGestureRecognizer:panGesture];

	// call setFrame: manually so the initial layout can be done
	[self setFrame:self.frame];

	// setup the layer positions
	[self positionLayersAndMask];
}

#pragma mark -
#pragma mark Setup Frame/Layout
- (void)sizeToFit
{
	[super sizeToFit];
	
	NSString *onString = toggleLayer.onString;
	NSString *offString = toggleLayer.offString;

	CGFloat width = [onString sizeWithFont:toggleLayer.labelFont].width;
	CGFloat offWidth = [offString sizeWithFont:toggleLayer.labelFont].width;
	
	if(offWidth > width)
		width = offWidth;
	
	width += toggleLayer.bounds.size.width * 2.;//add 2x the knob for padding
	
	CGRect newFrame = self.frame;
	CGFloat currentWidth = newFrame.size.width;
	newFrame.size.width = width;
	newFrame.origin.x += currentWidth - width;
	self.frame = newFrame;

	//old values for sizeToFit; keep these around for reference
//	newFrame.size.width = 77.0;
//	newFrame.size.height = 27.0;
}

- (void)useLayerMasking
{
	// turn of the manual clipping (done in toggleLayer's drawInContext:)
	toggleLayer.clip = NO;
	toggleLayer.drawOnTint = YES;
	[toggleLayer setNeedsDisplay];

	// create the layer mask and add that to the toggleLayer
	clipLayer = [CAShapeLayer layer];
	UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														cornerRadius:self.bounds.size.height / 2.0];
	clipLayer.path = clipPath.CGPath;
	toggleLayer.mask = clipLayer;
}

- (void)removeLayerMask
{
	// turn off the animations so the user doesn't see the changing of mask/clipping
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	// remove the layer mask (put on in useLayerMasking)
	toggleLayer.mask = nil;

	// renable manual clipping (done in toggleLayer's drawInContext:)
	toggleLayer.clip = YES;
	toggleLayer.drawOnTint = self.on;
	[toggleLayer setNeedsDisplay];
}

- (void)positionLayersAndMask
{
	// repositions the underlying toggle and the layer mask, plus the knob
	toggleLayer.mask.position = CGPointMake(-toggleLayer.frame.origin.x, 0.0);
	outlineLayer.frame = CGRectMake(-toggleLayer.frame.origin.x, 0, self.bounds.size.width, self.bounds.size.height);
	knobLayer.frame = CGRectMake(toggleLayer.frame.origin.x + toggleLayer.frame.size.width / 2.0 - knobLayer.frame.size.width / 2.0,
								 -1,
								 knobLayer.frame.size.width,
								 knobLayer.frame.size.height);
}

#pragma mark -
#pragma mark Interaction
- (void)tapped:(UITapGestureRecognizer *)gesture
{
	if (ignoreTap) return;
	
    if(_delegate != nil && [self.delegate respondsToSelector:@selector(didSwitchTouchUp:tagIndex:)])
    {
        [self.delegate didSwitchTouchUp:!self.on tagIndex:self.tag];
    }
    
	if (gesture.state == UIGestureRecognizerStateEnded)
		[self setOn:!self.on animated:YES];
}

- (void)toggleDragged:(UIPanGestureRecognizer *)gesture
{
	CGFloat minToggleX = -toggleLayer.frame.size.width / 2.0 + toggleLayer.frame.size.height / 2.0;
	CGFloat maxToggleX = -1;

	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[self useLayerMasking];
		[self positionLayersAndMask];
		knobLayer.gripped = YES;
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];

		// disable the animations before moving the layers
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

		// darken the knob
		if (!knobLayer.gripped)
			knobLayer.gripped = YES;

		// move the toggleLayer using the translation of the gesture, keeping it inside the outline.
		CGFloat newX = toggleLayer.frame.origin.x + translation.x;
		if (newX < minToggleX) newX = minToggleX;
		if (newX > maxToggleX) newX = maxToggleX;
		toggleLayer.frame = CGRectMake(newX,
									   toggleLayer.frame.origin.y,
									   toggleLayer.frame.size.width,
									   toggleLayer.frame.size.height);

		// this will re-position the layer mask and knob
		[self positionLayersAndMask];

		[gesture setTranslation:CGPointZero inView:self];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
        NSLog(@"UIGestureRecognizerStateEnded");

		// flip the switch to on or off depending on which half it ends at
		CGFloat toggleCenter = CGRectGetMidX(toggleLayer.frame);
        [self setOn:!self.on animated:YES];
		//[self setOn:(toggleCenter > CGRectGetMidX(self.bounds)) animated:YES];

        if(_delegate != nil && [self.delegate respondsToSelector:@selector(didSwitchTouchUp:tagIndex:)])
        {
            [self.delegate didSwitchTouchUp:self.on tagIndex:self.tag];
        }
	}

	// send off the appropriate actions (not fully tested yet)
	CGPoint locationOfTouch = [gesture locationInView:self];
	if (CGRectContainsPoint(self.bounds, locationOfTouch))
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	else
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (ignoreTap) return;

	[super touchesBegan:touches withEvent:event];

	knobLayer.gripped = YES;
	[self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];

	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark Setters/Getters

- (void)setOn:(BOOL)newOn
{
	[self setOn:newOn animated:NO];
}

- (void)setOn:(BOOL)newOn animated:(BOOL)animated
{
	[self setOn:newOn animated:animated ignoreControlEvents:NO];
}

- (void)setOn:(BOOL)newOn animated:(BOOL)animated ignoreControlEvents:(BOOL)ignoreControlEvents
{
	BOOL previousOn = self.on;
	on = newOn;
	ignoreTap = YES;

	[CATransaction setAnimationDuration:0.014];
	knobLayer.gripped = YES;

	// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
	[self useLayerMasking];
	[self positionLayersAndMask];

	[CATransaction setCompletionBlock:^{
		[CATransaction begin];
		if (!animated)
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		else
			[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];

		CGFloat minToggleX = -toggleLayer.frame.size.width / 2.0 + toggleLayer.frame.size.height / 2.0;
		CGFloat maxToggleX = -1;


		if (self.on)
		{
			toggleLayer.frame = CGRectMake(maxToggleX,
										   toggleLayer.frame.origin.y,
										   toggleLayer.frame.size.width,
										   toggleLayer.frame.size.height);
            if(onKnobColor)
            {
                [self setKnobColor:onKnobColor];
            }
		}
		else
		{
			toggleLayer.frame = CGRectMake(minToggleX,
										   toggleLayer.frame.origin.y,
										   toggleLayer.frame.size.width,
										   toggleLayer.frame.size.height);
            if(offKnobColor)
            {
                [self setKnobColor:offKnobColor];
            }
		}

		if (!toggleLayer.mask)
		{
			[self useLayerMasking];
			[toggleLayer setNeedsDisplay];
		}

		[self positionLayersAndMask];

		knobLayer.gripped = NO;

		[CATransaction setCompletionBlock:^{
			[self removeLayerMask];
			ignoreTap = NO;

			// send the action here so it get's sent at the end of the animations
			if (previousOn != on && !ignoreControlEvents)
				[self sendActionsForControlEvents:UIControlEventValueChanged];
		}];

		[CATransaction commit];
	}];
}

- (void)setOnTintColor:(UIColor *)anOnTintColor
{
	if (anOnTintColor != onTintColor)
	{
		//[onTintColor release];
		//onTintColor = [anOnTintColor retain];
		toggleLayer.onTintColor = anOnTintColor;
		[toggleLayer setNeedsDisplay];
	}
}

- (void)setOffTintColor:(UIColor *)anOffTintColor
{
    if (anOffTintColor != offTintColor)
    {
        toggleLayer.offTintColor = anOffTintColor;
        [toggleLayer setNeedsDisplay];
    }
}

- (void)setKnobColor:(UIColor *)color
{
    if(knobColor != color)
    {
        knobLayer.knobColor = color;
        [knobLayer setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)aFrame
{
	[super setFrame:aFrame];

	CGFloat knobRadius = self.bounds.size.height + 2.0;
	knobLayer.frame = CGRectMake(0, 0, knobRadius, knobRadius);
	CGSize toggleSize = CGSizeMake(self.bounds.size.width * 2 - (knobRadius - 4), self.bounds.size.height);
	CGFloat minToggleX = -toggleSize.width / 2.0 + knobRadius / 2.0 - 1;
	CGFloat maxToggleX = -1;

	if (self.on)
	{
		toggleLayer.frame = CGRectMake(maxToggleX,
									   toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
        
        if(onKnobColor)
        {
            [self setKnobColor:onKnobColor];
        }
	}
	else
	{
		toggleLayer.frame = CGRectMake(minToggleX,
									   toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
        
        if(offKnobColor)
        {
            [self setKnobColor:offKnobColor];
        }
	}

	[self positionLayersAndMask];
}

- (void)setOnText:(NSString *)newOnText
{
	if (newOnText != onText)
	{
		//[onText release];
		onText = [newOnText copy];
		toggleLayer.onString = onText;
		[toggleLayer setNeedsDisplay];
	}
}

- (void)setOffText:(NSString *)newOffText
{
	if (newOffText != offText)
	{
		//[offText release];
		offText = [newOffText copy];
		toggleLayer.offString = offText;
		[toggleLayer setNeedsDisplay];
	}
}

/*
    参考：http://my.oschina.net/quntion/blog/614244
    参考：http://blog.csdn.net/showhilllee/article/details/24253397
 */

/**
 * 功能：跟踪用户的操作（使addTarget方法生效）
 *  
 * 说明：在UIControl的子类中，我们可以override3个特殊的方法
 *      来提供一个自定义的跟踪行为
 *
 * 当在控件的bound内发生一个触摸事件，首先会调用控件的beginTarckingWithTouch方法
 *
 * 返回值：该函数返回BOOL值决定着：当触摸事件是dragged时，是否需要响应，在我们这里的自定义控件中，是需要跟踪用户的dragging，所以返回YES
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];

    return YES;
}

/**
    持续跟踪
 
    当用户drag时，会调用该函数
 
    该方法返回的BOOL值标示是否继续跟踪touch事件
 */
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    //[self movehandle:lastPoint];
    
    //We'll see this function in the next section:
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}

@end




