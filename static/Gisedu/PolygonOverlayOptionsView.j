@import <Foundation/CPObject.j>
@import <AppKit/CPView.j>

@implementation PolygonOverlayOptionsView : CPView
{
    PolygonOverlay m_OverlayTarget; //TODO: MAKE m_OverlayTarget a CPArray of OverlayPolygons (Options *can* manage multiple polys at once)
}

- (id) initWithFrame:(CGRect)aFrame
{
    console.log("initializing PolygonOverlayOptionsView");
    
    self = [super initWithFrame:aFrame];

    if(self)
    {
        lineColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineColorLabel setStringValue:@"Polygon Line Color"];
        [lineColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineColorLabel sizeToFit];
        [lineColorLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 40, CGRectGetMinY(aFrame) + 40)];

        lineColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 40, 20, 20)];
        [lineColorWell setBordered:YES];

        [self addSubview:lineColorLabel];
        [self addSubview:lineColorWell];

        fillColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [fillColorLabel setStringValue:@"Polygon Fill Color"];
        [fillColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [fillColorLabel sizeToFit];
        [fillColorLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 40, CGRectGetMinY(aFrame) + 80)];

        fillColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 80, 20, 20)];
        [fillColorWell setBordered:YES];

        [self addSubview:fillColorLabel];
        [self addSubview:fillColorWell];

        lineStrokeLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineStrokeLabel setStringValue:@"Polygon Line Stroke Size"];
        [lineStrokeLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineStrokeLabel sizeToFit];
        [lineStrokeLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 120)];

        lineStrokeSlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 140, 210, 20)];
        [lineStrokeSlider setMinValue:0];
        [lineStrokeSlider setMaxValue:10];

        [self addSubview:lineStrokeLabel];
        [self addSubview:lineStrokeSlider];

        lineOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineOpacityLabel setStringValue:@"Polygon Line Opactiy"];
        [lineOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineOpacityLabel sizeToFit];
        [lineOpacityLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 170)];

        lineOpactiySlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 190, 210, 20)];
        [lineOpactiySlider setMinValue:0];
        [lineOpactiySlider setMaxValue:100];

        [self addSubview:lineOpacityLabel];
        [self addSubview:lineOpactiySlider];

        fillOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [fillOpacityLabel setStringValue:@"Polygon Fill Opactiy"];
        [fillOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [fillOpacityLabel sizeToFit];
        [fillOpacityLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 220)];

        fillOpactiySlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 240, 210, 20)];
        [fillOpactiySlider setMinValue:0];
        [fillOpactiySlider setMaxValue:100];

        [self addSubview:fillOpacityLabel];
        [self addSubview:fillOpactiySlider];
    }

    return self;
}

- (void)setOverlayTarget:(id)overlayTarget
{
    if([overlayTarget typeName] == "MultiPolygonOverlay")
    {
        //Add each polygon to a list of polygons - TODO: MAKE m_OverlayTarget a CPArray of OverlayPolygons
    }

    m_OverlayTarget = overlayTarget;

    //TODO: populate fields
}

@end