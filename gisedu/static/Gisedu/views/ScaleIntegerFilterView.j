@import "FilterView.j"
@import "../FilterManager.j"

@implementation ScaleIntegerFilterView : FilterView
{
    FilterManager m_FilterManager;

    CPTextField m_ScaleByLabel;
    CPPopUpButton m_ScaleByPopUp;

    CPTextField m_MinimumValueLabel;
    CPSlider m_MinimumValueSlider;
    CPTextField m_MinimumValueText;

    CPTextField m_MaximumValueLabel;
    CPSlider m_MaximumValueSlider;
    CPTextField m_MaximumValueText;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter];
    
    if(self)
    {
        m_FilterManager = [FilterManager getInstance];

        var acceptedFilterNames = [CPArray array];

        for(var i=0; i < [acceptedValues count]; i++)
        {
            var curFilterId = [acceptedValues objectAtIndex:i];

            [acceptedFilterNames addObject:[m_FilterManager filterNameFromId:curFilterId]];
        }

        [m_FilterType setHidden:YES]; //not needed for this view

        //SCALE BY POPUP
        m_ScaleByLabel = [CPTextField labelWithTitle:"Scale By Integer Filter"];
        [m_ScaleByLabel sizeToFit];
        [m_ScaleByLabel setFrameOrigin:CGPointMake(20, 10)];

        m_ScaleByPopUp = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 35, 240, 24)];
        [m_ScaleByPopUp addItemsWithTitles:acceptedFilterNames];
        [m_ScaleByPopUp setAction:@selector(onScaleByPopUp:)];
        [m_ScaleByPopUp setTarget:self];

        //MINIMUM VALUE SLIDER AND TEXTBOX
        m_MinimumValueLabel = [CPTextField labelWithTitle:"Minimum Shape Size"];
        [m_MinimumValueLabel sizeToFit];
        [m_MinimumValueLabel setFrameOrigin:CGPointMake(20, 80)];

        m_MinimumValueSlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, 100, 160, 20)];
        [m_MinimumValueSlider setMinValue:100];
        [m_MinimumValueSlider setMaxValue:10000];
        [m_MinimumValueSlider setValue:1000];
        [m_MinimumValueSlider setTarget:self];
        [m_MinimumValueSlider setAction:@selector(onMinimumValueSlider:)];

        m_MinimumValueText = [CPTextField roundedTextFieldWithStringValue:"100" placeholder:"100" width:80];
        [m_MinimumValueText sizeToFit];
        [m_MinimumValueText setFrameOrigin:CGPointMake(190, 94)];
        [m_MinimumValueText setTarget:self];
        [m_MinimumValueText setAction:@selector(onMinimumValueText:)];
        [m_MinimumValueText setObjectValue:1000];

        //MAXIMUM VALUE SLIDER AND TEXTBOX
        m_MaximumValueLabel = [CPTextField labelWithTitle:"Maximum Shape Size"];
        [m_MaximumValueLabel sizeToFit];
        [m_MaximumValueLabel setFrameOrigin:CGPointMake(20, 140)];

        m_MaximumValueSlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, 160, 160, 20)];
        [m_MaximumValueSlider setMinValue:100];
        [m_MaximumValueSlider setMaxValue:10000];
        [m_MaximumValueSlider setValue:1000];
        [m_MaximumValueSlider setTarget:self];
        [m_MaximumValueSlider setAction:@selector(onMaximumValueSlider:)];

        m_MaximumValueText = [CPTextField roundedTextFieldWithStringValue:"100" placeholder:"100" width:80];
        [m_MaximumValueText sizeToFit];
        [m_MaximumValueText setFrameOrigin:CGPointMake(190, 154)];
        [m_MaximumValueText setTarget:self];
        [m_MaximumValueText setAction:@selector(onMaximumValueText:)];
        [m_MaximumValueText setObjectValue:1000];

        [self addSubview:m_ScaleByLabel];
        [self addSubview:m_ScaleByPopUp];

        [self addSubview:m_MinimumValueLabel];
        [self addSubview:m_MinimumValueSlider];
        [self addSubview:m_MinimumValueText];

        [self addSubview:m_MaximumValueLabel];
        [self addSubview:m_MaximumValueSlider];
        [self addSubview:m_MaximumValueText];

        if(filter)
        {
            if([filter reduceFilterId] != -1)
                [m_ScaleByPopUp selectItemWithTitle:[m_FilterManager filterNameFromId:[filter reduceFilterId]]];

            [m_MinimumValueSlider setValue:[filter minimumScale]];
            [m_MinimumValueText setObjectValue:[filter minimumScale]];

            [m_MaximumValueSlider setValue:[filter maximumScale]];
            [m_MaximumValueText setObjectValue:[filter maximumScale]];
        }
    }

    return self;
}

- (void)onScaleByPopUp:(id)sender
{
    [self onUpdate:self];
}

- (void)onMinimumValueSlider:(id)sender
{
    [m_MinimumValueText setObjectValue:[sender value]];
    [self onUpdate:self];
}

- (void)onMinimumValueText:(id)sender
{
    var newValue = [sender objectValue];

    if(newValue < 100)
        newValue = 100;
    else if(newValue > 10000)
        newValue = 10000;

    [m_MinimumValueSlider setValue:newValue];
    [m_MinimumValueText setObjectValue:newValue];
    [self onUpdate:self];
}

- (void)onMaximumValueSlider:(id)sender
{
    [m_MaximumValueText setObjectValue:[sender value]];
    [self onUpdate:self];
}

- (void)onMaximumValueText:(id)sender
{
    var newValue = [sender objectValue];

    if(newValue < 100)
        newValue = 100;
    else if(newValue > 10000)
        newValue = 10000;

    [m_MaximumValueSlider setValue:newValue];
    [m_MaximumValueText setObjectValue:newValue];
    [self onUpdate:self];
}

- (void)onUpdate:(id)sender
{
    [m_Filter setReduceFilterId:[m_FilterManager filterIdFromName:[m_ScaleByPopUp titleOfSelectedItem]]];
    [m_Filter setMinimumScale:[m_MinimumValueSlider value]];
    [m_Filter setMaximumScale:[m_MaximumValueSlider value]];
    
    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end
