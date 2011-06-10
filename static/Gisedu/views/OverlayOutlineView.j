@import <Foundation/CPObject.j>
@import <AppKit/CPTabView.j>

@implementation OverlayOutlineView : CPControl
{
    CPTabView m_TabView;
    CPTabViewItem m_OverlayFeaturesTab;

    CPView m_OverlayFeaturesView;
    CPOutlineView m_OutlineView @accessors(property=outline);

    CPDictionary m_Items @accessors(property=items);
}

- (id) initWithContentView:(CPView)contentView
{
    self = [super initWithFrame:[contentView bounds]];

    if(self)
    {
        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(0, 10, 300, CGRectGetHeight([contentView bounds]))];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

            //Overlay Features
            m_OverlayFeaturesTab = [[CPTabViewItem alloc] initWithIdentifier:@"LayersTab"];
            [m_OverlayFeaturesTab setLabel:"Overlay Features"];
                m_OverlayFeaturesView = [[CPView alloc] initWithFrame: CGRectMake(0, 100, 300, CGRectGetHeight([contentView bounds]) - 50)];
                    m_OverlayFeaturesScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(10, 20, 280, CGRectGetHeight([m_OverlayFeaturesView bounds]))];
                    [m_OverlayFeaturesView addSubview:m_OverlayFeaturesScrollView];
            [m_OverlayFeaturesTab setView:m_OverlayFeaturesView];

        [m_TabView addTabViewItem:m_OverlayFeaturesTab];
        [contentView addSubview:m_TabView];

        [m_TabView selectFirstTabViewItem:self];
    }

    return self;
}

- (void) loadOutline
{
    m_OutlineView = [[CPOutlineView alloc] initWithFrame:CGRectMake(0, 0, 300, CGRectGetHeight([m_OverlayFeaturesScrollView bounds]))];
    [m_OverlayFeaturesScrollView setDocumentView:m_OutlineView];

    var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
    [layerNameCol setWidth:300];

    [m_OutlineView setHeaderView:nil];
    [m_OutlineView setCornerView:nil];
    [m_OutlineView addTableColumn:layerNameCol];
    [m_OutlineView setOutlineTableColumn:layerNameCol];
    [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
    [m_OutlineView setTarget:self];

    m_Items = [CPDictionary dictionaryWithObjects:[[CPArray array], [CPArray array]] forKeys:[@"Counties", @"School Districts"]];
    [m_OutlineView setDataSource:self];
}

- (void) addItem:(CPString)itemName
{
    [m_Items setObject:[CPArray array] forKey:itemName];
    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (void) setArray:(CPArray)anArray forItem:(CPString)itemName
{
    [m_Items setObject:anArray forKey:itemName];
    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (void) setCountyItems:(CPArray)items
{
    [m_Items setObject:items forKey:@"Counties"];
    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (void) setSchoolDistrictItems:(CPArray)items
{
    [m_Items setObject:items forKey:@"School Districts"];
    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    CPLog("outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);

    if (item === nil)
    {
        var keys = [m_Items allKeys];
        return [keys objectAtIndex:index];
    }
    else
    {
        var values = [m_Items objectForKey:item];
        return [values objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    CPLog("outlineView:%@ isItemExpandable:%@", outlineView, item);

    var values = [m_Items objectForKey:item];
    return ([values count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    CPLog("outlineView:%@ numberOfChildrenOfItem:%@", outlineView, item);

    if (item === nil)
    {
        return [m_Items count];
    }
    else
    {
        var values = [m_Items objectForKey:item];
        return [values count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    CPLog("outlineView:%@ objectValueForTableColumn:%@ byItem:%@", outlineView, tableColumn, item);

    return item;
}

- (void) onOutlineItemSelected:(id)sender
{
    if(_action != nil && _target != nil)
    {
        [self sendAction:_action to:_target];
    }
}