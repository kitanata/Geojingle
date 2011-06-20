@import <Foundation/CPObject.j>

@implementation OrganizationTypeListLoader : CPControl
{
    CPArray m_OrganizationTypes  @accessors(property=orgTypes);
    
    CPURLConnection m_Connection; //To pull data from django
}

- (id)init
{
    m_OrganizationTypes = [CPArray array];

    return self;
}

- (void)load
{
    [m_Connection cancel];
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/org_type_list/"] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Could not load Organization Type list! ' + anError);
        m_Connection = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);

    if (aConnection == m_Connection)
    {
        m_OrganizationTypes = [CPArray arrayWithObjects:listData count:listData.length];

        console.log("Finished loading Organization Type list");

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end