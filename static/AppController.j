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

@import "Gisedu/views/OverlayOutlineView.j"
@import "Gisedu/views/OverlayOptionsView.j"

@import "Gisedu/loaders/PolygonOverlayLoader.j"
@import "Gisedu/loaders/PointOverlayLoader.j"
@import "Gisedu/loaders/OrganizationListLoader.j"

var m_ShowTablesToolbarId = 'showTables';
var m_HideOverlayOptionsToolbarId = 'hideOverlayOptions';

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;

    CPView m_ContentView;

    OverlayOutlineView m_OutlineView;
    OverlayOptionsView m_OverlayOptionsView;

    CPArray m_CountyItems;
    CPArray m_SchoolDistrictItems;

    CPArray m_OrgTypes;                         //A List of all the possible organization types
    CPDictionary m_OrgToGid;                    //maps name of organization to it's primary key in the db
    CPDictionary m_OrgGidToOverlay;             //maps the gid of the organization to a PointOverlay.

    CPURLConnection m_LoadCountyList;
    CPURLConnection m_LoadSchoolDistrictList;
    CPURLConnection m_LoadOrgTypeList;

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

    //Top View - Buttons and Controls
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"My Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];
    [theWindow setToolbar:toolbar];

    [self initMenu];

    m_OutlineView = [[OverlayOutlineView alloc] initWithContentView:m_ContentView];
    [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
    [m_OutlineView setTarget:self];

    m_CountyItems = [CPArray array];
    m_SchoolDistrictItems = [CPArray array];

    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
    m_MapHeight = m_MaxMapHeight;

    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 580;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;
    m_MapWidth = m_MinMapWidth;

    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) center:loc];
    
    [m_MapView setDelegate:self]
    [m_MapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [m_ContentView addSubview:m_MapView];

    var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);

    m_TableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(300, CGRectGetHeight([m_ContentView bounds]) - bottomHeight, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
    [m_TableScrollView setAutoresizingMask:CPViewMinYMargin | CPViewWidthSizable];
        var countyTableView = [[CPTableView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
        var countyNameCol = [[CPTableColumn alloc] initWithIdentifier:@"CountyNameColumn"];
        [countyNameCol setWidth:125.0];
        [[countyNameCol headerView] setStringValue:"County Name"];
        [countyTableView addTableColumn:countyNameCol];
        [m_TableScrollView setDocumentView:countyTableView];
        console.log("Loaded Table View");

    m_OverlayOptionsView = [[OverlayOptionsView alloc] initWithParentView:m_ContentView andMapView:m_MapView];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    [m_OutlineView loadOutline];

    m_OrgToGid = [CPDictionary dictionary];
    m_OrgGidToOverlay = [CPDictionary dictionary];
    
    [m_LoadCountyList cancel];
    m_LoadCountyList = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/county_list/"] delegate:self];

    [m_LoadSchoolDistrictList cancel];
    m_LoadSchoolDistrictList = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/school_district_list/"] delegate:self];

    [m_LoadOrgTypeList cancel];
    m_LoadOrgTypeList = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/org_type_list/"] delegate:self];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_ShowTablesToolbarId, m_HideOverlayOptionsToolbarId];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_ShowTablesToolbarId, m_HideOverlayOptionsToolbarId];
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
    else if(m_HideOverlayOptionsToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"hide_overlay_options.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"hide_overlay_options_highlighted.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onOverlayOptions:)];
        [toolbarItem setLabel:"Overlay Options"];

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
    else if(aConnection == m_LoadOrgTypeList)
    {
        alert('Could not load organization type information! ' + anError);
        m_LoadOrgTypeList = nil;
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

                countyOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:listData[i][key] andUrl:"http://127.0.0.1:8000/county/"];
                [countyOverlayLoader setAction:@selector(OnCountyGeometryLoaded:)];
                [countyOverlayLoader setTarget:self];
                [countyOverlayLoader loadAndShow:NO];

                [counties setObject:listData[i][key] forKey:key];
            }
        }

        [m_OutlineView setCountyItems:m_CountyItems];
        console.log("Finished Loading Counties");
    }
    else if(aConnection == m_LoadSchoolDistrictList)
    {
        schoolDistricts = [[OverlayManager getInstance] schoolDistricts];

        for(var i=0; i < listData.length; i++)
        {
            for(var key in listData[i])
            {
                m_SchoolDistrictItems[i] = key;

                [schoolDistricts setObject:listData[i][key] forKey:key];
            }
        }

        [m_OutlineView setSchoolDistrictItems:m_SchoolDistrictItems];
        console.log("Finished Loading School Districts");
    }
    else if(aConnection == m_LoadOrgTypeList)
    {
        console.log("Loading Organization Type List");
        
        for(var i=0; i < listData.length; i++)
        {
            [m_OutlineView addItem:listData[i]];
            
            loader = [[OrganizationListLoader alloc] initWithTypeName:listData[i]];
            [loader setAction:@selector(OnOrgListLoaded:)];
            [loader setTarget:self];
            [loader load];
        }

        m_OrgTypes = [CPArray arrayWithObjects:listData count:listData.length];
    }
}

- (void)OnCountyGeometryLoaded:(id)sender
{
    overlay = [sender overlay];

    overlayManager = [OverlayManager getInstance];
    countyOverlays = [overlayManager countyOverlays];
    
    [countyOverlays setObject:overlay forKey:[overlay pk]];
    [overlay addToMapView:m_MapView];
}

- (void)OnOrgListLoaded:(id)sender
{
    orgs = [sender orgs];

    orgKeys = [orgs allKeys];

    [m_OutlineView setArray:orgKeys forItem:[sender name]];

    [m_OrgToGid addEntriesFromDictionary:orgs];
}

- (void)OnOrgGeometryLoaded:(id)sender
{
    orgOverlay = [sender overlay];

    infoLoader = [[InfoWindowOverlayLoader alloc] initWithIdentifier:[orgOverlay pk] andUrl:"http://127.0.0.1:8000/edu_org_info/"];
    [orgOverlay setInfoLoader:infoLoader];
    
    [m_OverlayOptionsView setPointOverlayTarget:orgOverlay];
    [m_OrgGidToOverlay setObject:orgOverlay forKey:[orgOverlay pk]];
    
    [orgOverlay addToMapView:m_MapView];
}

- (void)onSchoolDistrictGeometryLoaded:(id)sender
{
    overlayManager = [OverlayManager getInstance];
    pkToOverlay = [overlayManager schoolDistrictOverlays];
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
        overlayManager = [OverlayManager getInstance];
        counties = [overlayManager counties];
        countyOverlays = [overlayManager countyOverlays];

        itemPk = [counties objectForKey:item];

        console.log([countyOverlays objectForKey:itemPk]);

        [m_OverlayOptionsView setPolygonOverlayTarget:[countyOverlays objectForKey:itemPk]];

        [self showOverlayOptionsView];
    }
    else if([sender parentForItem:item] == "School Districts")
    {
        overlayManager = [OverlayManager getInstance];
        schoolDistrictOverlays = [overlayManager schoolDistrictOverlays];
        schoolDistricts = [overlayManager schoolDistricts];

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
    else if([m_OrgTypes containsObject:[sender parentForItem:item]])
    {
        var orgId = [m_OrgToGid objectForKey:item];

        if([m_OrgGidToOverlay objectForKey:orgId] == nil)
        {
              overlay = [[PointOverlayLoader alloc] initWithIdentifier:orgId andUrl:"http://127.0.0.1:8000/edu_org/"];
              [overlay setAction:@selector(OnOrgGeometryLoaded:)];
              [overlay setTarget:self];
              [overlay loadAndShow:YES];
        }
        else
        {
            overlay = [m_OrgGidToOverlay objectForKey:orgId];
            [overlay openInfoWindow];

            [m_OverlayOptionsView setPointOverlayTarget:overlay];
        }

        [self showOverlayOptionsView];
    }
}

- (void)onDataTables:(id)sender
{
    if([m_TableScrollView superview] != nil)
    {
        [m_TableScrollView removeFromSuperview];
        m_MapHeight = m_MaxMapHeight;
        [self updateMapViewFrame];
    }
    else
    {
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

- (void)showOverlayOptionsView
{
    m_MapWidth = m_MinMapWidth;
    [self updateMapViewFrame];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)hideOverlayOptionsView
{
    [m_OverlayOptionsView removeFromSuperview];
    m_MapWidth = m_MaxMapWidth;
    [self updateMapViewFrame];
}

- (void)updateMapViewFrame
{
    [m_MapView setFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight)];
}

@end
