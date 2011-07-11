@import <Foundation/CPObject.j>

@import "../../filters/StringFilter.j"

@import "../../OverlayManager.j"
@import "../CPDynamicSearch.j"

@implementation StringFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)

    CPButton m_UpdateButton;

    StringFilter m_Filter       @accessors(property=filter);
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
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 40, 260, 30)];
            [m_SelectionControl setSearchStrings:m_AcceptedValues];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];
            [m_SelectionControl setStringValue:[m_Filter value]];
            [m_SelectionControl sizeToFit];
        }

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
    if(m_bPopUp)
        [m_Filter setValue:[m_SelectionControl titleOfSelectedItem]];
    else
        [m_Filter setValue:[m_SelectionControl stringValue]];


    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end