@import <Foundation/CPObject.j>

@import "../OverlayManager.j"
@import "CPDynamicSearch.j"

@implementation BooleanFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;

    CPButton m_UpdateButton;

    GiseduFilter m_Filter       @accessors(property=filter);
    CPArray m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        m_AcceptedValues = ['Yes', 'No'];
        m_OverlayManager = [OverlayManager getInstance];

        m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_SelectionControl addItemsWithTitles:m_AcceptedValues];

        [m_SelectionControl sizeToFit];
        [m_SelectionControl setFrameOrigin:CGPointMake(20, 20)];
        [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];

        if([m_Filter value])
            [m_SelectionControl selectItemWithTitle:"Yes"];
        else
            [m_SelectionControl selectItemWithTitle:"No"];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 65)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:m_SelectionControl];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    if([m_SelectionControl titleOfSelectedItem] == "Yes")
        [m_Filter setValue:YES];
    else
        [m_Filter setValue:NO];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end