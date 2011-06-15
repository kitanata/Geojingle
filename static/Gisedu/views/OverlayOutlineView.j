@import <Foundation/CPObject.j>
@import <AppKit/CPTabView.j>

@implementation OverlayOutlineView : CPControl
{
    CPScrollView m_OverlayFeaturesScrollView;
    CPOutlineView m_OutlineView @accessors(property=outline);

    CPDictionary m_Items @accessors(property=items);
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_OverlayFeaturesScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 20, 300, CGRectGetHeight([self bounds]) - 20)];
        [m_OverlayFeaturesScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
        [self addSubview:m_OverlayFeaturesScrollView];
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