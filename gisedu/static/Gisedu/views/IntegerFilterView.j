@import <Foundation/CPObject.j>

@import "../OverlayManager.j"
@import "CPDynamicSearch.j"

@implementation IntegerFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)

    CPPopUpButton   m_IntegerFilterOption;

    CPButton m_UpdateButton;

    GiseduFilter m_Filter       @accessors(property=filter);
    CPArray m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    self = [super initWithFrame:aFrame];
    
    if(self)
    {
        m_Filter = filter;
        m_AcceptedValues = [acceptedValues sortedArrayUsingSelector:@selector(compare:)];
        m_OverlayManager = [OverlayManager getInstance];

        m_bPopUp = ([m_AcceptedValues count] <= 100);

        if(m_bPopUp)
        {
            m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
            [m_SelectionControl addItemWithTitle:"All"];
            [m_SelectionControl addItemsWithTitles:m_AcceptedValues];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setFrameOrigin:CGPointMake(20, 20)];
            [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];
            [m_SelectionControl selectItemWithTitle:[m_Filter value]];
        }
        else
        {
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 20, 260, 30)];
            [m_SelectionControl setSearchStrings:m_AcceptedValues];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];
            [m_SelectionControl setStringValue:[m_Filter value]];
            [m_SelectionControl sizeToFit];
        }

        m_IntegerFilterOption = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_IntegerFilterOption addItemsWithTitles:["Equal", "Greater Than", "Less Than"]];

        [m_IntegerFilterOption sizeToFit];
        [m_IntegerFilterOption setFrameOrigin:CGPointMake(20, 65)];
        [m_IntegerFilterOption setFrameSize:CGSizeMake(260, CGRectGetHeight([m_IntegerFilterOption bounds]))];

        var intFilterOpt = [m_Filter requestOption];
        if(intFilterOpt == "eq" || intFilterOpt == "")
            [m_IntegerFilterOption selectItemWithTitle:"Equal"];
        else if(intFilterOpt == "gt")
            [m_IntegerFilterOption selectItemWithTitle:"Greater Than"];
        else if(intFilterOpt == "lt")
            [m_IntegerFilterOption selectItemWithTitle:"Less Than"];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 105)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:m_SelectionControl];
        [self addSubview:m_IntegerFilterOption];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    if(m_bPopUp)
        [m_Filter setValue:[m_SelectionControl titleOfSelectedItem]];
    else
        [m_Filter setValue:[m_SelectionControl stringValue]];

    var intFilterOptSel = [m_IntegerFilterOption titleOfSelectedItem];
    if(intFilterOptSel == "Equal")
        [m_Filter setRequestOption:"eq"];
    else if(intFilterOptSel == "Greater Than")
        [m_Filter setRequestOption:"gt"];
    else if(intFilterOptSel == "Less Than")
        [m_Filter setRequestOption:"lt"];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end