@import <Foundation/CPObject.j>

@import "FilterView.j"
@import "CPDynamicSearch.j"

//A Little Note: This filter view uses a dictionary of accepted key value pairs of type <String:Integer>
//This allows us to provide a nice view to the user(the strings) and a nice view to the server(the Integer)
//during future filter requests
@implementation DictFilterView : FilterView
{
    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)

    CPDictionary m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPDictionary)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter];

    if(self)
    {
        m_AcceptedValues = acceptedValues;

        m_bPopUp = ([m_AcceptedValues count] <= 100);

        if(m_bPopUp)
        {
            m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
            [m_SelectionControl addItemWithTitle:"All"];

            acceptedValuesSorted = [[m_AcceptedValues allValues] sortedArrayUsingSelector:@selector(compare:)];
            [m_SelectionControl addItemsWithTitles:acceptedValuesSorted];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setFrameOrigin:CGPointMake(20, 50)];
            [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];

            [m_SelectionControl setTarget:self];
            [m_SelectionControl setAction:@selector(onUpdate:)];
        }
        else
        {
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 50, 260, 30)];
            [m_SelectionControl setSearchStrings:[[m_AcceptedValues allValues] sortedArrayUsingSelector:@selector(compare:)]];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];

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