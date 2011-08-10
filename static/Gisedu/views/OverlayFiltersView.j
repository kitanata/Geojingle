@import <Foundation/CPObject.j>

@import "StringFilterView.j"
@import "IntegerFilterView.j"
@import "StringIdMapFilterView.j"
@import "BooleanFilterView.j"

@import "../FilterManager.j"
@import "../OverlayManager.j"

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
    OverlayManager m_OverlayManager;
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_FilterManager = [FilterManager getInstance];
        m_OverlayManager = [OverlayManager getInstance];
        
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

        [self setBackgroundColor:[CPColor colorWithHexString:"EDEDED"]];
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
    var filterType = [m_FilterManager typeFromFilter:item];

    var names = nil;

    if(filterType == "county")
        names = [[m_OverlayManager polygonalDataList:"county"] allKeysForObject:[item value]];
    else if(filterType == "school_district")
        names = [[m_OverlayManager polygonalDataList:"school_district"] allKeysForObject:[item value]];
    else if(filterType == "house_district")
        names = [[m_OverlayManager polygonalDataList:"house_district"] allKeysForObject:[item value]];
    else if(filterType == "senate_district")
        names = [[m_OverlayManager polygonalDataList:"senate_district"] allKeysForObject:[item value]];
    else if(filterType == "school_itc")
        names = [[m_OverlayManager schoolItcTypes] allKeysForObject:[item value]];
    else if(filterType == "ode_class")
        names = [[m_OverlayManager schoolOdeTypes] allKeysForObject:[item value]];
    else if(filterType == "school")
        names = [[m_OverlayManager schoolTypes] allKeysForObject:[item value]];
    else if(filterType == "organization")
        names = [[m_OverlayManager orgTypes] allKeysForObject:[item value]];

    var filterTypeName = [filterType stringByReplacingOccurrencesOfString:'_' withString:' '];
    var filterLabel = "Generic Filter";

    if(names)
    {
        if([names count] > 0)
            filterLabel = [names objectAtIndex:0] + " " + filterTypeName + " Filter";
        else
            filterLabel = "All " + filterTypeName + " Filter";
    }
    else
    {
        filterLabel = [item value] + " " + filterTypeName + " Filter";
    }

    return [filterLabel capitalizedString];
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

        var filterType = [m_FilterManager typeFromFilter:filter];

        if(filterType == "county")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager polygonalDataList:"county"]];
        }
        else if(filterType == "school_district")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager polygonalDataList:"school_district"]];
        }
        else if(filterType == "senate_district")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager polygonalDataList:"senate_district"]];
        }
        else if(filterType == "house_district")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager polygonalDataList:"house_district"]];
        }
        else if(filterType == "organization")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager orgTypes]];
        }
        else if(filterType == "school")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager schoolTypes]];
        }
        else if(filterType == "school_itc")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager schoolItcTypes]];
        }
        else if(filterType == "ode_class")
        {
            m_CurrentFilterView = [[StringIdMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager schoolOdeTypes]];
        }
        else if(filterType == "connectivity_less" || filterType == "connectivity_greater")
        {
            var acceptedValues = [CPArray arrayWithObjects:"1", "10", "100", "1000"];
            
            m_CurrentFilterView = [[IntegerFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:acceptedValues];
        }
        else if(filterType == "comcast_coverage")
        {
            m_CurrentFilterView = [[BooleanFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter];
        }

        [m_CurrentFilterView setAction:@selector(onFilterPropertiesChanged:)];
        [m_CurrentFilterView setTarget:self];
        [m_PropertiesView addSubview:m_CurrentFilterView];
    }
}

- (void) onAddFilter:(id)sender
{
    curSelRow = [m_OutlineView selectedRow];
    parentFilter = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];

    m_AddFilterPanel = [[AddFilterPanel alloc] initWithParentFilter:parentFilter];

    if(m_AddFilterPanel)
    {
        [m_AddFilterPanel setDelegate:self];
        [m_AddFilterPanel orderFront:self];
    }
    else
    {
        theAlert = [CPAlert alertWithError:"No more filters can legally be added to this filter."];
        [theAlert addButtonWithTitle:"Ok"];
        [theAlert runModal];
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

            if(m_CurrentFilterView)
            {
                [m_CurrentFilterView removeFromSuperview];
                m_CurrentFilterView = nil;
            }
        }
    }
}

- (void) onAddFilterConfirm:(CPString)filterType
{
    console.log("onAddFilterConfirm filterType is " + filterType);
    
    var newFilter = [m_FilterManager createFilter:filterType];

    curSelRow = [m_OutlineView selectedRow];

    if(curSelRow == CPNotFound)
    {
        [m_FilterManager addFilter:newFilter parent:nil];
        [m_OutlineView reloadItem:nil reloadChildren:YES];
    }
    else
    {
        curSelItem = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];
        console.log("Filter is " + newFilter + " and parent is " + curSelItem);
        
        [m_FilterManager addFilter:newFilter parent:curSelItem];
        [m_OutlineView reloadItem:curSelItem reloadChildren:YES];
        [m_OutlineView expandItem:curSelItem];
    }

    var newFilterIndex = [m_OutlineView rowForItem:newFilter];
    [m_OutlineView selectRowIndexes:[CPIndexSet indexSetWithIndex:newFilterIndex] byExtendingSelection:NO];
    [self onOutlineItemSelected:self];
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