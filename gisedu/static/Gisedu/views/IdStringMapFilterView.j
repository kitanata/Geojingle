@import <Foundation/CPObject.j>

@import "DictFilterView.j"
@import "CPDynamicSearch.j"

@implementation IdStringMapFilterView : DictFilterView
{
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPDictionary)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter andAcceptedValues:acceptedValues];

    if(self)
    {
        if(m_bPopUp)
        {
            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl selectItemWithTitle:curKeysForFilterValue];
        }
        else
        {
            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl setStringValue:curKeysForFilterValue];
        }

    }

    return self;
}

- (void)onUpdate:(id)sender
{
    var curSelItem = nil;

    if(m_bPopUp)
        curSelItem = [m_SelectionControl titleOfSelectedItem];
    else
        curSelItem = [m_SelectionControl stringValue];

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

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end
