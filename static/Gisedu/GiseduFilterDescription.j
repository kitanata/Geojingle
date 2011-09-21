@import <Foundation/CPObject.j>

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilterDescription : CPObject
{
    CPInteger m_Id                  @accessors(getter=id);
    CPString m_Name                 @accessors(getter=name);
    CPString m_FilterType           @accessors(getter=filterType);
    CPString m_DataType             @accessors(getter=dataType);
    CPString m_RequestModifier      @accessors(getter=requestModifier);
    CPArray m_OptionFilters         @accessors(getter=optionFilters);
    CPArray m_ExcludeFilters        @accessors(getter=excludeFilters);
    id m_FilterOptions              @accessors(getter=options); //either CPDictionary or CPArray
}

- (id)initWithValue:(id)value
{
    self = [super init];

    if(self)
    {
        m_Id = -1;
        m_Name = "Unknown";
        m_FilterType = "Unknown";
        m_DataType = "Unknown";
        m_RequestModifier = "Unknown";

        m_OptionFilters = nil;
        m_ExcludeFilters = nil;

        m_FilterOptions = nil;
    }

    return self;
}

- (CPString) subTypeForOption:(CPString)optionName
{
    if(m_FilterType == "DICT")
    {
        var filterKeys = [m_FilterOptions allKeys];

        for(var i=0; i < [filterKeys count]; i++)
        {
            var curKey = [filterKeys objectAtIndex:i];

            var nameValues = [[m_FilterOptions objectForKey:curKey] allValues];

            for(var j=0; j < [nameValues count]; j++)
            {
                if([nameValues objectAtIndex:j] == optionName)
                {
                    return curKey;
                }
            }
        }

        return m_Name;
    }
    else
    {
        return m_Name;
    }
}

- (void)fromJson:(id)jsonData
{
    m_Id = jsonData.id;
    m_Name = jsonData.name;
    m_FilterType = jsonData.filter_type;
    m_DataType = jsonData.data_type;
    m_RequestModifier = jsonData.request_modifier;

    m_OptionFilters = [CPArray arrayWithObjects:jsonData.option_filters count:jsonData.option_filters.length];
    m_ExcludeFilters = [CPArray arrayWithObjects:jsonData.exclude_filters count:jsonData.exclude_filters.length];

    if(Array.isArray(jsonData.filter_options))
        m_FilterOptions = [CPArray arrayWithObjects:jsonData.filter_options count:jsonData.filter_options.length];
    else
        m_FilterOptions = [CPDictionary dictionaryWithJSObject:jsonData.filter_options recursively:YES];
}

@end