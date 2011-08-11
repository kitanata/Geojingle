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
        for(var key in listData)
        {
            [m_Dictionary setObject:listData[key] forKey:key];
        }

        console.log("Finished loading dictionary");

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end