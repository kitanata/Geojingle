@import <Foundation/CPObject.j>

@import "FKFilePanel.j"
@import "JsonRequest.j"

g_sharedFileController = nil;

//The FileController is responsible for maintaining connections and getting file information
//This information is then fed to it's child OpenPanel and SavePanel classes
//The Panel classes delegate to the FileController when a file needs to be opened/saved/inspected etc.
@implementation FKFileController : CPObject
{
    AKUserSessionManager m_SessionManager;

    JsonRequest m_ProjectDictLoader;
    JsonRequest m_OpenFileRequest;
    JsonRequest m_SaveFileRequest;

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
        m_SessionManager = [AKUserSessionManager defaultManager];
        m_ProjectFilename = "Untitled";
        m_ProjectFiles = [CPDictionary dictionary];
    }

    return self;
}

- (void)loadProjectDictData
{
    var requestUrl = (g_UrlPrefix + "/cloud/project_list/");
    m_ProjectDictLoader = [JsonRequest getRequestFromUrl:requestUrl delegate:self send:YES];
}

- (void)clearProjectDictData
{
    m_ProjectFiles = [CPDictionary dictionary];
}

- (void)triggerOpenProject
{
    if([m_SessionManager userIsLoggedIn])
    {
        var openPanel = [FKFilePanel openPanelWithProjectList:m_ProjectFiles];

        [openPanel setDelegate:self];
        [openPanel orderFront:self];
    }
    else
    {
        [m_SessionManager triggerLogin];
    }
}

- (void)triggerSaveProject
{
    if([m_SessionManager userIsLoggedIn])
    {
        if(m_ProjectFilename)
            [self sendSaveRequest];
        else
            [self triggerSaveProjectAs];
    }
    else
    {
        [m_SessionManager triggerLogin];
    }
}

- (void)triggerSaveProjectAs
{
    if([m_SessionManager userIsLoggedIn])
    {
        var savePanel = [FKFilePanel savePanelWithProjectList:m_ProjectFiles];

        [savePanel setDelegate:self];
        [savePanel orderFront:self];
    }
    else
    {
        [m_SessionManager triggerLogin];
    }
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
        var requestUrl = (g_UrlPrefix + "/cloud/project/" + m_ProjectFilename);

        m_SaveFileRequest = [JsonRequest postRequestWithJSObject:requestObject
            toUrl:requestUrl delegate:self send:YES];
    }
}

- (void)sendOpenRequest
{
    var requestUrl = (g_UrlPrefix + "/cloud/project/" + m_ProjectFilename);
    m_OpenFileRequest = [JsonRequest getRequestFromUrl:requestUrl delegate:self send:YES];
}

- (void) onJsonRequestFailed:(JsonRequest)request withError:(CPString)anError
{
    var errorAugment = "";

    if(request == m_SaveFileRequest)
        errorAugment = 'Could not save project data! ';
    else if(request == m_OpenFileRequest)
        errorAugment = 'Could not open project data! ';

    alert(errorAugment + anError);

    if(request == m_SaveFileRequest)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onSaveFileRequestFailed:)])
            [m_Delegate onSaveFileRequestFailed:self];
    }
    else if(request == m_OpenFileRequest)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onOpenFileRequestFailed:)])
            [m_Delegate onOpenFileRequestFailed:self];
    }
}

- (void) onJsonRequestSuccessful:(JsonRequest)request
{
    if(request == m_SaveFileRequest)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onSaveFileRequestSuccessful:)])
                [m_Delegate onSaveFileRequestSuccessful:self];
                
        [self loadProjectDictData];
    }
}

- (void) onJsonRequestSuccessful:(JsonRequest)request withResponse:(id)jsonResponse
{
    if(request == m_OpenFileRequest)
    {
        m_JsonData = jsonResponse;

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onOpenFileRequestSuccessful:)])
            [m_Delegate onOpenFileRequestSuccessful:self];
    }
    else if(request == m_ProjectDictLoader)
    {
        for(filename in jsonResponse)
        {
            [m_ProjectFiles setObject:jsonResponse[filename] forKey:filename];
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
