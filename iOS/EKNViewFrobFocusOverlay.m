//
//  EKNViewFrobFocusOverlay.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 8/6/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobFocusOverlay.h"

#import <QuartzCore/QuartzCore.h>

@interface EKNViewFrobFocusOverlay ()

@property (strong, nonatomic) CAShapeLayer* topMargin;
@property (strong, nonatomic) CAShapeLayer* leftMargin;
@property (strong, nonatomic) CAShapeLayer* bottomMargin;
@property (strong, nonatomic) CAShapeLayer* rightMargin;

@property (strong, nonatomic) UILabel* topMarginLabel;
@property (strong, nonatomic) UILabel* leftMarginLabel;
@property (strong, nonatomic) UILabel* bottomMarginLabel;
@property (strong, nonatomic) UILabel* rightMarginLabel;

@end

@implementation EKNViewFrobFocusOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [self lineColor].CGColor;
        self.layer.borderWidth = 2;
        
        self.topMargin = [CAShapeLayer layer];
        self.leftMargin = [CAShapeLayer layer];
        self.bottomMargin = [CAShapeLayer layer];
        self.rightMargin = [CAShapeLayer layer];
        
        self.topMarginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.leftMarginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bottomMarginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.rightMarginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        for(CAShapeLayer* layer in self.marginLayers) {
            layer.lineWidth = 2;
            layer.lineDashPattern = @[@3, @3];
            layer.strokeColor = [self lineColor].CGColor;
            [self.layer addSublayer:layer];
        }
        
        for(UILabel* label in self.marginLabels) {
            label.textColor = [self lineColor];
            label.font = [UIFont systemFontOfSize:12.];
            [self addSubview:label];
        }
    }
    return self;
}

- (NSArray*)marginLayers {
    return @[self.topMargin, self.leftMargin, self.bottomMargin, self.rightMargin];
}

- (NSArray*)marginLabels {
    return @[self.topMarginLabel, self.leftMarginLabel, self.bottomMarginLabel, self.rightMarginLabel];
}

- (UIColor*)lineColor {
    return [UIColor colorWithRed:0 green:.5 blue:1. alpha:1.];
}

- (void)setShowsMargins:(BOOL)showsMargins {
    _showsMargins = showsMargins;
    [self setNeedsLayout];
}

- (void)setMargins:(UIEdgeInsets)margins {
    _margins = margins;
    [self setNeedsLayout];
}

- (UIBezierPath*)bezierPathFrom:(CGPoint)a to:(CGPoint)b {
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path moveToPoint:a];
    [path addLineToPoint:b];
    return path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cx = self.bounds.size.width / 2;
    CGFloat cy = self.bounds.size.height / 2;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    self.topMargin.path = [self bezierPathFrom:CGPointMake(cx, self.margins.top) to:CGPointMake(cx, 0)].CGPath;
    self.leftMargin.path = [self bezierPathFrom:CGPointMake(0, cy) to:CGPointMake(self.margins.left, cy)].CGPath;
    self.bottomMargin.path = [self bezierPathFrom:CGPointMake(cx, h) to:CGPointMake(cx, h - self.margins.bottom)].CGPath;
    self.rightMargin.path = [self bezierPathFrom:CGPointMake(w, cy) to:CGPointMake(w - self.margins.right, cy)].CGPath;
    
    self.topMarginLabel.text = [NSString stringWithFormat:@"%g", -self.margins.top];
    self.leftMarginLabel.text = [NSString stringWithFormat:@"%g", -self.margins.left];
    self.bottomMarginLabel.text = [NSString stringWithFormat:@"%g", -self.margins.bottom];
    self.rightMarginLabel.text = [NSString stringWithFormat:@"%g", -self.margins.right];
    
    for(UIView* label in self.marginLabels) {
        label.hidden = !self.showsMargins;
        [label sizeToFit];
    }
    
    self.topMarginLabel.frame = CGRectMake(cx + 2, self.margins.top, self.topMarginLabel.frame.size.width, self.topMarginLabel.frame.size.height);
    self.leftMarginLabel.frame = CGRectMake(self.margins.left, cy - self.leftMarginLabel.frame.size.height - 2, self.leftMarginLabel.frame.size.width, self.topMarginLabel.frame.size.height);
    self.bottomMarginLabel.frame = CGRectMake(cx + 2, h - self.margins.bottom - self.bottomMarginLabel.frame.size.height, self.bottomMarginLabel.frame.size.width, self.bottomMarginLabel.frame.size.height);
    self.rightMarginLabel.frame = CGRectMake(w - self.margins.right - self.rightMarginLabel.frame.size.width, cy - self.rightMarginLabel.frame.size.height - 2, self.rightMarginLabel.frame.size.width, self.rightMarginLabel.frame.size.height);
    

    for(CALayer* layer in self.marginLayers) {
        layer.hidden = !self.showsMargins;
    }
}

@end
