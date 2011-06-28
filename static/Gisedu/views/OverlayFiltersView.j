@import <Foundation/CPObject.j>

@import "../filters/CountyFilter.j"
@import "../filters/OrganizationFilter.j"

@import "filters/CountyFilterView.j"
@import "filters/OrganizationFilterView.j"

@import "../FilterManager.j"

@implementation OverlayFiltersView : CPView
{
    AddFilterPanel m_AddFilterPanel;
    CPAlert m_DeleteFilterAlert;

    CPSplitView m_SplitView;
    CPScrollView m_ScrollView;
    CPOutlineView m_OutlineView;
    CPView m_PropertiesView;
    CPView m_CurrentFilterView;

    FilterManager m_FilterManager;
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_FilterManager = [FilterManager getInstance];
        
        m_DeleteFilterAlert = [CPAlert alertWithError:"Are you sure you want to delete this filter?"];
        [m_DeleteFilterAlert addButtonWithTitle:"No, not yet."];
        [m_DeleteFilterAlert addButtonWithTitle:"Yes"];
        [m_DeleteFilterAlert setDelegate:self];

        m_SplitView = [[CPSplitView alloc] initWithFrame:CGRectMake(0, 20, 300, CGRectGetHeight(aFrame) - 20)];
        [m_SplitView setAutoresizingMask:CPViewHeightSizable];

        height = (CGRectGetHeight([self bounds]) - 30) / 3;
        m_PropertiesView = [[CPView alloc] initWithFrame:CGRectMake(10, height, 280, height)];

        m_ScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(10, height * 2, 280, height * 2)];
        m_OutlineView = [[CPOutlineView alloc] initWithFrame:[m_ScrollView bounds]];

        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"Filters"];
        [layerNameCol setWidth:260];

        [m_OutlineView setHeaderView:nil];
        [m_OutlineView setCornerView:nil];
        [m_OutlineView addTableColumn:layerNameCol];
        [m_OutlineView setOutlineTableColumn:layerNameCol];
        [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
        [m_OutlineView setTarget:self];

        [m_OutlineView setDataSource:self];
        [m_ScrollView setDocumentView:m_OutlineView];

        [m_SplitView setVertical:NO];
        [m_SplitView addSubview:m_PropertiesView];
        [m_SplitView addSubview:m_ScrollView];

        [self addSubview:m_SplitView];
    }

    return self;
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    if (item === nil)
    {
        return [[m_FilterManager userFilters] objectAtIndex:index];
    }
    else
    {
        return [[item childNodes] objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    return ([[item childNodes] count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    if (item === nil)
    {
        return [[m_FilterManager userFilters] count];
    }
    else
    {
        return [[item childNodes] count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    return [item type] + " Filter : " + [item name];
}

- (void) onOutlineItemSelected:(id)sender
{
    if([m_OutlineView selectedRow] == CPNotFound)
    {
        if(m_CurrentFilterView)
            [m_CurrentFilterView removeFromSuperview];
    }
    else
    {
        filter = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];

        if(m_CurrentFilterView)
            [m_CurrentFilterView removeFromSuperview];
        
        if([filter type] == "county")
            m_CurrentFilterView = [[CountyFilterView alloc] initWithFrame:[m_PropertiesView bounds] andFilter:filter];
        else if([filter type] == "org")
            m_CurrentFilterView = [[OrganizationFilterView alloc] initWithFrame:[m_PropertiesView bounds] andFilter:filter];
        
        [m_CurrentFilterView setAction:@selector(onFilterPropertiesChanged:)];
        [m_CurrentFilterView setTarget:self];
        [m_PropertiesView addSubview:m_CurrentFilterView];
    }
}

- (void) onAddFilter:(id)sender
{
    if(!m_AddFilterPanel)
    {
        m_AddFilterPanel = [[AddFilterPanel alloc] initWithTarget:self andAction:@selector(onAddFilterConfirm:)];

        [m_AddFilterPanel orderFront:self];
    }
    else
    {
        [m_AddFilterPanel orderFront:self];
    }
}

- (void) onDeleteFilter:(id)sender
{
    if([m_OutlineView selectedRow] != CPNotFound)
    {
        [m_DeleteFilterAlert runModal];
    }
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    console.log("Delete Filter Called");

    if(theAlert == m_DeleteFilterAlert)
    {
        if(returnCode == 1)
        {
            var curSelItem = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];
            curSelItemParent = [curSelItem parentNode];

            if(curSelItemParent == nil)
            {
                [m_FilterManager deleteFilter:curSelItem];
                [m_OutlineView reloadItem:nil reloadChildren:YES];
            }
            else
            {
                childNodes = [curSelItemParent childNodes];
                for(var i=0; i < [childNodes count]; i++)
                {
                    if([childNodes objectAtIndex:i] == curSelItem)
                    {
                        [curSelItemParent removeObjectFromChildNodesAtIndex:i];
                        break; //it down!
                    }
                }

                [m_OutlineView reloadItem:curSelItemParent reloadChildren:YES];
            }
        }
    }
}

- (void) onAddFilterConfirm:(id)sender
{
    filterType = [m_AddFilterPanel filterType];

    var newFilter = nil;
    
    if(filterType == "County")
        newFilter = [[CountyFilter alloc] initWithName:[m_AddFilterPanel filterName]];
    else if(filterType == "Organization")
        newFilter = [[OrganizationFilter alloc] initWithName:[m_AddFilterPanel filterName]];

    if(newFilter)
    {
        curSelRow = [m_OutlineView selectedRow];

        if(curSelRow == CPNotFound)
        {
            [m_FilterManager addFilter:newFilter parent:nil];
            [m_OutlineView reloadItem:nil reloadChildren:YES];
        }
        else
        {
            curSelItem = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];

            [m_FilterManager addFilter:newFilter parent:curSelItem];
            [m_OutlineView reloadItem:curSelItem reloadChildren:YES];
        }
    }

    [m_AddFilterPanel onCancel:sender];
}

- (void)onFilterPropertiesChanged:(id)sender
{
    curSelRow = [m_OutlineView selectedRow];

    if(curSelRow != CPNotFound)
    {
        curSelItem = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];

        [m_OutlineView reloadItem:curSelItem reloadChildren:NO];
    }
}

@end