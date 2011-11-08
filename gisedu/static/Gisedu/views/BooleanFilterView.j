@import <Foundation/CPObject.j>

@import "ArrayFilterView.j"

@implementation BooleanFilterView : ArrayFilterView

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter
{
    self = [super initWithFrame:aFrame andFilter:filter andAcceptedValues:['Yes', 'No']];

    if(self)
    {
        if([m_Filter value])
            [m_SelectionControl selectItemWithTitle:"Yes"];
        else
            [m_SelectionControl selectItemWithTitle:"No"];
    }

    return self;
}

- (void)onUpdate:(id)sender
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