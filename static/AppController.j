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

@import <Foundation/CPURLConnection.j>
@import <SCAuth/SCUserSessionManager.j>

@import "Gisedu/TablesController.j"

@import "Gisedu/views/LeftSideTabView.j"
@import "Gisedu/views/OverlayOutlineView.j"
@import "Gisedu/views/OverlayOptionsView.j"

@import "Gisedu/views/AddFilterPanel.j"

@import "Gisedu/loaders/PolygonOverlayLoader.j"
@import "Gisedu/loaders/PointOverlayLoader.j"

@import "Gisedu/FileKit/FKFileController.j"

var m_OverlayOptionsToolbarId = 'overlayOptions';
var m_AddFilterToolbarId = 'addFilter';
var m_DeleteFilterToolbarId = 'deleteFilter';
var m_UpdateMapToolbarId = 'updateMap';

g_UrlPrefix = 'http://127.0.0.1:8000';

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

    TablesController m_TablesController;

    CPScrollView m_TableScrollView;

    var m_MinMapHeight; //map's minimum height
    var m_MaxMapHeight; //map's maximum height
    var m_MapHeight;    //map's current height

    var m_MinMapWidth;  //map's minimum width
    var m_MaxMapWidth;  //map's maximum width
    var m_MapWidth;     //map's current width

    SCUserSessionManager m_SessionManager;
    FKFileController m_ProjectCloudManager;

    CPMenu m_FileMenu;
    CPMenuItem m_FileNewMenuItem;       //reloads browser
    CPMenuItem m_FileOpenMenuItem;      //open a project
    CPMenuItem m_FileSaveMenuItem;      //save project
    CPMenuItem m_FileSaveAsMenuItem;    //save project as
    CPMenuItem m_FileSeparatorItem;
    CPMenuItem m_FileExitMenuItem;      //exit Gisedu (closes browser tab)

    CPMenu m_AccountMenu;
    CPMenuItem m_AccountLoginMenuItem;
    CPMenuItem m_AccountRegisterMenuItem;
    CPMenuItem m_AccountLogOutMenuItem;
    CPMenuItem m_AccountAdminMenuItem;

    CPAlert m_ExitAlert;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        m_ContentView = [theWindow contentView];

    [theWindow orderFront:self];
    [theWindow setDelegate:self];

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
    m_MapWidth = m_MaxMapWidth;

    var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);

    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    m_MapView = [[MKMapView getInstance] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) center:loc];

    [m_MapView setDelegate:self]
    [m_MapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [m_ContentView addSubview:m_MapView];

    [m_OverlayManager setMapView:m_MapView];

    m_OverlayOptionsView = [[OverlayOptionsView alloc] initWithParentView:m_ContentView];

    m_LeftSideTabView = [[LeftSideTabView alloc] initWithContentView:m_ContentView];
    [[m_LeftSideTabView filtersView] setOptionsView:m_OverlayOptionsView];
    [m_ContentView addSubview:m_LeftSideTabView];

    //Not added to mapview because default is minimized

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

    m_SessionManager = [SCUserSessionManager defaultManager];
    [CPURLConnection setClassDelegate:m_SessionManager];
    [m_SessionManager setDelegate:self];
    [m_SessionManager syncSession];

    m_ProjectCloudManager = [FKFileController getInstance];
    [m_ProjectCloudManager setDelegate:self];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    console.log("AppController:-mapViewIsReady() called");

    [m_OverlayManager loadBasicDataTypeMaps];

    [m_OverlayManager loadPointDataTypeLists];

    [m_LeftSideTabView mapViewIsReady:mapView];
    [[m_LeftSideTabView outlineView] setAction:@selector(onOutlineItemSelected:)];
    [[m_LeftSideTabView outlineView] setTarget:self];

    console.log("AppController:-mapViewIsReady() finished");
}

- (void)onBasicDataTypeMapsLoaded:(CPString)dataType
{
    if(dataType == "county")
        [self onUpdateMapFilters:self];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_OverlayOptionsToolbarId, m_AddFilterToolbarId, m_DeleteFilterToolbarId, m_UpdateMapToolbarId];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_OverlayOptionsToolbarId, m_AddFilterToolbarId, m_DeleteFilterToolbarId, m_UpdateMapToolbarId];
}

// Create the toolbar item that is requested by the toolbar.
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	// Create the toolbar item and associate it with its identifier
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    var mainBundle = [CPBundle mainBundle];

    if(m_OverlayOptionsToolbarId == anItemIdentifier)
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
    console.log("AppController:-initMenu() called");

    var menu = [[CPMenu alloc] initWithTitle:"main_menu"];

    //BEGIN FILE MENU
    var fileMenuItem = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@"F"];
  	m_FileMenu = [[CPMenu alloc] initWithTitle:@"file_menu"];
  	    m_FileNewMenuItem = [[CPMenuItem alloc] initWithTitle:@"New Project" action:@selector(onNewProject:) keyEquivalent:@"N"];
        m_FileOpenMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open Project" action:@selector(onOpenProject:) keyEquivalent:@"O"];
        m_FileSaveMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save Project" action:@selector(onSaveProject:) keyEquivalent:@"S"];
        m_FileSaveAsMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save Project As..." action:@selector(onSaveProjectAs:) keyEquivalent:nil];
        m_FileSeparatorItem = [CPMenuItem separatorItem];
        m_FileExitMenuItem = [[CPMenuItem alloc] initWithTitle:@"Exit Gisedu" action:@selector(onExitGisedu:) keyEquivalent:nil];

        [m_FileMenu addItem:m_FileNewMenuItem];
        [m_FileMenu addItem:m_FileOpenMenuItem];
        [m_FileMenu addItem:m_FileSaveMenuItem];
        [m_FileMenu addItem:m_FileSaveAsMenuItem];
        [m_FileMenu addItem:m_FileSeparatorItem];
        [m_FileMenu addItem:m_FileExitMenuItem];

  	[fileMenuItem setSubmenu:m_FileMenu];
  	[menu addItem:fileMenuItem];
  	//END FILE MENU

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
	[CPMenu setMenuBarTitle:"Untitled Project"];

    var accountMenuItem = [[CPMenuItem alloc] initWithTitle:"My Account" action:nil keyEquivalent:nil];
    m_AccountMenu = [[CPMenu alloc] initWithTitle:@"Account Menu"];
	    m_AccountLoginMenuItem = [[CPMenuItem alloc] initWithTitle:"Login" action:@selector(onLoginUser:) keyEquivalent:"L"];
	    m_AccountRegisterMenuItem = [[CPMenuItem alloc] initWithTitle:"Sign-Up" action:@selector(onRegisterUser:) keyEquivalent:"R"];
	    m_AccountLogOutMenuItem = [[CPMenuItem alloc] initWithTitle:"Logout" action:@selector(onLogoutUser:) keyEquivalent:"L"];
        m_AccountAdminMenuItem = [[CPMenuItem alloc] initWithTitle:"Admin" action:@selector(onAdminUser:) keyEquivalent:"A"];

	    [m_AccountMenu addItem:m_AccountLoginMenuItem];
	    [m_AccountMenu addItem:m_AccountRegisterMenuItem];
	    [m_AccountMenu addItem:m_AccountAdminMenuItem];
	    [m_AccountMenu addItem:m_AccountLogOutMenuItem];

    [accountMenuItem setSubmenu:m_AccountMenu];
	[menu addItem:accountMenuItem];

	[self updateMenuItems:NO];

	console.log("AppController:-initMenu() finished");
}

- (void)onPolygonOverlaySelected:(id)sender
{
    [m_OverlayOptionsView setPolygonOverlayTarget:sender];
    [self showOverlayOptionsView];
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

- (void) onOutlineItemSelected:(id)sender
{
    sender = [sender outline];
    
    var item = [sender itemAtRow:[sender selectedRow]];

    if([sender parentForItem:item] == nil)
        return;
            
    if([sender parentForItem:item] == "Counties")
    {
        counties = [m_OverlayManager basicDataTypeMap:"county"];
        countyOverlays = [m_OverlayManager basicDataOverlayMap:"county"];

        itemPk = [counties objectForKey:item];

        [m_OverlayOptionsView setPolygonOverlayTarget:[countyOverlays objectForKey:itemPk]];

        [self showOverlayOptionsView];
    }
    else if([sender parentForItem:item] == "School Districts")
    {
        schoolDistrictOverlays = [m_OverlayManager basicDataOverlayMap:"school_district"];
        schoolDistricts = [m_OverlayManager basicDataTypeMap:"school_district"];

        itemPk = [schoolDistricts objectForKey:item];

        if([schoolDistrictOverlays objectForKey:itemPk] == nil)
        {
            schoolDistOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:itemPk andUrl:(g_UrlPrefix + "/school_district")];
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
    else
    {
        var parentValue = [sender parentForItem:item];
        var orgTypeList = [[m_OverlayManager pointDataTypes:"organization"] allValues]

        if([orgTypeList indexOfObject:parentValue] != CPNotFound)
        {
            orgNames = [m_OverlayManager orgNames];
            var orgId = [orgNames objectForKey:item];
            var curOrg = [m_OverlayManager getOverlayObject:"organization" objId:orgId];

            [[curOrg overlay] toggleInfoWindow];
            [m_OverlayOptionsView setPointOverlayTarget:[curOrg overlay]];

            [self showOverlayOptionsView];
        }
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
    [[m_LeftSideTabView outlineView] clearItems];

    filterManager = [FilterManager getInstance];
    [filterManager setDelegate:self];
    [filterManager triggerFilters];
}

- (void)onPolygonOverlayLoaded:(id)overlay dataType:(CPString)dataType
{
    var dataTypeNameMap = {
                            'county' : "Counties",
                            'school_district' : "School District",
                            'house_district' : "House Districts",
                            'senate_district' : "Senate Districts"
    }

    [overlay setDelegate:self];
    [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:dataTypeNameMap[dataType]];
}

- (void)onPointOverlayLoaded:(id)overlay dataType:(CPString)dataType
{
    [[m_LeftSideTabView outlineView] addItem:[overlay name] forCategory:[overlay type]];
}

- (void)onFilterRequestProcessed:(id)sender
{
    [[m_LeftSideTabView outlineView] sortItems];
}


/*======================LOGIN STUFF */
- (void)alertWithMessage:(CPString)aMessage title:(CPString)aTitle
{
    var activationAlert = [[CPAlert alloc] init];
    [activationAlert setTitle:aTitle];
    [activationAlert setAlertStyle:CPInformationalAlertStyle];
    [activationAlert setMessageText:aMessage];
    [activationAlert addButtonWithTitle:@"Ok"];
    [activationAlert runModal];
}

- (void)successfulAlertWithMessage:(CPString)aMessage
{
    [self alertWithMessage:aMessage title:@"Success!"];
}

- (void)failureAlertWithMessage:(CPString)aMessage
{
    [self alertWithMessage:aMessage title:@"Failed!"];
}

- (void)onLoginUser:(id)sender
{
    [[SCUserSessionManager defaultManager] triggerLogin];
}

- (void)onRegisterUser:(id)sender
{
    [[SCUserSessionManager defaultManager] triggerRegister];
}

- (void)onLogoutUser:(id)sender
{
    [[SCUserSessionManager defaultManager] triggerLogout];
}

- (void)onManageUser:(id)sender
{

}

- (void)onAdminUser:(id)sender
{
    window.open(g_UrlPrefix + "/admin");
}

- (void)onSessionSyncSuccessful:(id)sender
{
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
}

- (void)onSessionSyncFailed:(id)sender
{
    console.log("No session exists for this client on the server.");
}

- (void)onLoginSuccessful:(id)sender
{
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
    [m_ProjectCloudManager loadProjectDictData];
}

- (void)onRegisterSuccessful:(id)sender
{
    //Change Menu To Show Log-Out
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
}

- (void)onLogoutSuccessful:(id)sender
{
    [self updateMenuItems:NO];
    [m_ProjectCloudManager clearProjectDictData];
    [m_ProjectCloudManager setProjectName:"Untitled"];

    [self updateMenuBarTitle];
}

- (void)onLogoutFailed:(id)sender
{
    logoutFailedAlter = [CPAlert alertWithError:"Something went terrible wrong and we were unable to log you out."];
    [logoutFailedAlter addButtonWithTitle:"Ok, I'll call eTech IT right away!"];
}

- (void)updateMenuItems:(BOOL)sessionActive
{
    [m_AccountLoginMenuItem setHidden:sessionActive];
    [m_AccountRegisterMenuItem setHidden:sessionActive];

    [m_FileOpenMenuItem setHidden:!sessionActive];
    [m_FileSaveMenuItem setHidden:!sessionActive];
    [m_FileSaveAsMenuItem setHidden:!sessionActive];
    [m_FileSeparatorItem setHidden:!sessionActive];

    [m_AccountAdminMenuItem setHidden:!sessionActive];
    [m_AccountLogOutMenuItem setHidden:!sessionActive];
}

- (void)updateMenuBarTitle
{
    var userId = [[SCUserSessionManager defaultManager] userIdentifier];
    var projectName = [[FKFileController getInstance] projectName];

    var theTitle = "";

    if(userId)
        theTitle += [userId capitalizedString] + "'s ";

    theTitle += [projectName capitalizedString] + " Project";

    [CPMenu setMenuBarTitle:theTitle];
}

//FILE MENU SELECTORS

- (void)onNewProject:(id)sender
{
    location.reload(true);
}

- (void)onOpenProject:(id)sender
{
    [m_ProjectCloudManager triggerOpenProject];
}

- (void)onSaveProject:(id)sender
{
    [m_ProjectCloudManager triggerSaveProject];
}

- (void)onSaveProjectAs:(id)sender
{
    [m_ProjectCloudManager triggerSaveProjectAs];
}

- (void)onExitGisedu:(id)sender
{
    m_ExitAlert = [[CPAlert alloc] init];
    [m_ExitAlert setTitle:"Are you sure?"];
    [m_ExitAlert setAlertStyle:CPInformationalAlertStyle];
    [m_ExitAlert setMessageText:"Are you sure you want to close gisedu?"];
    [m_ExitAlert addButtonWithTitle:@"No"];
    [m_ExitAlert addButtonWithTitle:@"Yes"];
    [m_ExitAlert setDelegate:self];
    
    [m_ExitAlert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if(theAlert == m_ExitAlert && returnCode == 1)
    {
        [[CPApplication sharedApplication] terminate:self];

        [[[CPApplication sharedApplication] mainWindow] close];
        [[[CPApplication sharedApplication] keyWindow] close];
        [[[CPApplication sharedApplication] modalWindow] close];

        [[theWindow platformWindow] orderOut:self];

        window.close();

        var badAlert = [CPAlert alertWithError:"Sorry. I could not close the window."];
        [badAlert runModal];
    }
}

- (id)buildJsonSaveData
{
    return {"filters": [[FilterManager getInstance] toJson]};
}

- (void)onOpenFileRequestSuccessful:(id)sender
{
    var jsonData = [sender jsonData];

    var filters = jsonData['filters'];

    [[FilterManager getInstance] fromJson:filters];
    [[m_LeftSideTabView filtersView] refreshOutline];
    [self onUpdateMapFilters:self];
    [self updateMenuBarTitle];
}

- (void)onOpenFileRequestFailed:(id)sender
{
    var badAlert = [CPAlert alertWithError:"Sorry. I could not open the project. " + [sender error]];
    [badAlert runModal];
}

- (void)onSaveFileRequestSuccessful:(id)sender
{
    var successAlert = [CPAlert alertWithError:"Your project was saved successfully to the server."];
    [successAlert setAlertStyle:CPInformationalAlertStyle];
    [successAlert runModal];
}

- (void)onSaveFileRequestFailed:(id)sender
{
    var badAlert = [CPAlert alertWithError:"Sorry. I could not save the project. " + [sender error]];
    [badAlert runModal];
}

@end
