@import "../GiseduModule.j"
@import "../../FileKit/JsonRequest.j"

@implementation SpeedTesterModule : GiseduModule
{
    var m_Time0;
    JsonRequest m_SpeedRequest;
    CPInteger m_ConnectionSpeed @accessors(getter=connectionSpeed);
}

- (id)initFromApp:(CPObject)app
{
    self = [super initFromApp:app];

    if(self)
    {
        m_ConnectionSpeed = 0;

        var d = new Date;
        m_Time0 = d.getTime();

        m_SpeedRequest = [JsonRequest getRequestFromUrl:g_UrlPrefix + "/speed_test"
            delegate:self send:YES];
    }

    return self;
}

- (void) onJsonRequestSuccessful:(JsonRequest)request withResponse:(id)jsonResponse
{
    var d = new Date;
    var time = Math.round((d.getTime()-m_Time0)/10)/100;
    m_ConnectionSpeed = Math.round(200/time);
}

@end
