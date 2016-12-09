//
//  GenericUserView.m
//  maxoucard_app
//
//  Created by Olivier on 09/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "GenericUserView.h"

@implementation GenericUserView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setUser:(GenericUser *)aUser welcome:(NSString *)aWelcome {
    [[self ivProfile] sd_setImageWithURL:[NSURL URLWithString:[aUser bigpicURL]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        ;
    }];
    
    [[self lbName] setText:[NSString stringWithFormat:@"%@ %@ %@", [aUser title], [aUser fname], [aUser lname]]];
    [[self lbWelcome] setText:aWelcome];

    _user = aUser;
    
    [self setHidden:NO];
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // 1. load the interface
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        // 2. add as subview
        [self addSubview:self.view];
        // 3. allow for autolayout
        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        // 4. add constraints to span entire view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.view}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.view}]];
        
        
        [[[self ivProfile] layer] setCornerRadius:CGRectGetWidth([[self ivProfile] frame]) / 2];
        
        // hide until we put some data
        [self setHidden:YES];
     
    }

    return self;
}
@end
