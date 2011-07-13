@import <Foundation/CPObject.j>

@import "../../filters/IntegerFilter.j"

@import "../../OverlayManager.j"
@import "../CPDynamicSearch.j"

@implementation IntegerFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;

    CPButton m_UpdateButton;

    IntegerFilter m_Filter       @accessors(property=filter);
    CPArray m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:filter andAcceptedValues:acceptedValues
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        m_AcceptedValues = acceptedValues;
        m_OverlayManager = [OverlayManager getInstance];

        m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_SelectionControl addItemsWithTitles:m_AcceptedValues];

        [m_SelectionControl sizeToFit];
        [m_SelectionControl setFrameOrigin:CGPointMake(20, 20)];
        [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];
        [m_SelectionControl selectItemWithTitle:[m_Filter value].toString()];

        selectionLabel = [CPTextField labelWithTitle:"TODO Selection"];
        [selectionLabel sizeToFit];
        [selectionLabel setFrameOrigin:CGPointMake(20, 20)];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 85)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:selectionLabel];
        [self addSubview:m_SelectionControl];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setValue:[m_SelectionControl titleOfSelectedItem]];


    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end