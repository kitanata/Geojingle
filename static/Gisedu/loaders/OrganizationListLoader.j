@import <Foundation/CPObject.j>

@import "../Organization.j"

@implementation OrganizationListLoader : CPControl
{
    CPString m_szName @accessors(property=name); //The name of the organization type
    CPArray m_Organizations @accessors(property=orgs);
    
    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL @accessors(property=url);
}

- (id)initWithTypeName:(CPString)orgName
{
    m_szName = orgName;

    m_ConnectionURL = "http://127.0.0.1:8000/org_list_by_typename/";

    m_Organizations = [CPArray array];

    return self;
}

- (void)load
{
    [m_Connection cancel];
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_ConnectionURL + m_szName] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Load failed! ' + anError);
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
        for(var i=0; i < listData.length; i++)
        {
            var curOrg = [[Organization alloc] init];
            [curOrg setType:m_szName];

            for(var key in listData[i])
            {
                if(key == "gid")
                    [curOrg setPk:listData[i][key]];
                else if(key == "name")
                    [curOrg setName:listData[i][key]];
            }

            [m_Organizations addObject:curOrg];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end