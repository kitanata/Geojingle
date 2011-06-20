/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "MapKit/MKMapView.j"
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>

@import "Gisedu/TablesController.j"

@import "Gisedu/views/LeftSideTabView.j"
@import "Gisedu/views/OverlayOutlineView.j"
@import "Gisedu/views/OverlayOptionsView.j"

@import "Gisedu/views/AddFilterPanel.j"

@import "Gisedu/loaders/PolygonOverlayLoader.j"
@import "Gisedu/loaders/PointOverlayLoader.j"
@import "Gisedu/loaders/OrganizationListLoader.j"

var m_ShowTablesToolbarId = 'showTables';
var m_OverlayOptionsToolbarId = 'overlayOptions';
var m_AddFilterToolbarId = 'addFilter';
var m_DeleteFilterToolbarId = 'deleteFilter';
var m_UpdateMapToolbarId = 'updateMap';

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;
    CPView m_ContentView;

    LeftSideTabView m_LeftSideTabView;
    OverlayOptionsView m_OverlayOptionsView;

    id m_CurSelectedItem;

    CPArray m_CountyItems;
    CPArray m_SchoolDistrictItems;

    OverlayManager m_OverlayManager;

    CPURLConnection m_LoadCountyList;
    CPURLConnection m_LoadSchoolDistrictList;

    TablesController m_TablesController;

    CPScrollView m_TableScrollView;

    var m_MinMapHeight; //map's minimum height
    var m_MaxMapHeight; //map's maximum height
    var m_MapHeight;    //map's current height

    var m_MinMapWidth;  //map's minimum width
    var m_MaxMapWidth;  //map's maximum width
    var m_MapWidth;     //map's current width
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        m_ContentView = [theWindow contentView];

    [theWindow orderFront:self];

    [m_ContentView setBackgroundColor:[CPColor whiteColor]];

    m_OverlayManager = [OverlayManager getInstance];
    [m_OverlayManager setDelegate:self];

    m_CountyItems = [CPArray array];
    m_SchoolDistrictItems = [CPArray array];

    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
    m_MapHeight = m_MaxMapHeight;

    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 580;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;
    m_MapWidth = m_MinMapWidth;

    var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);

    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) center:loc];

    [m_MapView setDelegate:self]
    [m_MapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [m_ContentView addSubview:m_MapView];

    [m_OverlayManager setMapView:m_MapView];

    m_LeftSideTabView = [[LeftSideTabView alloc] initWithContentView:m_ContentView];
    [m_ContentView addSubview:m_LeftSideTabView];

    m_OverlayOptionsView = [[OverlayOptionsView alloc] initWithParentView:m_ContentView andMapView:m_MapView];
    [m_ContentView addSubview:m_OverlayOptionsView];

    m_TableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(300, CGRectGetHeight([m_ContentView bounds]) - bottomHeight, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
    [m_TableScrollView setAutoresizingMask:CPViewMinYMargin | CPViewWidthSizable];
        var countyTableView = [[CPTableView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
        var countyNameCol = [[CPTableColumn alloc] initWithIdentifier:@"CountyNameColumn"];
        [countyNameCol setWidth:125.0];
        [[countyNameCol headerView] setStringValue:"County Name"];
        [countyTableView addTableColumn:countyNameCol];
        [m_TableScrollView setDocumentView:countyTableView];
        console.log("Loaded Table View");

    [self initMenu];

    //Top View - Buttons and Controls
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"My Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];
    [theWindow setToolbar:toolbar];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    [m_LoadCountyList cancel];
    m_LoadCountyList = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/county_list/"] delegate:self];

    [m_LoadSchoolDistrictList cancel];
    m_LoadSchoolDistrictList = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/school_district_list/"] delegate:self];
    
    [m_OverlayManager loadOrganizationTypeList];

    [m_LeftSideTabView mapViewIsReady:mapView];
    [[m_LeftSideTabView outlineView] setAction:@selector(onOutlineItemSelected:)];
    [[m_LeftSideTabView outlineView] setTarget:self];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_ShowTablesToolbarId, m_OverlayOptionsToolbarId, m_AddFilterToolbarId, m_DeleteFilterToolbarId, m_UpdateMapToolbarId];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_ShowTablesToolbarId, m_OverlayOptionsToolbarId, m_AddFilterToolbarId, m_DeleteFilterToolbarId, m_UpdateMapToolbarId];
}

// Create the toolbar item that is requested by the toolbar.
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	// Create the toolbar item and associate it with its identifier
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    var mainBundle = [CPBundle mainBundle];

    if(m_ShowTablesToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"view_table.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"view_table_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onDataTables:)];
        [toolbarItem setLabel:"Data Tables"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_OverlayOptionsToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"overlay_options.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"overlay_options_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onOverlayOptions:)];
        [toolbarItem setLabel:"Overlay Options"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_AddFilterToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"add_filter.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"add_filter_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:[m_LeftSideTabView filtersView]];
        [toolbarItem setAction:@selector(onAddFilter:)];
        [toolbarItem setLabel:"Add Filter"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_DeleteFilterToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"delete_filter.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"delete_filter_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:[m_LeftSideTabView filtersView]];
        [toolbarItem setAction:@selector(onDeleteFilter:)];
        [toolbarItem setLabel:"Delete Filter"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_UpdateMapToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"update_map.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"update_map_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onUpdateMapFilters:)];
        [toolbarItem setLabel:"Update Map"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }

    return toolbarItem;
}

- (void)initMenu
{
    var menu = [[CPMenu alloc] initWithTitle:@"dummy"];

  	var menuItem1 = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@"1"];
  	[menu addItem:menuItem1];

  	var menu11 = [[CPMenu alloc] initWithTitle:@"dummy"];
  	var menuItem111 = [[CPMenuItem alloc] initWithTitle:@"AAA" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu11 addItem:menuItem111];
  	[menu11 addItem:[CPMenuItem separatorItem]];
  	var menuItem112 = [[CPMenuItem alloc] initWithTitle:@"BBB" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu11 addItem:menuItem112];

	[menuItem1 setSubmenu:menu11];

  	var menuItem2 = [[CPMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@"4"];
  	[menu addItem:menuItem2];

  	var menu2 = [[CPMenu alloc] initWithTitle:@"dummy"];
  	var menuItem3 = [[CPMenuItem alloc] initWithTitle:@"CCC" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu2 addItem:menuItem3];
  	[menu2 addItem:[CPMenuItem separatorItem]];

  	var menuItem4 = [[CPMenuItem alloc] initWithTitle:@"DDD" action:nil keyEquivalent:@"2"];
  	[menu2 addItem:menuItem4];
	[menu2 addItem:[[CPMenuItem alloc] initWithTitle:@"EEE" action:nil keyEquivalent:@"2"]];

  	var menu3 = [[CPMenu alloc] initWithTitle:@"Phil"];
  	[menu3 addItem:[[CPMenuItem alloc] initWithTitle:@"GGG" action:@selector(showAlert:) keyEquivalent:@"2"]];
	[menuItem4 setSubmenu:menu3];

	[menuItem2 setSubmenu:menu2];

	var sharedApplication = [CPApplication sharedApplication];
	[sharedApplication setMainMenu:menu];

	// Show the application menu
	[CPMenu setMenuBarVisible:YES];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_LoadCountyList)
    {
        alert('Could not load county information! ' + anError);
        m_LoadCountyList = nil;
    }
    else if(aConnection == m_LoadSchoolDistrictList)
    {
        alert('Could not load school district information! ' + anError);
        m_LoadSchoolDistrictList = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);
        
    if (aConnection == m_LoadCountyList)
    {
        counties = [[OverlayManager getInstance] counties];
                        
        for(var i=0; i < listData.length; i++)
        {
            for(var key in listData[i])
            {
                m_CountyItems[i] = key;
                [counties setObject:listData[i][key] forKey:key];
            }
        }

        [[m_LeftSideTabView outlineView] setCountyItems:m_CountyItems];
        console.log("Finished Loading Counties");
        [self onUpdateMapFilters:self];
    }
    else if(aConnection == m_LoadSchoolDistrictList)
    {
        schoolDistricts = [m_OverlayManager schoolDistricts];

        for(var i=0; i < listData.length; i++)
        {
            for(var key in listData[i])
            {
                m_SchoolDistrictItems[i] = key;

                [schoolDistricts setObject:listData[i][key] forKey:key];
            }
        }

        [[m_LeftSideTabView outlineView] setSchoolDistrictItems:m_SchoolDistrictItems];
        console.log("Finished Loading School Districts");
    }
}

- (void)onOrgTypeListLoaded
{
    var orgTypes = [[m_OverlayManager orgTypes] allKeys];

    for(var i=0; i < [orgTypes count]; i++)
    {
        [[m_LeftSideTabView outlineView] addItem:[orgTypes objectAtIndex:i]];
    }
}

- (void)setCountyOverlayOnClick:(id)overlay
{
    [overlay setOnClickAction:@selector(OnCountyGeometrySelected:)];
    [overlay setEventTarget:self];
}

- (void)setOrgOverlayOnClick:(id)overlay
{
    [overlay setOnClickAction:@selector(OnOrgGeometrySelected:)];
    [overlay setEventTarget:self];
}

- (void)OnCountyGeometrySelected:(id)sender
{
    [m_OverlayOptionsView setPolygonOverlayTarget:sender];
}

- (void)OnOrgGeometrySelected:(id)sender
{
    [m_OverlayOptionsView setPointOverlayTarget:sender];
}

- (void)onOrgListLoaded:(CPString)orgName
{
    orgKeys = [[m_OverlayManager orgs] allKeys];

    [[m_LeftSideTabView outlineView] setArray:orgKeys forItem:orgName];
}

- (void)OnOrgGeometryLoaded:(id)sender
{
    orgOverlay = [sender overlay];

    infoLoader = [[InfoWindowOverlayLoader alloc] initWithIdentifier:[orgOverlay pk] andUrl:"http://127.0.0.1:8000/edu_org_info/"];
    [orgOverlay setInfoLoader:infoLoader];

    [m_OverlayOptionsView setPointOverlayTarget:orgOverlay];

    [[m_OverlayManager orgOverlays] setObject:orgOverlay forKey:[orgOverlay pk]];

    [orgOverlay addToMapView:m_MapView];
}

- (void)onSchoolDistrictGeometryLoaded:(id)sender
{
    pkToOverlay = [m_OverlayManager schoolDistrictOverlays];
    schoolDistOverlay = [sender overlay];

    [m_OverlayOptionsView setPolygonOverlayTarget:schoolDistOverlay];
    [pkToOverlay setObject:schoolDistOverlay forKey:[schoolDistOverlay pk]];
    [schoolDistOverlay addToMapView:m_MapView];
}

- (void) onOutlineItemSelected:(id)sender
{
    sender = [sender outline];
    
    var item = [sender itemAtRow:[sender selectedRow]];

    if([sender parentForItem:item] == nil)
        return;
            
    if([sender parentForItem:item] == "Counties")
    {
        counties = [m_OverlayManager counties];
        countyOverlays = [m_OverlayManager countyOverlays];

        itemPk = [counties objectForKey:item];

        console.log([countyOverlays objectForKey:itemPk]);

        [m_OverlayOptionsView setPolygonOverlayTarget:[countyOverlays objectForKey:itemPk]];

        [self showOverlayOptionsView];
    }
    else if([sender parentForItem:item] == "School Districts")
    {
        schoolDistrictOverlays = [m_OverlayManager schoolDistrictOverlays];
        schoolDistricts = [m_OverlayManager schoolDistricts];

        itemPk = [schoolDistricts objectForKey:item];

        if([schoolDistrictOverlays objectForKey:itemPk] == nil)
        {
            schoolDistOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:itemPk andUrl:"http://127.0.0.1:8000/school_district/"];
            [schoolDistOverlayLoader setAction:@selector(onSchoolDistrictGeometryLoaded:)];
            [schoolDistOverlayLoader setTarget:self];
            [schoolDistOverlayLoader loadAndShow:YES];
        }
        else
        {
            [m_OverlayOptionsView setPolygonOverlayTarget:[schoolDistrictOverlays objectForKey:itemPk]];
        }

        [self showOverlayOptionsView];
    }//Organizations
    else if([[m_OverlayManager orgTypeList] containsObject:[sender parentForItem:item]])
    {
        orgs = [m_OverlayManager orgs];
        orgOverlays = [m_OverlayManager orgOverlays];
        var orgId = [orgs objectForKey:item];

        if([orgOverlays objectForKey:orgId] == nil)
        {
              overlay = [[PointOverlayLoader alloc] initWithIdentifier:orgId andUrl:"http://127.0.0.1:8000/edu_org/"];
              [overlay setAction:@selector(OnOrgGeometryLoaded:)];
              [overlay setTarget:self];
              [overlay loadAndShow:YES];
        }
        else
        {
            overlay = [orgOverlays objectForKey:orgId];

            if(m_CurSelectedItem == item)
            {
                [overlay toggleInfoWindow];
            }
            [m_OverlayOptionsView setPointOverlayTarget:overlay];
        }

        [self showOverlayOptionsView];
    }

    m_CurSelectedItem = item;
}

- (void)showOverlayOptionsView
{
    [self updateMapTheory];
    m_MapWidth = m_MinMapWidth;

    [self updateMapViewFrame];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)hideOverlayOptionsView
{
    [m_OverlayOptionsView removeFromSuperview];

    [self updateMapTheory];
    m_MapWidth = m_MaxMapWidth;

    [self updateMapViewFrame];
}

- (void)updateMapTheory
{
    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 580;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;

    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
}

- (void)updateMapViewFrame
{
    [m_MapView setFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight)];
}

//TOOLBAR EVENTS

- (void)onDataTables:(id)sender
{
    if([m_TableScrollView superview] != nil)
    {
        [m_TableScrollView removeFromSuperview];
        [self updateMapTheory];
        m_MapHeight = m_MaxMapHeight;
        [self updateMapViewFrame];
    }
    else
    {
        var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);
        [m_TableScrollView setFrame:CGRectMake(300, CGRectGetHeight([m_ContentView bounds]) - bottomHeight, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];

        [self updateMapTheory];
        m_MapHeight = m_MinMapHeight;
        [self updateMapViewFrame];
        [m_ContentView addSubview:m_TableScrollView];
    }
}

- (void)onOverlayOptions:(id)sender
{
    if([m_OverlayOptionsView superview] != nil)
    {
        [self hideOverlayOptionsView];
    }
    else
    {
        [self showOverlayOptionsView];
    }
}

- (void)onUpdateMapFilters:(id)sender
{
    filterManager = [FilterManager getInstance];

    [filterManager updateMap:m_MapView];
}

@end
