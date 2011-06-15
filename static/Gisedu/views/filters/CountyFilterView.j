@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"

@implementation CountyFilterView : CPView
{
    OverlayManager m_OverlayManager;
    
    CPPopUpButton m_CountyType;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];

        m_CountyType = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_CountyType addItemWithTitle:"All"];

        counties = [[m_OverlayManager counties] allKeys];

        for(var i=0; i < [counties count]; i++)
        {
            [m_CountyType addItemWithTitle:[counties objectAtIndex:i]];
        }

        countyTypeLabel = [CPTextField labelWithTitle:"County Selection"];
        [countyTypeLabel sizeToFit];
        [countyTypeLabel setFrameOrigin:CGPointMake(20, 20)];

        [m_CountyType sizeToFit];
        [m_CountyType setFrameOrigin:CGPointMake(20, 45)];
        [m_CountyType setFrameSize:CGSizeMake(260, CGRectGetHeight([m_CountyType bounds]))];

        [self addSubview:countyTypeLabel];
        [self addSubview:m_CountyType];
    }

    return self;
}

@end