@import "FilterView.j"

@implementation ColorizeIntegerFilterView : FilterView
{
    FilterManager m_FilterManager;

    CPTextField m_ScaleByLabel;
    CPPopUpButton m_ScaleByPopUp;

    CPTextField m_MinimumColorLabel;
    CPColorWell m_MinimumColorWell;

    CPTextField m_MaximumColorLabel;
    CPColorWell m_MaximumColorWell;
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
        m_ScaleByLabel = [CPTextField labelWithTitle:"Colorize By Integer Filter"];
        [m_ScaleByLabel sizeToFit];
        [m_ScaleByLabel setFrameOrigin:CGPointMake(20, 10)];

        m_ScaleByPopUp = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 35, 240, 24)];
        [m_ScaleByPopUp addItemsWithTitles:acceptedFilterNames];
        [m_ScaleByPopUp setAction:@selector(onScaleByPopUp:)];
        [m_ScaleByPopUp setTarget:self];

        //Minimum Color Well
        m_MinimumColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_MinimumColorLabel setStringValue:@"Minimum Value Color"];
        [m_MinimumColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_MinimumColorLabel sizeToFit];
        [m_MinimumColorLabel setFrameOrigin:CGPointMake(20, 80)];

        m_MinimumColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(180, 76, 90, 24)];
        [m_MinimumColorWell setBordered:YES];
        [m_MinimumColorWell setTarget:self];
        [m_MinimumColorWell setAction:@selector(onMinimumColorWell:)];

        //Maximum Color Well
        m_MaximumColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_MaximumColorLabel setStringValue:@"Maximum Value Color"];
        [m_MaximumColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_MaximumColorLabel sizeToFit];
        [m_MaximumColorLabel setFrameOrigin:CGPointMake(20, 120)];

        m_MaximumColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(180, 116, 90, 24)];
        [m_MaximumColorWell setBordered:YES];
        [m_MaximumColorWell setTarget:self];
        [m_MaximumColorWell setAction:@selector(onMaximumColorWell:)];

        [self addSubview:m_ScaleByLabel];
        [self addSubview:m_ScaleByPopUp];

        [self addSubview:m_MinimumColorLabel];
        [self addSubview:m_MinimumColorWell];

        [self addSubview:m_MaximumColorLabel];
        [self addSubview:m_MaximumColorWell];

        if(filter)
        {
            if([filter reduceFilterId] != -1)
                [m_ScaleByPopUp selectItemWithTitle:[m_FilterManager filterNameFromId:[filter reduceFilterId]]];

            [m_MinimumColorWell setColor:[filter minimumColor]];
            [m_MaximumColorWell setColor:[filter maximumColor]];
        }
    }

    return self;
}

- (void)onScaleByPopUp:(id)sender
{
    [self onUpdate:self];
}

- (void)onMinimumColorWell:(id)sender
{
    var lineColor = "#" + [[m_MinimumColorWell color] hexString];

    [self onUpdate:self];
}

- (void)onMaximumColorWell:(id)sender
{
    var lineColor = "#" + [[m_MaximumColorWell color] hexString];

    [self onUpdate:self];
}

- (void)onUpdate:(id)sender
{
    [m_Filter setReduceFilterId:[m_FilterManager filterIdFromName:[m_ScaleByPopUp titleOfSelectedItem]]];
    [m_Filter setMinimumColor:[m_MinimumColorWell color]];
    [m_Filter setMaximumColor:[m_MaximumColorWell color]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end
