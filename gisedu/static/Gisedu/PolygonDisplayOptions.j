@import <Foundation/CPObject.j>

@implementation PolygonDisplayOptions : CPObject
{
    id m_DefaultDisplayOptions;
    id m_DisplayOptions     @accessors(getter=rawOptions);
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

        m_DisplayOptions = {}

        for(key in m_DefaultDisplayOptions)
            m_DisplayOptions[key] = m_DefaultDisplayOptions[key];
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

- (void)enchantOptionsFrom:(PolygonDisplayOptions)theOptions
{
    var options = [theOptions rawOptions];

    for(key in options)
        m_DisplayOptions[key] = options[key];
}

- (void)resetOptions
{
    m_DisplayOptions = m_DefaultDisplayOptions.slice(0);
}

+ (id)defaultOptions
{
    return [[PolygonDisplayOptions alloc] init];
}

@end
