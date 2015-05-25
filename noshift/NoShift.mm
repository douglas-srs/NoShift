#import <Preferences/Preferences.h>

@interface NoShiftListController: PSListController {
}
@end

@implementation NoShiftListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"NoShift" target:self] retain];
	}
	return _specifiers;
}
@end

@interface NoShiftCreditsListController: PSListController {
}
@end

@implementation NoShiftCreditsListController

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"NoShiftCredits" target:self] retain];
    }

    return _specifiers;
}

-(void)joshGibsonTwitter:(PSSpecifier *)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/joshlgibson"]];
}

@end

// vim:ft=objc
