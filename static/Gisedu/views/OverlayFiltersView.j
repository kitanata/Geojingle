@import <Foundation/CPObject.j>

@implementation OverlayFiltersView : CPSplitView
{
    CPScrollView m_ScrollView;
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        height = CGRectGetHeight([self bounds]) / 3;
        propertiesView = [[CPView alloc] initWithFrame:CGRectMake(10, height, 280, height)];
        m_ScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(10, height * 2, 280, height * 2)];
        
        [self setVertical:NO];
        [self addSubview:propertiesView];
        [self addSubview:m_ScrollView];
    }

    return self;
}

@end