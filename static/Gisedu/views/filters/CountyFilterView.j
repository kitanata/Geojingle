@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"

@implementation CountyFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPTextField m_FilterName;
    CPPopUpButton m_CountyType;

    CPButton m_UpdateButton;

    CountyFilter m_Filter @accessors(property=filter);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(CountyFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        
        m_OverlayManager = [OverlayManager getInstance];

        m_CountyType = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_CountyType addItemWithTitle:"All"];

        counties = [[m_OverlayManager counties] allKeys];

        for(var i=0; i < [counties count]; i++)
        {
            [m_CountyType addItemWithTitle:[counties objectAtIndex:i]];
        }

        filterNameLabel = [CPTextField labelWithTitle:"Filter Name"];
        [filterNameLabel sizeToFit];
        [filterNameLabel setFrameOrigin:CGPointMake(20, 0)];

        m_FilterName = [CPTextField roundedTextFieldWithStringValue:[m_Filter name] placeholder:"Filter Name" width:260];
        [m_FilterName setFrameOrigin:CGPointMake(20, 20)];

        countyTypeLabel = [CPTextField labelWithTitle:"County Selection"];
        [countyTypeLabel sizeToFit];
        [countyTypeLabel setFrameOrigin:CGPointMake(20, 60)];

        [m_CountyType sizeToFit];
        [m_CountyType setFrameOrigin:CGPointMake(20, 85)];
        [m_CountyType setFrameSize:CGSizeMake(260, CGRectGetHeight([m_CountyType bounds]))];
        [m_CountyType selectItemWithTitle:[m_Filter county]];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 125)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:filterNameLabel];
        [self addSubview:m_FilterName];

        [self addSubview:countyTypeLabel];
        [self addSubview:m_CountyType];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setName:[m_FilterName stringValue]];

    [m_Filter setCounty:[m_CountyType titleOfSelectedItem]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end