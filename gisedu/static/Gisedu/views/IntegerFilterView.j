@import <Foundation/CPObject.j>

@import "ArrayFilterView.j"
@import "CPDynamicSearch.j"

@implementation IntegerFilterView : ArrayFilterView
{
    CPPopUpButton   m_IntegerFilterOption;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    [acceptedValues addObject:"All"];
    self = [super initWithFrame:aFrame andFilter:filter andAcceptedValues:acceptedValues];
    
    if(self)
    {
        if(m_bPopUp)
        {
            [m_SelectionControl selectItemWithTitle:[m_Filter value]];
        }
        else
        {
            [m_SelectionControl setStringValue:[m_Filter value]];
        }

        m_IntegerFilterOption = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_IntegerFilterOption addItemsWithTitles:["Equal", "Greater Than", "Less Than"]];

        [m_IntegerFilterOption sizeToFit];
        [m_IntegerFilterOption setFrameOrigin:CGPointMake(20, 95)];
        [m_IntegerFilterOption setFrameSize:CGSizeMake(260, CGRectGetHeight([m_IntegerFilterOption bounds]))];
        [m_IntegerFilterOption setTarget:self];
        [m_IntegerFilterOption setAction:@selector(onUpdate:)];

        var intFilterOpt = [m_Filter requestOption];
        if(intFilterOpt == "eq" || intFilterOpt == "")
            [m_IntegerFilterOption selectItemWithTitle:"Equal"];
        else if(intFilterOpt == "gt")
            [m_IntegerFilterOption selectItemWithTitle:"Greater Than"];
        else if(intFilterOpt == "lt")
            [m_IntegerFilterOption selectItemWithTitle:"Less Than"];

        [self addSubview:m_IntegerFilterOption];
    }

    return self;
}

- (void)onUpdate:(id)sender
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