@import <Foundation/CPObject.j>

@implementation PointDisplayOptions : CPObject
{
    id m_DefaultDisplayOptions;
    id m_DisplayOptions         @accessors(getter=rawOptions);
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

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOption:(CPString)option
{
    return m_DisplayOptions[option];
}

- (void)enchantOptionsFrom:(PointDisplayOptions)theOptions
{
    var options = [theOptions rawOptions];

    for(key in options)
        m_DisplayOptions[key] = options[key];
}

- (void)resetOptions
{
    m_DisplayOptions = {};

    for(key in m_DefaultDisplayOptions)
        m_DisplayOptions[key] = m_DefaultDisplayOptions[key];
}

+ (id)defaultOptions
{
    return [[PointDisplayOptions alloc] init];
}

@end
