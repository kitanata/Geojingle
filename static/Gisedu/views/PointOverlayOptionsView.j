@import <Foundation/CPObject.j>
@import "../PointOverlay.j"

@implementation PointOverlayOptionsView : CPView
{
    PointOverlay m_OverlayTarget @accessors(property=overlay);

    CPPopUpButton m_IconTypeButton;

    CPTextField m_IconSubTypeLabel;
    CPPopUpButton m_IconSubTypeButton;

    CPTextField m_IconColorLabel;
    CPPopUpButton m_IconColorButton;

    CPTextField m_LineColorLabel;
    CPColorWell m_LineColorWell;

    CPTextField m_FillColorLabel;
    CPColorWell m_FillColorWell;

    CPTextField m_LineStrokeLabel;
    CPSlider m_LineStrokeSlider;

    CPTextField m_LineOpacityLabel;
    CPSlider m_LineOpacitySlider;

    CPTextField m_FillOpacityLabel;
    CPSlider m_FillOpacitySlider;

    CPTextField m_ShapeRadiusLabel;
    CPSlider m_ShapeRadiusSlider;

    CPCheckBox m_ShowButton;
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        var iconTypeLabel = [CPTextField labelWithTitle:"Icon Type:"];
        [iconTypeLabel sizeToFit];
        [iconTypeLabel setFrameOrigin:CGPointMake(20, 40)];

        m_IconTypeButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 60, 240, 24)];
        [m_IconTypeButton addItemsWithTitles:[[CPDictionary dictionaryWithJSObject:g_IconTypes] allKeys]];
        [m_IconTypeButton setAction:@selector(onIconTypeChanged:)];
        [m_IconTypeButton setTarget:self];
        [m_IconTypeButton setTitle:"Map Marker"];

        m_IconSubTypeLabel = [CPTextField labelWithTitle:"Icon SubType:"];
        [m_IconSubTypeLabel sizeToFit];
        [m_IconSubTypeLabel setFrameOrigin:CGPointMake(20, 100)];
        [m_IconSubTypeLabel setHidden:YES];

        m_IconSubTypeButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 120, 240, 24)];
        [m_IconSubTypeButton setTitle:"Select Icon Subtype"];
        [m_IconSubTypeButton setAction:@selector(onIconSubTypeChanged:)];
        [m_IconSubTypeButton setTarget:self];
        [m_IconSubTypeButton setHidden:YES];

        m_IconColorLabel = [CPTextField labelWithTitle:"Icon Color:"];
        [m_IconColorLabel sizeToFit];
        [m_IconColorLabel setFrameOrigin:CGPointMake(20, 100)];

        m_IconColorButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 120, 240, 24)];
        [m_IconColorButton addItemsWithTitles:[[CPDictionary dictionaryWithJSObject:g_MapIconColors] allKeys]];
        [m_IconColorButton setAction:@selector(onIconColorChanged:)];
        [m_IconColorButton setTarget:self];
        [m_IconColorButton setTitle:"Black"];

        //LINE COLOR WELL
        m_LineColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_LineColorLabel setStringValue:@"Shape Line Color"];
        [m_LineColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_LineColorLabel sizeToFit];
        [m_LineColorLabel setFrameOrigin:CGPointMake(40, 100)];

        m_LineColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(20, 100, 20, 20)];
        [m_LineColorWell setBordered:YES];
        [m_LineColorWell setTarget:self];
        [m_LineColorWell setAction:@selector(onLineColorWell:)];

        //FILL COLOR WELL
        m_FillColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_FillColorLabel setStringValue:@"Shape Fill Color"];
        [m_FillColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_FillColorLabel sizeToFit];
        [m_FillColorLabel setFrameOrigin:CGPointMake(40, 130)];

        m_FillColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(20, 130, 20, 20)];
        [m_FillColorWell setBordered:YES];
        [m_FillColorWell setTarget:self];
        [m_FillColorWell setAction:@selector(onFillColorWell:)];

        //LINE STROKE SLIDER
        m_LineStrokeLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_LineStrokeLabel setStringValue:@"Shape Line Stroke Size"];
        [m_LineStrokeLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_LineStrokeLabel sizeToFit];
        [m_LineStrokeLabel setFrameOrigin:CGPointMake(20, 160)];

        m_LineStrokeSlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, 170, 240, 20)];
        [m_LineStrokeSlider setMinValue:0];
        [m_LineStrokeSlider setMaxValue:25];
        [m_LineStrokeSlider setTarget:self];
        [m_LineStrokeSlider setAction:@selector(onStrokeSlider:)];

        //LINE OPACITY SLIDER
        m_LineOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_LineOpacityLabel setStringValue:@"Shape Line Opactiy"];
        [m_LineOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_LineOpacityLabel sizeToFit];
        [m_LineOpacityLabel setFrameOrigin:CGPointMake(20, 200)];

        m_LineOpacitySlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, 210, 240, 20)];
        [m_LineOpacitySlider setMinValue:0];
        [m_LineOpacitySlider setMaxValue:100];
        [m_LineOpacitySlider setTarget:self];
        [m_LineOpacitySlider setAction:@selector(onLineOpacitySlider:)];

        //FILL OPACITY SLIDER
        m_FillOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_FillOpacityLabel setStringValue:@"Shape Fill Opactiy"];
        [m_FillOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_FillOpacityLabel sizeToFit];
        [m_FillOpacityLabel setFrameOrigin:CGPointMake(20, 240)];

        m_FillOpacitySlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, 250, 240, 20)];
        [m_FillOpacitySlider setMinValue:0];
        [m_FillOpacitySlider setMaxValue:100];
        [m_FillOpacitySlider setTarget:self];
        [m_FillOpacitySlider setAction:@selector(onFillOpacitySlider:)];

        //SHAPE RADIUS SLIDER
        m_ShapeRadiusLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [m_ShapeRadiusLabel setStringValue:@"Shape Radius (meters)"];
        [m_ShapeRadiusLabel setFont:[CPFont systemFontOfSize:12.0]];
        [m_ShapeRadiusLabel sizeToFit];
        [m_ShapeRadiusLabel setFrameOrigin:CGPointMake(20, 280)];

        m_ShapeRadiusSlider = [[CPSlider alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(aFrame) + 290, 240, 20)];
        [m_ShapeRadiusSlider setMinValue:100];
        [m_ShapeRadiusSlider setMaxValue:10000];
        [m_ShapeRadiusSlider setTarget:self];
        [m_ShapeRadiusSlider setAction:@selector(onShapeRadiusSlider:)];
        //

        m_ShowButton = [[CPCheckBox alloc] initWithFrame:CGRectMakeZero()];
        [m_ShowButton setTitle:@"Show Marker"];
        [m_ShowButton sizeToFit];
        [m_ShowButton setFrameOrigin:CGPointMake(20, 160)];
        [m_ShowButton setTarget:self];
        [m_ShowButton setAction:@selector(onShowButton:)];

        [self setBackgroundColor:[CPColor colorWithHexString:"EDEDED"]];

        [self addSubview:iconTypeLabel];
        [self addSubview:m_IconTypeButton];

        [self addSubview:m_IconSubTypeLabel];
        [self addSubview:m_IconSubTypeButton];

        [self addSubview:m_IconColorLabel];
        [self addSubview:m_IconColorButton];

        //CIRCLE AND RECTANGLE OPTIONS
        [self addSubview:m_LineColorLabel];
        [self addSubview:m_LineColorWell];
        [self addSubview:m_FillColorLabel];
        [self addSubview:m_FillColorWell];
        [self addSubview:m_LineStrokeLabel];
        [self addSubview:m_LineStrokeSlider];
        [self addSubview:m_LineOpacityLabel];
        [self addSubview:m_LineOpacitySlider];
        [self addSubview:m_FillOpacityLabel];
        [self addSubview:m_FillOpacitySlider];
        [self addSubview:m_ShapeRadiusLabel];
        [self addSubview:m_ShapeRadiusSlider];

        [m_LineColorLabel setHidden:YES];
        [m_LineColorWell setHidden:YES];
        [m_FillColorLabel setHidden:YES];
        [m_FillColorWell setHidden:YES];
        [m_LineStrokeLabel setHidden:YES];
        [m_LineStrokeSlider setHidden:YES];
        [m_LineOpacityLabel setHidden:YES];
        [m_LineOpacitySlider setHidden:YES];
        [m_FillOpacityLabel setHidden:YES];
        [m_FillOpacitySlider setHidden:YES];
        [m_ShapeRadiusLabel setHidden:YES];
        [m_ShapeRadiusSlider setHidden:YES];

        //ALL OPTIONS
        [self addSubview:m_ShowButton];
    }

    return self;
}

- (void)onIconTypeChanged:(id)sender
{
    [self updateLayout];

    [self updatePointOverlay];
}

- (void)updateLayout
{
    var curIcon = [m_IconTypeButton titleOfSelectedItem];

    //Hide yo' kids; Hide yo' wife (this will make someone feel old someday)
    [m_LineColorLabel setHidden:YES];
    [m_LineColorWell setHidden:YES];
    [m_FillColorLabel setHidden:YES];
    [m_FillColorWell setHidden:YES];
    [m_LineStrokeLabel setHidden:YES];
    [m_LineStrokeSlider setHidden:YES];
    [m_LineOpacityLabel setHidden:YES];
    [m_LineOpacitySlider setHidden:YES];
    [m_FillOpacityLabel setHidden:YES];
    [m_FillOpacitySlider setHidden:YES];
    [m_ShapeRadiusLabel setHidden:YES];
    [m_ShapeRadiusSlider setHidden:YES];

    [m_IconSubTypeLabel setHidden:YES];
    [m_IconSubTypeButton setHidden:YES];

    [m_IconColorLabel setHidden:YES];
    [m_IconColorButton setHidden:YES];

    if(curIcon == "Circle" || curIcon == "Rectangle")
    {
        [m_LineColorLabel setHidden:NO];
        [m_LineColorWell setHidden:NO];
        [m_FillColorLabel setHidden:NO];
        [m_FillColorWell setHidden:NO];
        [m_LineStrokeLabel setHidden:NO];
        [m_LineStrokeSlider setHidden:NO];
        [m_LineOpacityLabel setHidden:NO];
        [m_LineOpacitySlider setHidden:NO];
        [m_FillOpacityLabel setHidden:NO];
        [m_FillOpacitySlider setHidden:NO];
        [m_ShapeRadiusLabel setHidden:NO];
        [m_ShapeRadiusSlider setHidden:NO];

        [m_ShowButton setFrameOrigin:CGPointMake(20, 320)];

        [self updateAdvancedOptionControls];
    }
    else
    {
        [m_IconColorLabel setHidden:NO];
        [m_IconColorButton setHidden:NO];

        if(curIcon == "Educational Icon")
        {
            [m_IconSubTypeLabel setHidden:NO];
            [m_IconSubTypeButton setHidden:NO];

            [m_IconColorLabel setFrameOrigin:CGPointMake(20, 160)];
            [m_IconColorButton setFrameOrigin:CGPointMake(20, 180)];
            [m_ShowButton setFrameOrigin:CGPointMake(20, 220)];

            [m_IconSubTypeButton removeAllItems];
            [m_IconSubTypeButton addItemsWithTitles:[[CPDictionary dictionaryWithJSObject:g_EducationIconTypes] allKeys]];
        }
        else
        {
            [m_IconColorLabel setFrameOrigin:CGPointMake(20, 100)];
            [m_IconColorButton setFrameOrigin:CGPointMake(20, 120)];
            [m_ShowButton setFrameOrigin:CGPointMake(20, 160)];
        }
    }
    
    if(m_OverlayTarget && [m_OverlayTarget visible])
        [m_ShowButton setState:CPOnState];
    else
        [m_ShowButton setState:CPOffState];
}

- (void)onIconSubTypeChanged:(id)sender
{
    [self updatePointOverlay];
}

- (void)onIconColorChanged:(id)sender
{
    [self updatePointOverlay];
}

- (void)updatePointOverlay
{
    if(m_OverlayTarget)
    {
        var curType = g_IconTypes[[m_IconTypeButton titleOfSelectedItem]];

        if(curType == "education")
            [m_OverlayTarget setIcon:curType + "/" + g_EducationIconTypes[[m_IconSubTypeButton titleOfSelectedItem]]];
        else
            [m_OverlayTarget setIcon:curType];

        [m_OverlayTarget setIconColor:g_MapIconColors[[m_IconColorButton titleOfSelectedItem]]];
        
        [m_OverlayTarget removeFromMapView];
        [m_OverlayTarget createGoogleMarker];
        [m_OverlayTarget updateGoogleMarker];
        [m_OverlayTarget addToMapView];
    }
}

- (void)setOverlayTarget:(PointOverlay)overlayTarget
{
    m_OverlayTarget = overlayTarget;

    var iconTypeMap = [CPDictionary dictionaryWithJSObject:g_IconTypes];
    var eduIconTypeMap = [CPDictionary dictionaryWithJSObject:g_EducationIconTypes];
    var iconColorMap = [CPDictionary dictionaryWithJSObject:g_MapIconColors];

    var iconType = [m_OverlayTarget icon];
    var iconSubType = nil
    var iconColor = [m_OverlayTarget iconColor];

    var subTypeSplit = iconType.indexOf("/");
    if(subTypeSplit != -1)
    {
        iconSubType = iconType.slice(subTypeSplit + 1, iconType.length);
        iconType = iconType.slice(0, subTypeSplit);

        [m_IconSubTypeButton selectItemWithTitle:[[eduIconTypeMap allKeysForObject:iconSubType] objectAtIndex:0]];
    }

    [m_IconTypeButton selectItemWithTitle:[[iconTypeMap allKeysForObject:iconType] objectAtIndex:0]];

    if(iconType == "rectangle" || iconType == "circle")
    {
        [self updateAdvancedOptionControls];
    }
    else
    {
        [m_IconColorButton selectItemWithTitle:[[iconColorMap allKeysForObject:iconColor] objectAtIndex:0]];
    }

    [self updateLayout];
}

- (void)updateAdvancedOptionControls
{
    var iconOptions = [m_OverlayTarget iconOptions];
    [m_LineColorWell setColor:[CPColor colorWithHexString:[iconOptions.strokeColor substringFromIndex:1]]];
    [m_FillColorWell setColor:[CPColor colorWithHexString:[iconOptions.fillColor substringFromIndex:1]]];

    [m_LineStrokeSlider setValue:iconOptions.strokeWeight];
    [m_LineOpacitySlider setValue:iconOptions.strokeOpacity * 100];
    [m_FillOpacitySlider setValue:iconOptions.fillOpacity * 100];
}

- (void)onLineColorWell:(id)sender
{
    [m_OverlayTarget setIconOption:"strokeColor" value:"#" + [[m_LineColorWell color] hexString]];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onFillColorWell:(id)sender
{
    [m_OverlayTarget setIconOption:"fillColor" value:"#" + [[m_FillColorWell color] hexString]];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onStrokeSlider:(id)sender
{
    [m_OverlayTarget setIconOption:"strokeWeight" value:[m_LineStrokeSlider doubleValue]];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onLineOpacitySlider:(id)sender
{
    [m_OverlayTarget setIconOption:"strokeOpacity" value:([m_LineOpacitySlider doubleValue] / 100)];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onFillOpacitySlider:(id)sender
{
    [m_OverlayTarget setIconOption:"fillOpacity" value:([m_FillOpacitySlider doubleValue] / 100)];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onShapeRadiusSlider:(id)sender
{
    [m_OverlayTarget setIconOption:"radius" value:[m_ShapeRadiusSlider doubleValue]];
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onShowButton:(id)sender
{
    if([m_ShowButton state] == CPOnState)
    {
        [m_OverlayTarget setVisible:YES];
        [m_OverlayTarget addToMapView];
    }
    //the else is nessecary CPMixedState is possible
    else if([m_ShowButton state] == CPOffState)
    {
        [m_OverlayTarget setVisible:NO];
        [m_OverlayTarget removeFromMapView];
    }
}

@end