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
    m_MapView = [[MKMapView getInstance] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) center:loc];

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
    [m_OverlayManager loadSchoolTypeList];
    [m_OverlayManager loadSchoolItcTypeList];
    [m_OverlayManager loadSchoolOdeTypeList];

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

        console.log("Finished Loading School Districts");
    }
}

- (void)onCountyOverlayLoaded:(id)overlay
{
    [overlay setOnClickAction:@selector(OnPolygonGeometrySelected:)];
    [overlay setEventTarget:self];

    [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:"Counties"];
}

- (void)onSchoolDistrictOverlayLoader:(id)overlay
{
    [overlay setOnClickAction:@selector(OnPolygonGeometrySelected:)];
    [overlay setEventTarget:self];

    [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:"School Districts"];
}

- (void)OnPolygonGeometrySelected:(id)sender
{
    [m_OverlayOptionsView setPolygonOverlayTarget:sender];
}

- (void)onOrgOverlaySelected:(id)organization
{
    console.log("AppController::onOrgOverlaySelected Called");
    [m_OverlayOptionsView setPointOverlayTarget:[organization overlay]];

    [[m_LeftSideTabView outlineView] selectItem:[organization name]];
}

- (void)onSchoolOverlaySelected:(id)school
{
    console.log("AppController:onSchoolOverlaySelected Called");
    [m_OverlayOptionsView setPointOverlayTarget:[school overlay]];

    [[m_LeftSideTabView outlineView] selectItem:[school name]];
}

- (void)onSchoolDistrictGeometryLoaded:(id)sender
{

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
    else if([[m_OverlayManager orgTypes] containsKey:[sender parentForItem:item]])
    {
        orgNames = [m_OverlayManager orgNames];
        var orgId = [orgNames objectForKey:item];
        var curOrg = [[m_OverlayManager organizations] objectForKey:orgId];

        [[curOrg overlay] toggleInfoWindow];
        [m_OverlayOptionsView setPointOverlayTarget:[curOrg overlay]];

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
    [filterManager setDelegate:self];
    [filterManager triggerFilters];
}

- (void)onFilterManagerFiltered:(CPSet)filterResult
{
    var resultSet = [filterResult allObjects];

    seps = [CPCharacterSet characterSetWithCharactersInString:":"];

    [[m_LeftSideTabView outlineView] clearItems];

    countyOverlays = [m_OverlayManager countyOverlays];
    schoolDistrictOverlays = [m_OverlayManager schoolDistrictOverlays];
    var organizations = [m_OverlayManager organizations];
    var schools = [m_OverlayManager schools];

    for(var i=0; i < [resultSet count]; i++)
    {
        typeIdPair = [resultSet objectAtIndex:i];
        items = [typeIdPair componentsSeparatedByCharactersInSet:seps];

        itemType = [items objectAtIndex:0];
        itemId = [items objectAtIndex:1];

        if(itemType == "county")
        {
            //Add the County to the map
            if([countyOverlays containsKey:itemId])
            {
                overlay = [countyOverlays objectForKey:itemId];
                [overlay addToMapView:m_MapView];
                [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:"Counties"];
            }
            else
            {
                [m_OverlayManager loadCountyOverlay:itemId andShowOnLoad:YES];
            }
        }
        else if(itemType == "org")
        {
            var curOrg = [m_OverlayManager getOrganization:itemId];

            if([curOrg overlay])
            {
                [[curOrg overlay] addToMapView:m_MapView];
                [[m_LeftSideTabView outlineView] addItem:[curOrg name] forCategory:[curOrg type]];
            }
            else
            {
                [curOrg loadPointOverlay:YES];
                [[m_LeftSideTabView outlineView] addItem:[curOrg name] forCategory:[curOrg type]];
            }
        }
        else if(itemType == "school")
        {
            var curSchool = [m_OverlayManager getSchool:itemId];

            console.log("Current School is " + curSchool);
            
            if([curSchool overlay])
            {
                [[curSchool overlay] addToMapView:m_MapView];
                [[m_LeftSideTabView outlineView] addItem:[curSchool name] forCategory:[curSchool type]];
            }
            else
            {
                [curSchool loadPointOverlay:YES];
                [[m_LeftSideTabView outlineView] addItem:[curSchool name] forCategory:[curSchool type]];
            }
        }
        else if(itemType == "school_district")
        {
            if([schoolDistrictOverlays containsKey:itemId])
            {
                var curOverlay = [schoolDistrictOverlays objectForKey:itemId];
                [curOverlay addToMapView:m_MapView];
                [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:"School Districts"];
            }
            else
            {
                [m_OverlayManager loadSchoolDistrictOverlay:itemId andShowOnLoad:YES];
            }
        }
    }

    [[m_LeftSideTabView outlineView] sortItems];
}

@end
