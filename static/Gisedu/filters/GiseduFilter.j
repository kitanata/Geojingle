@import <AppKit/CPTreeNode.j>

///////////////////////////////////////////////////////////////////
//Class: GiseduFilter
//Purpose: A base class for the filtering system
///////////////////////////////////////////////////////////////////
@implementation GiseduFilter : CPTreeNode
{
    CPString m_szType @accessors(property=type);
    CPString m_szName @accessors(property=name);

    BOOL m_bFinished    @accessors(property=finished);
    BOOL m_bCached      @accessors(property=cached);

    CPURLConnection m_Connection; //To pull data from django

    CPArray m_ObjectIds @accessors(property=objects);
}

- (id)initWithName:(CPString)name
{
    self = [super initWithRepresentedObject:"Filter"];

    if(self)
    {
        m_szType = "Gisedu Filter";
        m_szName = name;

        m_bFinished = NO;
        m_bCached = NO;

        m_ObjectIds = [CPArray array];
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
        m_ObjectIds = [CPArray array];

        [m_Connection cancel];
        m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:[self requestUrl]] delegate:self];
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

        for(var i=0; i < listData.length; i++)
        {
            [m_ObjectIds addObject:listData[i]];
        }

        [[FilterManager getInstance] onFilterLoaded:self];
    }
}

- (CPSet)filter
{
    overlayManager = [OverlayManager getInstance];

    var typeIds = [CPArray array];

    for(var i=0; i < [m_ObjectIds count]; i++)
    {
        [typeIds addObject:(m_szType + ":" + [m_ObjectIds objectAtIndex:i])];
    }

    console.log(typeIds);
    
    return [CPSet setWithArray:typeIds];
}

@end