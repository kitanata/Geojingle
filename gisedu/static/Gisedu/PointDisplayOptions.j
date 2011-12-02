@import "DisplayOptions.j"

@implementation PointDisplayOptions : DisplayOptions
{
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_DefaultDisplayOptions = {
            "icon" : "circle",
            "iconColor" : "red",
            "strokeColor" : "#000000",
            "strokeOpacity" : 1.0,
            "strokeWeight" : 1.5,
            "fillColor" : "#000000",
            "fillOpacity" : 0.3,
            "radius" : 1000,
            "visible" : YES
        };

        [self resetOptions];
    }

    return self;
}

+ (id)defaultOptions
{
    return [[PointDisplayOptions alloc] init];
}

@end
