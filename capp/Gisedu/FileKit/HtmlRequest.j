@import <Foundation/CPObject.j>

@import "../AuthKit/AKUserSessionManager.j"

@implementation HtmlRequest : CPObject
{
    AKUserSessionManager m_SessionManager;
    CPURLConnection m_RequestConnection;

    id m_Delegate               @accessors(property=delegate);
    CPString m_RequestUrl       @accessors(property=requestUrl);
    CPString m_RequestMethod    @accessors(property=requestMethod);
}

/* The delegates to be implemented in classes that use this class are:
- (void) onHtmlRequestFailed:(HtmlRequest)request withError:(CPString)anError
- (void) onHtmlRequestSuccessful:(HtmlRequest)request
- (void) onHtmlRequestSuccessful:(HtmlRequest)request withResponse:(id)HtmlResponse
*/

- (id)init
{
    self = [super init];

    if(self)
    {
        m_SessionManager = [AKUserSessionManager defaultManager];
        m_RequestConnection = nil;

        m_RequestMethod = "GET";
    }

    return self;
}

- (id)send
{
    var request = [CPURLRequest requestWithURL:m_RequestUrl];

    var csrfTok = [m_SessionManager csrfToken];

    [request setHTTPMethod:m_RequestMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request setValue:csrfTok forHTTPHeaderField:@"X-CSRFToken"];
    m_RequestConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_RequestConnection)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onHtmlRequestFailed:withError:)])
            [m_Delegate onHtmlRequestFailed:self withError:anError];

        m_RequestConnection = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    if (![aResponse isKindOfClass:[CPHTTPURLResponse class]])
    {
        [aConnection cancel];

        if (aConnection == m_RequestConnection)
        {
            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onHtmlRequestFailed:withError:)])
                [m_Delegate onHtmlRequestFailed:self withError:"An unknown error occurred."];
        }

        return;
    }

    var statusCode = [aResponse statusCode];

    if (aConnection == m_RequestConnection)
    {
        if(statusCode == 200)
        {
            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onHtmlRequestSuccessful:)])
                [m_Delegate onHtmlRequestSuccessful:self];
        }
        else
        {
            var requestError = "An unknown error occurred.";
            if(statusCode == 404)
                requestError = "I could not contact the server. Please check your internet connection and try again."
            else
                requestError = "The server rejected the request. You do not have permission to do this."

            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onHtmlRequestFailed:withError:)])
                [m_Delegate onHtmlRequestFailed:self withError:requestError];
        }
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if(aConnection == m_RequestConnection)
    {
        if(!aData || aData == "")
            return;

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onHtmlRequestSuccessful:withResponse:)])
            [m_Delegate onHtmlRequestSuccessful:self withResponse:aData];
    }
}

//GET REQUESTS
+ (id)getRequestFromUrl:(CPString)url delegate:(id)delegate
{
    return [HtmlRequest getRequestFromUrl:url delegate:delegate send:NO];
}

+ (id)getRequestFromUrl:(CPString)url delegate:(id)delegate send:(BOOL)send
{
    var newRequest = [[HtmlRequest alloc] init];

    if(newRequest)
    {
        [newRequest setDelegate:delegate];
        [newRequest setRequestUrl:url];

        if(send)
            [newRequest send];
    }

    return newRequest;
}

@end
