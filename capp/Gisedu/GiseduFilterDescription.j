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
    CPArray m_AttributeFilters      @accessors(getter=attributeFilters);
    CPArray m_ExcludeFilters        @accessors(getter=excludeFilters);

    id m_FilterOptions              @accessors(getter=options); //either CPDictionary or CPArray
    CPDictionary m_FilterSubTypes;  //if m_FilterType == "DICT" then used otherwise null
                                    //used for reverse lookups
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

        m_AttributeFilters = nil;
        m_ExcludeFilters = nil;

        m_FilterOptions = nil;
        m_FilterSubTypes = nil;
    }

    return self;
}

- (CPString) subTypeForOption:(CPString)optionName
{
    if(m_FilterType == "DICT")
    {
        return [m_FilterSubTypes objectForKey:optionName];
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

    m_AttributeFilters = [CPArray arrayWithObjects:jsonData.attribute_filters count:jsonData.attribute_filters.length];
    m_ExcludeFilters = [CPArray arrayWithObjects:jsonData.exclude_filters count:jsonData.exclude_filters.length];

    if(Array.isArray(jsonData.filter_options))
        m_FilterOptions = [CPArray arrayWithObjects:jsonData.filter_options count:jsonData.filter_options.length];
    else
    {
        m_FilterOptions = [CPDictionary dictionaryWithJSObject:jsonData.filter_options recursively:YES];

        if(m_FilterType == "DICT")
        {
            m_FilterSubTypes = [CPDictionary dictionary];

            var filterOptionKeys = [m_FilterOptions allKeys];

            for(var i=0; i < [filterOptionKeys count]; i++)
            {
                var curKey = [filterOptionKeys objectAtIndex:i];

                var nameValues = [[m_FilterOptions objectForKey:curKey] allValues];

                for(var j=0; j < [nameValues count]; j++)
                {
                    var curNameValue = [nameValues objectAtIndex:j];

                    [m_FilterSubTypes setObject:curKey forKey:curNameValue];
                }
            }
        }
    }
}

@end
