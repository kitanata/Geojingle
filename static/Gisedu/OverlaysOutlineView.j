/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>

@import "CountyOverlay.j"

@implementation OverlaysOutlineView : CPView
{
    MKMapView m_MapView;

    CPOutlineView m_OutlineView;
    
    CPDictionary m_Items;

    CPDictionary m_CountyItems;

    CPURLConnection m_LoadCountyInformation;

    CPArray m_CountyOverlays;
}

- (id)initWithParentView:(CPScrollView)parentView andMapView:(MKMapView)mapView
{
    CPLogRegister(CPLogConsole);

    m_MapView = mapView;
    
    m_OutlineView = [[CPOutlineView alloc] initWithFrame:CGRectMake(0, 0, 300, CGRectGetHeight([parentView bounds]))];
    [parentView setDocumentView:m_OutlineView];

    var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
    [layerNameCol setWidth:125.0];

    [m_OutlineView setHeaderView:nil];
    [m_OutlineView setCornerView:nil];
    [m_OutlineView addTableColumn:layerNameCol];
    [m_OutlineView setOutlineTableColumn:layerNameCol];

    m_CountyItems = [@"Adams", @"Franklin", @"Wayne"];

    m_Items = [CPDictionary dictionaryWithObjects:[m_CountyItems, [@"District 1", @"District 2", @"District 3"],
        ["A Library"], ["A School"], ["An Organization"]] forKeys:[@"Counties", @"Districts", @"Libraries", @"Schools", @"Organizations"]];
    [m_OutlineView setDataSource:self];

    m_CountyOverlays = [CPArray array];
    [self loadOverlays];

    return self;
}

- (void)loadOverlays
{
    [m_LoadCountyInformation cancel];
    m_LoadCountyInformation = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/county_list/"] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_LoadCountyInformation) {
        alert('Load failed! ' + anError);
        m_LoadCountyInformation = nil;
    } else {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_LoadCountyInformation)
    {
        //[m_CountyItems removeAllObjects];
        
        var aData = aData.replace('while(1);', '');
        var counties = JSON.parse(aData);

        for(var i=0; i < counties.length; i++)
        {
            for(var key in counties[i])
            {
                m_CountyItems[i] = key;

                countyOverlay = [[CountyOverlay alloc] initWithIdentifier:counties[i][key] andMapView:m_MapView];

                m_CountyOverlays = [m_CountyOverlays arrayByAddingObject:countyOverlay];
            }
        }

        [m_Items setObject:m_CountyItems forKey:@"Counties"];
        [m_OutlineView setDataSource:self];
    }
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

- (void)setCountiesVisible:(BOOL)visible
{
    if(visible)
    {
        for(var i=0; i < [m_CountyOverlays count]; i++)
        {
            [[m_CountyOverlays objectAtIndex:i] addToMapView];
        }
    }
    else if(!visible)
    {
        for(var i=0; i < [m_CountyOverlays count]; i++)
        {
            overlay = [m_CountyOverlays objectAtIndex:i];

            console.log("County Overlay " + overlay);

            [overlay removeFromMapView];
        }
    }
}

@end