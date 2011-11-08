@import <Foundation/CPObject.j>

@import "FilterView.j"

@implementation ArrayFilterView : FilterView
{
    CPArray m_AcceptedValues    @accessors(property=acceptedValues);

    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter];

    if(self)
    {
        if([acceptedValues count])
            m_AcceptedValues = [acceptedValues sortedArrayUsingSelector:@selector(compare:)];
        else
            m_AcceptedValues = [CPArray array];

        m_bPopUp = ([m_AcceptedValues count] <= 100);

        if(m_bPopUp)
        {
            m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
            [m_SelectionControl addItemsWithTitles:m_AcceptedValues];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setFrameOrigin:CGPointMake(20, 50)];
            [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];
            [m_SelectionControl setTarget:self];
            [m_SelectionControl setAction:@selector(onUpdate:)];
        }
        else
        {
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 50, 260, 30)];
            [m_SelectionControl setSearchStrings:m_AcceptedValues];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];
            [m_SelectionControl sizeToFit];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setDelegate:self];
        }

        [self addSubview:m_SelectionControl];
    }

    return self;
}

- (void)onSearchMenuItemSelected:(id)sender
{
    [self onUpdate:sender];
}

@end