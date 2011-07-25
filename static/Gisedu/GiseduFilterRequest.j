@import <AppKit/CPTreeNode.j>

@implementation GiseduFilterRequest : CPObject
{
    BOOL m_bFinished    @accessors(property=finished);
    BOOL m_bCached      @accessors(property=cached);

    CPString m_szUrl;
    CPURLConnection m_Connection; //To pull data from django

    CPArray m_ResultSet @accessors(property=resultSet);
}

- (id)initWithUrl:(CPString)url
{
    self = [super init];

    if(self)
    {
        m_szUrl = url;

        m_bFinished = NO;
        m_bCached = NO;

        m_ResultSet = [CPArray array];
    }

    return self;
}

- (void)trigger
{
    [self trigger:NO];
}

- (void)trigger:(BOOL)reloadData
{
    m_bFinished = NO;

    if(!m_bCached || reloadData)
    {
        m_bCached = NO;
        m_ResultSet = [CPArray array];

        [m_Connection cancel];
        m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_szUrl] delegate:self];
    }
    else
    {
        m_bFinished = YES;
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        [self onError];
        m_Connection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);

    if (aConnection == m_Connection)
    {
        m_bFinished = YES;
        m_bCached = YES;

        m_ResultSet = [CPArray arrayWithObjects:listData count:listData.length];

        [[FilterManager getInstance] onFilterLoaded:self];
    }
}

+ (id)requestWithUrl:(CPString)url
{
    return [[GiseduFilterRequest alloc] initWithUrl:url];
}

@end