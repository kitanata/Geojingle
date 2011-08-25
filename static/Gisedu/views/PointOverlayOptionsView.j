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
        [m_IconSubTypeLabel setHidden:YES];
        [m_IconSubTypeButton setHidden:YES];

        [m_IconColorLabel setFrameOrigin:CGPointMake(20, 100)];
        [m_IconColorButton setFrameOrigin:CGPointMake(20, 120)];
        [m_ShowButton setFrameOrigin:CGPointMake(20, 160)];
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
        [m_OverlayTarget updateGoogleMarker];
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
    [m_IconColorButton selectItemWithTitle:[[iconColorMap allKeysForObject:iconColor] objectAtIndex:0]];

    [self updateLayout];
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