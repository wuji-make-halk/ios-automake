//
//  DCRoundSwitch.h
//
//  Created by Patrick Richards on 28/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DCRoundSwitchToggleLayer;
@class DCRoundSwitchOutlineLayer;
@class DCRoundSwitchKnobLayer;

@protocol DCRoundSwitchDelegate <NSObject>

@optional
- (void)didSwitchTouchUp:(BOOL)status tagIndex:(NSInteger)tag;

@end

@interface DCRoundSwitch : UIControl
{
	@private
		DCRoundSwitchOutlineLayer *outlineLayer;
		DCRoundSwitchToggleLayer *toggleLayer;
		DCRoundSwitchKnobLayer *knobLayer;
		CAShapeLayer *clipLayer;
		BOOL ignoreTap;
}

@property (nonatomic, retain) UIColor *onTintColor;		// default: blue (matches normal UISwitch)
@property (nonatomic, retain) UIColor *offTintColor;    //default: white
@property (nonatomic, strong) UIColor *knobColor;
@property (nonatomic, strong) UIColor *onKnobColor;
@property (nonatomic, strong) UIColor *offKnobColor;
@property (nonatomic, getter=isOn) BOOL on;				// default: NO
@property (nonatomic, copy) NSString *onText;			// default: 'ON' - automatically localized
@property (nonatomic, copy) NSString *offText;			// default: 'OFF' - automatically localized

@property (nonatomic,weak) id<DCRoundSwitchDelegate>delegate;

- (void)setOn:(BOOL)newOn animated:(BOOL)animated;
- (void)setOn:(BOOL)newOn animated:(BOOL)animated ignoreControlEvents:(BOOL)ignoreControlEvents;

@end
