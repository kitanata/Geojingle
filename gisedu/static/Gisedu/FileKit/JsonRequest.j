@import <Foundation/CPObject.j>

@import "../AuthKit/AKUserSessionManager.j"

@implementation JsonRequest : CPObject
{
    AKUserSessionManager m_SessionManager;
    CPURLConnection m_RequestConnection;

    id m_Delegate               @accessors(property=delegate);
    id m_JsonObject             @accessors(property=jsonObject);
    CPString m_RequestUrl       @accessors(property=requestUrl);
    CPString m_RequestMethod    @accessors(property=requestMethod);
}

/* The delegates to be implemented in classes that use this class are:
- (void) onJsonRequestFailed:(JsonRequest)request withError:(CPString)anError
- (void) onJsonRequestSuccessful:(JsonRequest)request
- (void) onJsonRequestSuccessful:(JsonRequest)request withResponse:(id)jsonResponse
*/

- (id)init
{
    self = [super init];

    if(self)
    {
        m_SessionManager = [AKUserSessionManager defaultManager];
        m_RequestConnection = nil;
        m_JsonObject = nil;

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

    if(m_RequestMethod == "POST" && m_JsonObject)
        [request setHTTPBody:[CPString JSONFromObject:m_JsonObject]];

    m_RequestConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_RequestConnection)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onJsonRequestFailed:withError:)])
            [m_Delegate onJsonRequestFailed:self withError:anError];

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
            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onJsonRequestFailed:withError:)])
                [m_Delegate onJsonRequestFailed:self withError:"An unknown error occurred."];
        }

        return;
    }

    var statusCode = [aResponse statusCode];

    if (aConnection == m_RequestConnection)
    {
        if(statusCode == 200)
        {
            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onJsonRequestSuccessful:)])
                [m_Delegate onJsonRequestSuccessful:self];
        }
        else
        {
            var requestError = "An unknown error occurred.";
            if(statusCode == 404)
                requestError = "I could not contact the server. Please check your internet connection and try again."
            else
                requestError = "The server rejected the request. You do not have permission to do this."

            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onJsonRequestFailed:withError:)])
                [m_Delegate onJsonRequestFailed:self withError:requestError];
        }
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if(aConnection == m_RequestConnection)
    {
        console.log("Here?");

        if(!aData || aData == "")
            return;

        var aData = aData.replace('while(1);', '');
        var responseData = JSON.parse(aData);

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onJsonRequestSuccessful:withResponse:)])
            [m_Delegate onJsonRequestSuccessful:self withResponse:responseData];
    }
}

//GET REQUESTS
+ (id)getRequestFromUrl:(CPString)url delegate:(id)delegate
{
    return [JsonRequest getRequestFromUrl:url delegate:delegate send:NO];
}

+ (id)getRequestFromUrl:(CPString)url delegate:(id)delegate send:(BOOL)send
{
    var newRequest = [[JsonRequest alloc] init];

    if(newRequest)
    {
        [newRequest setDelegate:delegate];
        [newRequest setRequestUrl:url];

        if(send)
            [newRequest send];
    }

    return newRequest;
}

//POST REQUESTS
+ (id)postRequestWithJSObject:(id)jsonObject
    toUrl:(CPString)url
    delegate:(id)delegate
{
    return [JsonRequest postRequestWithJSObject:jsonObject toUrl:url delegate:delegate send:NO];
}

+ (id)postRequestWithJSObject:(id)jsonObject
    toUrl:(CPString)url
    delegate:(id)delegate
    send:(BOOL)send
{
    var newRequest = [[JsonRequest alloc] init];

    if(newRequest)
    {
        [newRequest setRequestUrl:url];
        [newRequest setDelegate:delegate];
        [newRequest setJsonObject:jsonObject];
        [newRequest setRequestMethod:"POST"];

        if(send)
            [newRequest send];
    }

    return newRequest;
}

@end
