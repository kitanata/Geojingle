@import <Foundation/CPObject.j>

@import "FKFilePanel.j"
@import "../loaders/DictionaryLoader.j"

g_sharedFileController = nil;

//The FileController is responsible for maintaining connections and getting file information
//This information is then fed to it's child OpenPanel and SavePanel classes
//The Panel classes delegate to the FileController when a file needs to be opened/saved/inspected etc.
@implementation FKFileController : CPObject
{
    SCUserSessionManager m_SessionManager;
    
    CPURLConnection m_OpenFileRequestUrl;
    CPURLConnection m_SaveFileRequestUrl;

    CPDictionary m_ProjectFiles; //name:date

    CPString m_ProjectFilename   @accessors(property=projectName);
    id m_JsonData                @accessors(property=jsonData);

    id m_Delegate   @accessors(property=delegate);  
                    //handling the opened data and the save data is sent out to the delegate through
                    //- (id)buildJsonSaveData and
                    //- (void)onOpenFileRequestSuccessful:(id)sender

    CPString m_RequestError     @accessors(property=error);
}

- (void) init
{
    self = [super init];

    if(self)
    {
        [self loadProjectDictData];
        m_SessionManager = [SCUserSessionManager defaultManager];
        m_ProjectFilename = "Untitled";
    }

    return self;
}

- (void)loadProjectDictData
{
    var projectDictLoader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/cloud/project_list/")];
    [projectDictLoader setAction:@selector(onProjectDictLoaded:)];
    [projectDictLoader setTarget:self];
    [projectDictLoader load];
}

- (void)clearProjectDictData
{
    m_ProjectFiles = nil;
}

- (void)onProjectDictLoaded:(id)sender
{
    m_ProjectFiles = [sender dictionary];
}

- (void)triggerOpenProject
{
    var openPanel = [FKFilePanel openPanelWithProjectList:m_ProjectFiles];

    [openPanel setDelegate:self];
    [openPanel orderFront:self];
}

- (void)triggerSaveProject
{
    if(m_ProjectFilename)
        [self sendSaveRequest];
    else
        [self triggerSaveProjectAs];
}

- (void)triggerSaveProjectAs
{
    var savePanel = [FKFilePanel savePanelWithProjectList:m_ProjectFiles];

    [savePanel setDelegate:self];
    [savePanel orderFront:self];
}

- (void)triggerCloseProject
{
    m_ProjectFilename = nil;
}

- (void)onFilePanelFinished:(id)sender
{
    m_ProjectFilename = [sender fileName];

    if([sender mode])
        [self sendSaveRequest];
    else
        [self sendOpenRequest];
}

- (void)sendSaveRequest
{
    if(m_Delegate && [m_Delegate respondsToSelector:@selector(buildJsonSaveData)])
    {
        var requestObject = [m_Delegate buildJsonSaveData];
        var request         = [CPURLRequest requestWithURL:(g_UrlPrefix + "/cloud/project/" + m_ProjectFilename)];

        var csrfTok = [m_SessionManager csrfToken];

        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        console.log("CSRF Token is " + csrfTok);
        [request setValue:csrfTok forHTTPHeaderField:@"X-CSRFToken"];
        [request setHTTPBody:[CPString JSONFromObject:requestObject]];
        m_SaveFileRequestUrl = [CPURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)sendOpenRequest
{
    var request = [CPURLRequest requestWithURL:(g_UrlPrefix + "/cloud/project/" + m_ProjectFilename)];
    [request setHTTPMethod:@"GET"];
    m_OpenFileRequestUrl = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_SaveFileRequestUrl)
    {
        alert('Could not save project data! ' + anError);
        m_Connection = nil;
    }
    else if(aConnection == m_OpenFileRequestUrl)
    {
        alert('Could not open project data! ' + anError);
        m_Connection = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    if (![aResponse isKindOfClass:[CPHTTPURLResponse class]])
    {
        [aConnection cancel];

        if (aConnection == m_SaveFileRequestUrl)
            alert('Could not save project data! ' + anError);
        else if (aConnection == m_OpenFileRequestUrl)
            alert('Could not open project data! ' + anError);

        return;
    }

    var statusCode = [aResponse statusCode];

    if (aConnection == m_SaveFileRequestUrl)
    {
        if(statusCode == 200)
        {
            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onSaveFileRequestSuccessful:)])
                [m_Delegate onSaveFileRequestSuccessful:self];

            [self loadProjectDictData];
        }
        else if(statusCode == 404)
        {
            m_RequestError = "I could not contact the server. Please check your internet connection and try again."

            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onSaveFileRequestFailed:)])
                [m_Delegate onSaveFileRequestFailed:self];
        }
        else
        {
            m_RequestError = "The server rejected the request. You do not have permission to do this."

            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onSaveFileRequestFailed:)])
                [m_Delegate onSaveFileRequestFailed:self];
        }
    }
    else if (aConnection == m_OpenFileRequestUrl)
    {
        if (statusCode == 404)
            m_RequestError = "No project exists of that name on your account."
        else if(statusCode != 200)
            m_RequestError = "The server rejected the request. You do not have permission to do this."

        if (statusCode != 200)
        {
            [aConnection cancel];

            if(m_Delegate && [m_Delegate respondsToSelector:@selector(onOpenFileRequestFailed:)])
                [m_Delegate onOpenFileRequestFailed:self];
        }
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if(aConnection == m_OpenFileRequestUrl)
    {
        var aData = aData.replace('while(1);', '');
        m_JsonData = JSON.parse(aData);

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onOpenFileRequestSuccessful:)])
        {
            [m_Delegate onOpenFileRequestSuccessful:self];
        }
    }
}

+ (id)getInstance
{
    if(!g_sharedFileController)
        g_sharedFileController = [[FKFileController alloc] init];

    return g_sharedFileController;
}

@end