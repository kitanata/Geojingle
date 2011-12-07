@import <Foundation/CPObject.j>

@import "StringFilterView.j"
@import "IntegerFilterView.j"
@import "StringIdMapFilterView.j"
@import "IdStringMapFilterView.j"
@import "BooleanFilterView.j"

@import "ScaleIntegerFilterView.j"
@import "ColorizeIntegerFilterView.j"

@import "../FilterManager.j"
@import "../OverlayManager.j"

var m_AddPointFilterToolbarId = 'addPointFilter';
var m_AddPolygonFilterToolbarId = 'addPolygonFilter';
var m_AddReduceFilterToolbarId = 'addReduceFilter';
var m_AddPostFilterToolbarId = 'addPostFilter';
var m_DeleteFilterToolbarId = 'deleteFilter';

@implementation OverlayFiltersView : CPView
{
    AppController m_AppController           @accessors(property=appController);

    AddFilterPanel m_AddFilterPanel;
    CPAlert m_DeleteFilterAlert;

    CPSplitView m_SplitView;
    CPScrollView m_ScrollView;
    CPOutlineView m_OutlineView;
    CPView m_PropertiesView;
    CPView m_CurrentFilterView;
        
    CPButton m_AddPointFilterButton;
    CPButton m_AddPolygonFilterButton;
    CPButton m_AddReduceFilterButton;
    CPButton m_AddPostFilterButton;
    CPButton m_DeleteFilterButton;

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

        m_ScrollContainerView = [[CPView alloc] initWithFrame:CGRectMake(10, height * 2, 280, height * 2)];
        m_ScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 24, 300, CGRectGetHeight([m_ScrollContainerView bounds]) - 24)];
        m_OutlineView = [[CPOutlineView alloc] initWithFrame:[m_ScrollView bounds]];

        m_ButtonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, 0, 300, 24)];
        [m_ButtonBar setBoundsSize:CGSizeMake(300, 24)];
        [m_ButtonBar setHasResizeControl:NO];
        [m_ButtonBar setResizeControlIsLeftAligned:NO];

        var mainBundle = [CPBundle mainBundle];

        m_AddPointFilterButton = [CPButton buttonWithTitle:""];
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/point_filter.png"] size:CPSizeMake(24, 24)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/point_filter.png"] size:CPSizeMake(24, 24)];
        [m_AddPointFilterButton setImage:image];
        [m_AddPointFilterButton setAlternateImage:highlighted];
        [m_AddPointFilterButton setTarget:self];
        [m_AddPointFilterButton setAction:@selector(onAddPointFilter:)];
        [m_AddPointFilterButton sizeToFit];

        m_AddPolygonFilterButton = [CPButton buttonWithTitle:""];
        image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/polygon_filter.png"] size:CPSizeMake(24, 24)];
        highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/polygon_filter.png"] size:CPSizeMake(24, 24)];
        [m_AddPolygonFilterButton setImage:image];
        [m_AddPolygonFilterButton setAlternateImage:highlighted];
        [m_AddPolygonFilterButton setTarget:self];
        [m_AddPolygonFilterButton setAction:@selector(onAddPolygonFilter:)];
        [m_AddPolygonFilterButton sizeToFit];

        m_AddReduceFilterButton = [CPButton buttonWithTitle:""];
        image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/reduce_filter.png"] size:CPSizeMake(24, 24)];
        highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/reduce_filter.png"] size:CPSizeMake(24, 24)];
        [m_AddReduceFilterButton setImage:image];
        [m_AddReduceFilterButton setAlternateImage:highlighted];
        [m_AddReduceFilterButton setTarget:self];
        [m_AddReduceFilterButton setAction:@selector(onAddReduceFilter:)];
        [m_AddReduceFilterButton sizeToFit];

        m_AddPostFilterButton = [CPButton buttonWithTitle:""];
        image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/post_filter.png"] size:CPSizeMake(24, 24)];
        highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/post_filter.png"] size:CPSizeMake(24, 24)];
        [m_AddPostFilterButton setImage:image];
        [m_AddPostFilterButton setAlternateImage:highlighted];
        [m_AddPostFilterButton setTarget:self];
        [m_AddPostFilterButton setAction:@selector(onAddPostFilter:)];
        [m_AddPostFilterButton sizeToFit];

        m_DeleteFilterButton = [CPButton buttonWithTitle:""];
        image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/delete_filter.png"] size:CPSizeMake(24, 24)];
        highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/delete_filter.png"] size:CPSizeMake(24, 24)];
        [m_DeleteFilterButton setImage:image];
        [m_DeleteFilterButton setAlternateImage:highlighted];
        [m_DeleteFilterButton setTarget:self];
        [m_DeleteFilterButton setAction:@selector(onDeleteFilter:)];
        [m_DeleteFilterButton sizeToFit];

        [m_ButtonBar setButtons:[m_AddPointFilterButton, m_AddPolygonFilterButton, m_AddReduceFilterButton, m_AddPostFilterButton, m_DeleteFilterButton]];

        [m_ScrollContainerView addSubview:m_ButtonBar];
        [m_ScrollContainerView addSubview:m_ScrollView];
        [m_ScrollContainerView setAutoresizingMask:CPViewHeightSizable];
        [m_ScrollView setAutoresizingMask:CPViewHeightSizable];

        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"Filters"];
        [layerNameCol setWidth:260];

        [m_OutlineView setHeaderView:nil];
        [m_OutlineView setCornerView:nil];
        [m_OutlineView addTableColumn:layerNameCol];
        [m_OutlineView setOutlineTableColumn:layerNameCol];
        [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
        [m_OutlineView setTarget:self];
        [m_OutlineView registerForDraggedTypes:[CPArray arrayWithObject:"filters"]];

        [m_OutlineView setDataSource:self];
        [m_ScrollView setDocumentView:m_OutlineView];

        [m_SplitView setVertical:NO];
        [m_SplitView addSubview:m_PropertiesView];
        [m_SplitView addSubview:m_ScrollContainerView];

        [self setBackgroundColor:[CPColor colorWithHexString:"EDEDED"]];
        [self addSubview:m_SplitView];
    }

    return self;
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    if (item === nil)
    {
        //console.log("index = "); console.log(index);
        //console.log("returning = "); console.log([[m_FilterManager userFilters] objectAtIndex:index]);
        return [[m_FilterManager userFilters] objectAtIndex:index];
    }
    else
    {
        //console.log("index = "); console.log(index);
        //console.log("returning = "); console.log([[item childNodes] objectAtIndex:index]);
        return [[item childNodes] objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    //console.log(item);
    //console.log("Problem expandable");
    //console.log(([[item childNodes] count] > 0));
    return ([[item childNodes] count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    //console.log(item);
    //console.log("Problem Child Num");
    if (item === nil)
    {
        //console.log([[m_FilterManager userFilters] count]);
        return [[m_FilterManager userFilters] count];
    }
    else
    {
        //console.log([[item childNodes] count]);
        return [[item childNodes] count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    var filterType = [item type];
    var filterDescription = [item description];

    var names = nil;

    var filterTypeName = [filterDescription name];
    var filterLabel = "All " + filterTypeName + " Filter";

    if([filterDescription filterType] == "LIST")
    {
        var filterName = [[filterDescription options] objectForKey:[item value]];

        if(!filterName)
            filterName = "All";
            
        filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "DICT")
    {
        filterLabel = [item value] + " " + filterTypeName + " Filter";
    }
    else if([filterDescription dataType] == "POINT")
    {
        var filterName = [[m_OverlayManager pointDataTypes:filterType] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "CHAR")
    {
        var filterName = [[filterDescription options] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "BOOL")
    {
        if([item value])
            filterLabel = "Has " + filterTypeName + " Filter";
        else
            filterLabel = "Doesn't have " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "INTEGER")
    {
        var filterValue = [item value];
        var requestOption = [item requestOption];

        if(requestOption == "lt")
            requestOption = "< "
        else if(requestOption == "gt")
            requestOption = "> "
        else if(requestOption == "gte")
            requestOption = ">= "
        else if(requestOption == "lte")
            requestOption = "<= "
        else
            requestOption = "== "

            
        if(filterValue != "All")
            filterLabel = requestOption + [item value] + " " + filterTypeName + " Filter";
    }

    return [filterLabel capitalizedString];
}

- (BOOL)outlineView:(CPOutlineView)outlineView acceptDrop:(id)info item:(id)item childIndex:(CPInteger)index
{
    var pboard = [info draggingPasteboard];
    var dataNode = [pboard dataForType:"filters"];

    if(item == dataNode)
        return NO;

    var dataNodeParent = [dataNode parentNode];

    if(!dataNodeParent)
    {
        [[m_FilterManager userFilters] removeObject:dataNode];

        if(item)
        {
            var itemRootParent = item;

            while([itemRootParent parentNode])
                itemRootParent = [itemRootParent parentNode];

            if(itemRootParent == dataNode)
            {
                [[m_FilterManager userFilters] addObjectsFromArray:[dataNode childNodes]];

                while([[dataNode childNodes] count] > 0)
                    [dataNode removeObjectFromChildNodesAtIndex:0];
            }

            [item insertObject:dataNode inChildNodesAtIndex:0];
        }
        else
        {
            [[m_FilterManager userFilters] addObject:dataNode];
        }

        return YES;
    }
    else if(!item)
    {
        if(dataNodeParent)
        {
            var dataNodeIndex = [[dataNodeParent childNodes] indexOfObject:dataNode];
            [dataNodeParent removeObjectFromChildNodesAtIndex:dataNodeIndex];
        }

        [[m_FilterManager userFilters] addObject:dataNode];

        return YES;
    }
    else if([item parentNode] != dataNode)
    {
        [item insertObject:dataNode inChildNodesAtIndex:0];

        return YES;
    }
    else if([item parentNode] == dataNode)
    {
        if(dataNodeParent)
        {
            var itemIndex = [[dataNode childNodes] indexOfObject:item];
            [dataNode removeObjectFromChildNodesAtIndex:itemIndex];

            var dataNodeIndex = [[dataNodeParent childNodes] indexOfObject:dataNode];
            [dataNodeParent removeObjectFromChildNodesAtIndex:dataNodeIndex];
            [dataNodeParent insertObject:item inChildNodesAtIndex:dataNodeIndex];
            [item insertObject:dataNode inChildNodesAtIndex:index];
        }
        else
        {
            var itemIndex = [[dataNode childNodes] indexOfObject:item];
            [dataNode removeObjectFromChildNodesAtIndex:itemIndex];
            [item insertObject:dataNode inChildNodesAtIndex:index];
        }

        return YES;
    }

    return NO;
}

- (CPDragOperation)outlineView:(CPOutlineView)outlineView validateDrop:(id)info proposedItem:(id)item proposedChildIndex:(CPInteger)index
{
    var movingItem = [[info draggingPasteboard] dataForType:"filters"];

    var filtersInTree = [self allTypesInFilterTree:movingItem];

    var exclusionMap = [m_FilterManager filterFlagMap];

    //console.log("Exclusion Map = ");
    //console.log(exclusionMap);

    for(var i=0; i < [filtersInTree count]; i++)
    {
        var curFilterType = [filtersInTree objectAtIndex:i];
        var curFilterDesc = [[m_FilterManager filterDescriptions] objectForKey:curFilterType];

        var curExs = [curFilterDesc excludeFilters];

        for(var j=0; j < [curExs count]; j++)
        {
            //console.log([curExs objectAtIndex:j]);
            
            exclusionMap[[curExs objectAtIndex:j]] = NO;
        }
    }

    var filtersInProposedItem = [CPArray arrayWithObject:[item type]];

    while([item parentNode])
    {
        [filtersInProposedItem addObject:[[item parentNode] type]];
        item = [item parentNode];
    }

    for(var i=0; i < [filtersInProposedItem count]; i++)
    {
        var curFilterType = [filtersInProposedItem objectAtIndex:i];

        if(exclusionMap[curFilterType] == NO)
            return CPDragOperationNone;
    }

    return CPDragOperationMove;
}

- (CPArray)allTypesInFilterTree:(GiseduFilter)filter
{
    var typeList = [CPArray array];
    var filterChildren = [filter childNodes];

    for(var i=0; i < [filterChildren count]; i++)
    {
        var curChild = [filterChildren objectAtIndex:i];

        [typeList addObjectsFromArray:[self allTypesInFilterTree:curChild]];
    }

    [typeList addObject:[filter type]];

    return typeList;
}

- (BOOL)outlineView:(CPOutlineView)outlineView writeItems:(CPArray)items toPasteboard:(CPPasteboard)pboard
{
    if([items count] > 1 || [items count] == 0)
        return NO;

    var theItem = [items objectAtIndex:0];

    [pboard declareTypes:[CPArray arrayWithObject:"filters"] owner:self];
    [pboard setData:theItem forType:"filters"];

    return YES;
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

        var filterType = [filter type];
        var filterDescription = [filter description];

        if([filterDescription dataType] == "POLYGON")
        {
            m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription options]];

            [[m_AppController pointDisplayOptions] disable];
            [[m_AppController polygonDisplayOptions] enable];
            [[m_AppController polygonDisplayOptions] setFilterTarget:filter];
        }
        else if([filterDescription dataType] == "POINT")
        {
            if([filterDescription filterType] == "DICT")
            {
                m_CurrentFilterView = [[StringFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[[m_OverlayManager pointDataTypes:filterType] allKeys]];
            }
            else if([filterDescription filterType] == "LIST")
            {
                m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription options]];
            }

            [[m_AppController polygonDisplayOptions] disable];
            [[m_AppController pointDisplayOptions] enable];
            [[m_AppController pointDisplayOptions] setFilterTarget:filter];
        }
        else if([filterDescription dataType] == "REDUCE")
        {
            if([filterDescription filterType] == "INTEGER")
            {
                m_CurrentFilterView = [[IntegerFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription options]];
            }
            else if([filterDescription filterType] == "CHAR")
            {
                //console.log("Char Filter Options = "); console.log([filterDescription options]);
                m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription options]];
            }
            else if([filterDescription filterType] == "BOOL")
            {
                m_CurrentFilterView = [[BooleanFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter];
            }

            [[m_AppController polygonDisplayOptions] enable];
            [[m_AppController pointDisplayOptions] enable];
            
            [[m_AppController polygonDisplayOptions] setFilterTarget:filter];
            [[m_AppController pointDisplayOptions] setFilterTarget:filter];
        }
        else if([filterDescription dataType] == "POST")
        {
            if([filterDescription filterType] == "SCALE_INTEGER")
                m_CurrentFilterView = [[ScaleIntegerFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription attributeFilters]];
            else if([filterDescription filterType] == "COLORIZE_INTEGER")
                m_CurrentFilterView = [[ColorizeIntegerFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[filterDescription attributeFilters]];

            [[m_AppController polygonDisplayOptions] disable];
            [[m_AppController pointDisplayOptions] disable];
        }
        else if([filterDescription filterType] == "LIST")
        {
            m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                        andFilter:filter andAcceptedValues:[filterDescription options]];
        }

        [m_CurrentFilterView setAction:@selector(onFilterPropertiesChanged:)];
        [m_CurrentFilterView setTarget:self];
        [m_PropertiesView addSubview:m_CurrentFilterView];
    }
}

- (void)onAddPointFilter:(id)sender
{
    [self showAddFilterPanel:"POINT"];
}

- (void)onAddPolygonFilter:(id)sender
{
    [self showAddFilterPanel:"POLYGON"];
}

- (void)onAddReduceFilter:(id)sender
{
    [self showAddFilterPanel:"REDUCE"];
}

- (void)onAddPostFilter:(id)sender
{
    [self showAddFilterPanel:"POST"];
}

- (void)showAddFilterPanel:(CPString)dataType
{
    var addFilterList = [self buildAddFilterList:dataType];
    
    if(addFilterList)
    {
        m_AddFilterPanel = [[AddFilterPanel alloc] initWithFilterNames:addFilterList];
        [m_AddFilterPanel setDelegate:self];
        [m_AddFilterPanel setTitle:"Add New " + [dataType capitalizedString] + " Filter"];
        [m_AddFilterPanel orderFront:self];
    }
    else
    {
        m_AddFilterPanel = nil;
        theAlert = [CPAlert alertWithError:"No more " + [dataType lowercaseString] + " filters can legally be added to this filter."];
        [theAlert addButtonWithTitle:"Ok"];
        [theAlert runModal];
    }
}

- (CPArray)buildAddFilterList:(CPString)dataType
{
    var parentFilter = [self curSelectedFilter];
    var parentType = [parentFilter type];

    var filterDescriptions = [m_FilterManager filterDescriptions];
    var excludedFilterIds = [CPArray array];

    if(parentFilter && parentType)
    {
        var parentTypes = [];
        var parentIter = parentFilter;

        while(parentIter != nil)
        {
            var parentDesc = [parentIter description];
            [excludedFilterIds addObjectsFromArray:[parentDesc excludeFilters]];
            parentIter = [parentIter parentNode];
        }
    }

    var itemList = [CPArray array];
    var filterIds = [filterDescriptions allKeys];

    for(var i=0; i < [filterIds count]; i++)
    {
        var curFilterId = [filterIds objectAtIndex:i];
        var curDesc = [filterDescriptions objectForKey:curFilterId];

        if([curDesc dataType] == dataType)
            [itemList addObject:curFilterId];
    }

    for(var i=0; i < [excludedFilterIds count]; i++)
    {
        var excludedId = [excludedFilterIds objectAtIndex:i].toString();
        [itemList removeObject:excludedId];
    }

    if(itemList.length == 0)
        return null;

    var addFilterList = [CPArray array];

    for(var i=0; i < [itemList count]; i++)
    {
        [addFilterList addObject:[[filterDescriptions objectForKey:[itemList objectAtIndex:i]] name]];
    }

    return addFilterList;
}

- (id)curSelectedFilter
{
    var curSelRow = [m_OutlineView selectedRow];
    return [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];
}

- (void)onDeleteFilter:(id)sender
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
    console.log("onAddFilterConfirm filterType = " + filterType);

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

- (void)refreshOutline
{
    [m_OutlineView reloadItem:nil reloadChildren:YES];
    [m_OutlineView expandItem:nil expandChildren:YES];
}

@end
