@import <Foundation/CPObject.j>

@import "ArrayFilterView.j"
@import "CPDynamicSearch.j"

@implementation StringFilterView : ArrayFilterView

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
    }

    return self;
}

- (void)onUpdate:(id)sender
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