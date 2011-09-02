@import <Foundation/CPObject.j>

@import "StringFilterView.j"
@import "IntegerFilterView.j"
@import "StringIdMapFilterView.j"
@import "IdStringMapFilterView.j"
@import "BooleanFilterView.j"

@import "../FilterManager.j"
@import "../OverlayManager.j"

@implementation OverlayFiltersView : CPView
{
    OverlayOptionsView m_OverlayOptionsView @accessors(property=optionsView);
    
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
        [m_OutlineView registerForDraggedTypes:[CPArray arrayWithObject:"filters"]];

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
    var filterType = [item type];

    var names = nil;

    var listBasedFilterTypes = [m_FilterManager listBasedFilterTypes];
    var pointFilterTypes = [m_FilterManager pointFilterTypes];
    var booleanDataFilters = [m_FilterManager booleanFilterTypes];

    var filterTypeName = [filterType stringByReplacingOccurrencesOfString:'_' withString:' '];
    var filterLabel = "All " + filterTypeName + " Filter";

    if(listBasedFilterTypes.indexOf(filterType) != -1)
    {
        var filterName = [[m_OverlayManager basicDataTypeMap:filterType] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if(pointFilterTypes.indexOf(filterType) != -1)
    {
        var filterName = [[m_OverlayManager pointDataTypes:filterType] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if(booleanDataFilters.indexOf(filterType) != -1)
    {
        if([item value])
            filterLabel = "Has " + filterTypeName + " Filter";
        else
            filterLabel = "Doesn't have " + filterTypeName + " Filter";
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
    var filterExclusionMap = [m_FilterManager filterExclusionMap];

    var movingItem = [[info draggingPasteboard] dataForType:"filters"];

    var filtersInTree = [self allTypesInFilterTree:movingItem];
    
    var exclusionMap = [m_FilterManager filterFlagMap];

    for(var i=0; i < [filtersInTree count]; i++)
    {
        var curFilterType = [filtersInTree objectAtIndex:i];
        
        var curExs = filterExclusionMap[curFilterType];

        for(var j=0; j < curExs.length; j++)
        {
            exclusionMap[curExs[j]] = NO;
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

        var listBasedFilterTypes = [m_FilterManager listBasedFilterTypes];
        var polygonalFilterTypes = [m_FilterManager polygonalFilterTypes];
        var pointDataFilters = [m_FilterManager pointFilterTypes];
        var booleanDataFilters = [m_FilterManager booleanFilterTypes];

        if(polygonalFilterTypes.indexOf(filterType) != -1)
        {
            m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                    andFilter:filter andAcceptedValues:[m_OverlayManager basicDataTypeMap:filterType]];

            [m_OverlayOptionsView setPolygonFilterTarget:filter];
        }
        else if(pointDataFilters.indexOf(filterType) != -1)
        {
            m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:[m_OverlayManager pointDataTypes:filterType]];

            [m_OverlayOptionsView setPointFilterTarget:filter];
        }
        else if(listBasedFilterTypes.indexOf(filterType) != -1)
        {
            m_CurrentFilterView = [[IdStringMapFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                        andFilter:filter andAcceptedValues:[m_OverlayManager basicDataTypeMap:filterType]];
        }
        else if(filterType == "connectivity_less" || filterType == "connectivity_greater")
        {
            var acceptedValues = [CPArray arrayWithObjects:"1", "10", "100", "1000"];
            
            m_CurrentFilterView = [[IntegerFilterView alloc] initWithFrame:[m_PropertiesView bounds]
                andFilter:filter andAcceptedValues:acceptedValues];
        }
        else if(booleanDataFilters.indexOf(filterType) != -1)
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