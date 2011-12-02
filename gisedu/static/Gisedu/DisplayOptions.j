@import <Foundation/CPObject.j>

@implementation DisplayOptions : CPObject
{
    id m_DefaultDisplayOptions;
    id m_DisplayOptions         @accessors(getter=rawOptions);
}

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOption:(CPString)option
{
    return m_DisplayOptions[option];
}

//This function should only be used during loading saved projects
//from the server. Use setDisplayOption or enchantOptionsFrom instead
//for anything else. It is unwise to use this to access things directly: Why?
//Because it can break backward compatability with old saves.
- (void)enchantOptionsFromJson:(id)rawOptions
{
    for(key in rawOptions)
        m_DisplayOptions[key] = rawOptions[key];
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

@end
