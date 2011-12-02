@import "DisplayOptions.j"

@implementation PolygonDisplayOptions : DisplayOptions
{
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_DefaultDisplayOptions = {
            "strokeColor" : "#000000",
            "strokeOpacity" : 1.0,
            "strokeWeight" : 1.5,
            "fillColor" : "#000000",
            "fillOpacity" : 0.3,
            "visible" : YES
        };

        [self resetOptions];
    }

    return self;
}

+ (id)defaultOptions
{
    return [[PolygonDisplayOptions alloc] init];
}

@end
