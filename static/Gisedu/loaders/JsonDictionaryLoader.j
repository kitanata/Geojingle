@import <Foundation/CPObject.j>

@implementation JsonDictionaryLoader : CPControl
{
    CPDictionary m_Dictionary   @accessors(property=dictionary);
    CPString m_szCategory       @accessors(property=category);
    var m_JsonRequest           @accessors(property=json);

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

    var request         = [CPURLRequest requestWithURL:m_szUrl];

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:m_JsonRequest]];
    m_SaveFileRequestUrl = [CPURLConnection connectionWithRequest:request delegate:self];
    
    m_Connection = [CPURLConnection connectionWithRequest:request delegate:self];
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