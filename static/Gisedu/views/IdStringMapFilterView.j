@import <Foundation/CPObject.j>

@import "../OverlayManager.j"
@import "CPDynamicSearch.j"

//A Little Note: This filter view uses a dictionary of accepted key value pairs of type <String:Integer>
//This allows us to provide a nice view to the user(the strings) and a nice view to the server(the Integer)
//during future filter requests
@implementation IdStringMapFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)

    CPButton m_UpdateButton;

    GiseduFilter m_Filter            @accessors(property=filter);
    CPDictionary m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPDictionary)acceptedValues
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
            
            acceptedValuesSorted = [[m_AcceptedValues allValues] sortedArrayUsingSelector:@selector(compare:)];
            [m_SelectionControl addItemsWithTitles:acceptedValuesSorted];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setFrameOrigin:CGPointMake(20, 20)];
            [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];

            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl selectItemWithTitle:curKeysForFilterValue];
        }
        else
        {
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 20, 260, 30)];
            [m_SelectionControl setSearchStrings:[[m_AcceptedValues allValues] sortedArrayUsingSelector:@selector(compare:)]];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];
            
            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl setStringValue:curKeysForFilterValue];
                
            [m_SelectionControl sizeToFit];
        }

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
    console.log("onFilterUpdateButton called");

    var curSelItem = nil;

    if(m_bPopUp)
        curSelItem = [m_SelectionControl titleOfSelectedItem];
    else
        curSelItem = [m_SelectionControl stringValue];

    //console.log("AcceptedValues is " + m_AcceptedValues);

    if(curSelItem == "All")
    {
        [m_Filter setValue:"All"];
    }
    else
    {
        var keyList = [m_AcceptedValues allKeysForObject:curSelItem];
        if([keyList count] > 0)
            [m_Filter setValue:[keyList objectAtIndex:0]];
    }

    console.log("Filter Values is " + [m_Filter value]);

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end