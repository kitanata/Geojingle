@import <Foundation/CPObject.j>

@import "../OverlayManager.j"

@implementation FilterView : CPControl
{
    OverlayManager m_OverlayManager;
    GiseduFilter m_Filter       @accessors(property=filter);

    CPTextField m_FilterType;
    CPTextField m_FilterTitle;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        m_OverlayManager = [OverlayManager getInstance];

        var filterDescription = [m_Filter description];

        m_FilterType = [CPTextField labelWithTitle:[filterDescription name]];
        [m_FilterType setFrameOrigin:CGPointMake(20, 10)];
        [m_FilterType sizeToFit];

        [self addSubview:m_FilterType];
    }

    return self;
}

@end