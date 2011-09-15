@import <Foundation/CPObject.j>

@implementation DictionaryLoader : CPControl
{
    CPDictionary m_Dictionary   @accessors(property=dictionary);
    CPString m_szCategory       @accessors(property=category);
    CPString m_szSubCategory    @accessors(property=subCategory);//remove this once refactoring is done. Find a better way

    CPString m_szUrl;
    CPURLConnection m_Connection; //To pull data from django
}

- (id)initWithUrl:(CPString)url
{
    self = [super init];

    if(self)
    {
        m_szUrl = url;
        m_Dictionary = [CPDictionary dictionary];
    }

    return self;
}

- (void)load
{
    if(m_Connection)
        [m_Connection cancel];
    
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_szUrl] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Could not load dictionary! ' + anError);
        m_Connection = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);

    if (aConnection == m_Connection)
    {
        m_Dictionary = [self parseObjectIntoDictionary:listData];

        console.log("Finished loading dictionary");

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

- (CPDictionary)parseObjectIntoDictionary:(id)data
{
    var retDict = [CPDictionary dictionary];

    for(var key in data)
    {
        var curDataItem = data[key];

        if(Array.isArray(curDataItem))
            [retDict setObject:[self parseObjectIntoArray:curDataItem] forKey:key];
        else if(typeof(curDataItem) === "object")
            [retDict setObject:[self parseObjectIntoDictionary:curDataItem] forKey:key];
        else
            [retDict setObject:curDataItem forKey:key];
    }

    return retDict;
}

- (CPArray)parseObjectIntoArray:(id)data
{
    var retArr = [CPArray array];

    for(var i=0; i < data.length; i++)
    {
        var curDataItem = data[key];

        if(Array.isArray(curDataItem))
            [retArr addObject:[self parseObjectIntoArray:curDataItem]];
        else if(typeof(retArr[key]) === "object")
            [retArr addObject:[self parseObjectIntoDictionary:curDataItem]];
        else
            [retArr addObject:curDataItem];
    }

    return retArr;
}

@end