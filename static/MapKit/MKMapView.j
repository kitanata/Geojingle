@import <AppKit/CPView.j>
@import <AppKit/CPWebView.j>
@import "MKMarker.j"
@import "MKLocation.j"
@import "MKPolyline.j"

/* a "class" variable that will hold the domWin.google.maps object/"namespace" */
var gmNamespace = nil;

MKLoadingMarkupWhiteSpinner = @"<div style='position: absolute; top:50%; left:50%;'><img src='Frameworks/MapKit/Resources/spinner-white.gif'/></div>";
MKLoadingMarkupBlackSpinner = @"<div style='position: absolute; top:50%; left:50%;'><img src='Frameworks/MapKit/Resources/spinner-black.gif'/></div>";

g_mapViewInstance = nil;

@implementation MKMapView : CPWebView
{
    DOMElement      _DOMMapElement;
    JSObject        _gMap               @accessors(property=gMap);
    BOOL            _mapReady;
    BOOL            _googleAjaxLoaded;
    id              delegate            @accessors;
    BOOL            hasLoaded;
    MKLocation      _center;
    CPString        _centerName;
    int             _zoomLevel;
    
    CPView          _loadingView @accessors(property=loadingView);
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame center:nil];
}

- (id)initWithFrame:(CGRect)aFrame center:(MKLocation)aLocation
{
    return [self initWithFrame:aFrame center:aLocation loadingMarkup:nil];
}

- (id)initWithFrame:(CGRect)aFrame
             center:(MKLocation)aLocation 
      loadingMarkup:(CPString)someLoadingMarkup
{
    return [self initWithFrame:aFrame center:aLocation loadingMarkup:someLoadingMarkup loadingView:nil];
}

- (id)initWithFrame:(CGRect)aFrame
             center:(MKLocation)aLocation 
        loadingView:(CPString)aLoadingView
{
    return [self initWithFrame:aFrame center:aLocation loadingMarkup:nil loadingView:aLoadingView];
}

- (id)initWithFrame:(CGRect)aFrame
             center:(MKLocation)aLocation 
      loadingMarkup:(CPString)someLoadingMarkup
        loadingView:(CPString)aLoadingView
{
    console.log("MKMapView::initWithFrame() called");

    _center = aLocation;
    _zoomLevel = 6;
    
    if (!_center)
    {
        _center = [MKLocation locationWithLatitude:52 andLongitude:-1];
    }

    console.log("MKMapView:initWithFrame() Problem Area 1");
    
    if (!someLoadingMarkup)
    {
        someLoadingMarkup = @"";
    }

    console.log("MKMapView:initWithFrame() Problem Area 2");

    if (self = [super initWithFrame:aFrame])
    {
        _iframe.allowTransparency = true;

        var bounds = [self bounds];

        [self setFrameLoadDelegate:self];

        console.log("MKMapView:initWithFrame() Problem Area 3");

        [self _startedLoading];

        _ignoreLoadStart = YES;
        _ignoreLoadEnd = YES;

        console.log("MKMapView:initWithFrame() Problem Area 4");

        [self _load];

        console.log("MKMapView:initWithFrame() Problem Area 5");
    }

    console.log("MKMapView::initWithFrame() finished");

    return self;
}

- (void)_load
{
    // clear the iframe
    _iframe.src = g_UrlPrefix + "/map";

    if (_loadHTMLStringTimer !== nil)
    {
        window.clearTimeout(_loadHTMLStringTimer);
        _loadHTMLStringTimer = nil;
    }

    // need to give the browser a chance to reset iframe, otherwise we'll be document.write()-ing the previous document
    _loadHTMLStringTimer = window.setTimeout(function() {
            window.setTimeout(_loadCallback, 1);
    }, 0);
}

- (void)webView:(CPWebView)aWebView didFinishLoadForFrame:(id)aFrame
{
    console.log("MKMapView::didFinishLoadForFrame() called");

    var domWin = [self DOMWindow];

    _mapReady = YES;

    var googleScriptElement = domWin.document.createElement('script');
    _DOMMapElement = domWin.document.getElementById('MKMapViewDiv');

     //remember the google maps namespace, but only once because it's a class variable
    if (!gmNamespace)
    {
        gmNamespace = domWin.google.maps;
    }

    // for some things the current google namespace needs to be used...
    var localGmNamespace = domWin.google.maps;

    var centerLatLng = new localGmNamespace.LatLng([_center latitude], [_center longitude]);

    var mapOptions = {
        zoom: 8,
        center: centerLatLng,
        mapTypeId: localGmNamespace.MapTypeId.ROADMAP,
        backgroundColor: 'transparent'}

    _gMap = new localGmNamespace.Map(_DOMMapElement, mapOptions);

    // Hack to get mouse up event to work
    //localGmNamespace.Event.addDomListener(document.body, 'mouseup', function() { try { localGmNamespace.Event.trigger(domWin, 'mouseup'); } catch(e){} });

    _mapReady = YES;

    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }

    if (delegate && [delegate respondsToSelector:@selector(mapViewIsReady:)])
    {
        [delegate mapViewIsReady:self];
    }

    console.log("MKMapView::didFinishLoadForFrame() finished");
}

- (void)setFrameSize:(CGSize)aSize
{
    console.log("MKMapView::setFrameSize() called");

    [super setFrameSize:aSize];
    var bounds = [self bounds];

    if (_gMap) 
    {
        var domWin = [self DOMWindow];
        domWin.google.maps.event.trigger(_gMap, 'resize');
    }

    console.log("MKMapView::setFrameSize() finished");
}

/* Overriding CPWebView's implementation */
- (BOOL)_resizeWebFrame 
{
    console.log("MKMapView::_resizeWebFrame() called");

    var width = [self bounds].size.width,
        height = [self bounds].size.height;

    _iframe.setAttribute("width", width);
    _iframe.setAttribute("height", height);

    [_frameView setFrameSize:CGSizeMake(width, height)];

    console.log("MKMapView::_resizeWebFrame() finished");
}

- (void)viewDidMoveToSuperview
{
    console.log("MKMapView::viewDidMoveToSuperview() called");

    if (!_mapReady && _googleAjaxLoaded) 
    {
        [self createMap];
    }
    [super viewDidMoveToSuperview];

    console.log("MKMapView::viewDidMoveToSuperview() finished");
}

- (void)setCenter:(MKLocation)aLocation 
{
    _center = aLocation;
    if (_mapReady) 
    {
        _gMap.setCenter([aLocation googleLatLng]);
    }
}

- (MKLocation)center 
{
    return _center;
}

- (void)setZoom:(int)aZoomLevel 
{
    _zoomLevel = aZoomLevel;
    if (_mapReady) 
    {
        _gMap.setZoom(_zoomLevel);
    }
}

- (MKMarker)addMarker:(MKMarker)aMarker atLocation:(MKLocation)aLocation
{
    if (_mapReady) 
    {
        var gMarker = [aMarker gMarker];
        gMarker.setLatLng([aLocation googleLatLng]);
        _gMap.addOverlay(gMarker);
    } 
    else 
    {
        // TODO some sort of queue?
    }
    return marker;
}

- (void)clearOverlays 
{
    if (_mapReady) 
    {
        _gMap.clearOverlays();
    }
}

- (void)addMapItem:(MKMapItem)mapItem
{
    [mapItem addToMapView:self];
}

- (BOOL)isMapReady 
{
    return _mapReady;
}

- (JSObject)gmNamespace 
{
    console.log("MKMapView::-gmNamespace() called");

    var domWin = [self DOMWindow];
    
    if (domWin && _mapReady) 
    {
        console.log("MKMapView::-gmNamespace() finished without nil");

        return domWin.google.maps;
    }

    console.log("MKMapView::-gmNamespace() finished with nil");
    
    return nil;
}

+ (JSObject)gmNamespace 
{
    console.log("MKMapView::+gmNamespace() called");

    if (!gmNamespace)
    {
        console.log("Error: MKMapView must be instantiated before this is valid");
    }

    console.log("MKMapView::+gmNamespace() finished");

    return gmNamespace;
}

+ (id)getInstance
{
    console.log("MKMapView::+getInstance() called");

    if(!g_mapViewInstance)
    {
        g_mapViewInstance = [MKMapView alloc];
    }

    console.log("MKMapView::+getInstance() finished");

    return g_mapViewInstance;
}

@end

