@interface UIKBTree
    -(id)name;
-(BOOL)isLetters;
-(int)displayType;
@end

@interface UIKeyboardLayoutStar
    -(id)keyHitTest:(CGPoint)arg1;
    - (void)touchUp:(UITouch *)touch;
@end

@interface UIKeyboardImpl
    -(id)delegate;
    -(void)deleteBackward;
@end

#define UserDefaultsPlistPath @"/var/mobile/Library/Preferences/net.douglassoares.noshift.plist"

static bool enabled;
static double tapSpeed;
static double pressingTime = 0;
static NSString *keyName;
static bool capitalize = NO;
static NSArray *blacklist = [NSArray arrayWithObjects: @"t", @"o", @"d", @"g", @"p", @"f", @"s", @"r", nil];

static void loadPreferences() {
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:UserDefaultsPlistPath];
    NSNumber *optionKey = tweakSettings[@"enabled"];
    enabled = optionKey ? [optionKey boolValue] : 1;
    optionKey = tweakSettings[@"speed"];
    tapSpeed = optionKey ? [optionKey floatValue] : 0.18;
}

%hook UIKeyboardLayoutStar
    - (void)touchUp:(UITouch *)touch {
        loadPreferences();
        if (enabled){
            CGPoint point = [touch locationInView:touch.view];
            UIKBTree* kbTree = [self keyHitTest:point];
            if (pressingTime == 0){
                pressingTime = [[NSDate new] timeIntervalSince1970];
                keyName = [kbTree name];
            } else {
                NSTimeInterval differ = [[NSDate dateWithTimeIntervalSince1970:[[NSDate new] timeIntervalSince1970]] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:pressingTime]];
                
                //NSLog(@"########################### name1 %@ - name2 %@ differ %f", keyName, [kbTree name], differ);
                if (keyName == [kbTree name] && differ < tapSpeed && [kbTree displayType] == 0)
                    capitalize = YES;

                pressingTime = [[NSDate new] timeIntervalSince1970];
                if ([kbTree displayType] != 0)
                	keyName = @"";
                else
                	keyName = [kbTree name];
            }
        }

        %orig;
    }

%end

%hook UIKeyboardImpl


    -(void)insertText:(NSString*)text {
        loadPreferences();
        if (enabled){
            if (capitalize){
                capitalize = NO;
                NSString *allText = @"";
                if(self.delegate && [self.delegate respondsToSelector:@selector(text)]){
                	allText = [[self delegate] text];
                	//NSLog(@"################ OBTIVE O TEXTO COM SUCESSO!");
                }

                if ([allText length] == 0){
                	//NSLog(@"################ NAO OBTIVE O TEXTO!");
    	            [self deleteBackward];
    	            %orig([text uppercaseString]);
            	} else {
            		//NSArray *words = [allText componentsSeparatedByString:@" "];
            		NSString *lastChar = @".";
            		if ([allText length] > 3){
            		lastChar = [allText substringFromIndex:[allText length] - 2];
            		lastChar = [lastChar substringToIndex:1];
            		}
            		//NSLog(@"################ ULTIMO CARACTERE %@", lastChar);

            		if ([lastChar isEqual:@" "]){
            			//NSLog(@"################ ULTIMO CARACTERE EH ESPACO");
            			[self deleteBackward];
    	            	%orig([text uppercaseString]);
            		} else {
            			//NSLog(@"################ ULTIMO CARACTERE NAO EH ESPACO");
            			if ([blacklist containsObject:text]) {
            				//NSLog(@"################ ENCONTREI A LETRA %@ NA BLACKLIST", text);
            				%orig;
            			} else {
            				//NSLog(@"################ NAO ENCONTREI A LETRA %@ NA BLACKLIST", text);
            				if ([lastChar isEqual:text]){
            					[self deleteBackward];
    	            			%orig([text uppercaseString]);
    	            		} else {
    	            			%orig;
    	            		}
            			}
            		}

            	}
            }
            else
                %orig;
        } else
            %orig;
    }

%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("net.douglassoares.noshift/prefsChanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPreferences();
}