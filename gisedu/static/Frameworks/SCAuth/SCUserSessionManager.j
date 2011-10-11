/*
 * SCUserSessionManager.j
 * SCAuth
 *
 * Created by Saikat Chakrabarti on April 7, 2010.
 *
 * See LICENSE file for license information.
 *
 */

@import <Foundation/CPObject.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPUserSessionManager.j>
@import "SCLoginPanel.j"
@import "SCRegisterPanel.j"

var SCDefaultSessionManager = nil;

/*!
    @class SCUserSessionManager

    This class manages a user's session data. It is also responsible for dealing with 401
    response codes from the backend and will automatically deal with these by using its
    login provider to attempt to log the user in.
*/

@implementation SCUserSessionManager : CPUserSessionManager
{
    SCLoginPanel    m_LoginPanel            @accessors(property=loginPanel);
    RegisterPanel   m_RegisterPanel         @accessors(property=registerPanel);
    CPURLConnection m_LoginConnection;
    CPURLConnection m_LogoutConnection;
    CPURLConnection m_SessionSyncConnection;
    CPURLConnection m_CheckUsernameConnection;
    CPURLConnection m_RegisterConnection;

    CPString        m_csrfToken             @accessors(getter=csrfToken);

    id              m_Delegate              @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if (self)
    {
        m_LoginPanel = [[SCLoginPanel alloc] init];
        m_RegisterPanel = [[SCRegisterPanel alloc] init];
    }
    return self;
}

/*!
    Returns a SCUserSessionManager singleton that can be used app-wide.
 */
+ (SCUserSessionManager)defaultManager
{
    if (!SCDefaultSessionManager)
        SCDefaultSessionManager = [[SCUserSessionManager alloc] init];

    return SCDefaultSessionManager;
}

/*!
    Returns the current user identifier as a readable string.
 */
- (CPString)userDisplayName
{
    return [self userIdentifier];
}

- (void)onLoginPanelFinished:(id)panel
{
    var username = [panel username];
    var pass = [panel password];
    var rememberUser = [panel rememberUser];

    [self loginUser:username password:pass remember:rememberUser];
}

- (void)onRegisterPanelFinished:(id)panel
{
    var username = [panel username];
    var userpass = [panel password];
    var useremail = [panel email];
    var rememberUser = [panel rememberUser];

    [self registerUser:username password:userpass email:useremail remember:rememberUser];
}

- (void)onCheckUsername:(id)panel
{
    [self checkUsername:[panel username]];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPException)anException
{
    if (aConnection == m_SessionSyncConnection)
    {
        if (m_Delegate && [m_Delegate respondsToSelector:@selector(onSessionSyncFailed:)])
            [m_Delegate onSessionSyncFailed:self];
    }
    else if (connection == m_LoginConnection)
    {
        [self onLoginFailed];
    }
    else if (aConnection == m_CheckUsernameConnection)
    {
        [self checkUsernameFailed];
    }
    else if (connection == m_RegisterConnection)
    {
        [self onRegisterFailed];
    }
    else if (aConnection == m_LogoutConnection)
    {
        if (m_Delegate && [m_Delegate respondsToSelector:@selector(onLogoutFailed:)])
            [m_Delegate onLogoutFailed:self];
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    if (![aResponse isKindOfClass:[CPHTTPURLResponse class]])
    {
        [aConnection cancel];
        if (aConnection == m_SessionSyncConnection)
        {
            if (m_Delegate && [m_Delegate respondsToSelector:@selector(onSessionSyncFailed:)])
                [m_Delegate onSessionSyncFailed:self];
        }
        else if (aConnection == m_LogoutConnection)
        {
            if (m_Delegate && [m_Delegate respondsToSelector:@selector(onLogoutFailed:)])
                [m_Delegate onLogoutFailed:self];
        }
        else if (aConnection == m_LoginConnection)
            [self onLoginFailed];
        else if (aConnection == m_CheckUsernameConnection)
            [self checkUsernameFailed];
        else if (aConnection == m_RegisterConnection)
            [self onRegisterFailed];
        else
            [self _setErrorMessageText:GenericErrorMessage];
        return;
    }

    var statusCode = [aResponse statusCode];
    if (aConnection == m_SessionSyncConnection)
    {
        if (statusCode != 200)
            [aConnection cancel];

        if (statusCode == 200)
            return;

        if (statusCode == 404)
        {
            [self resetUserSession];
            if (m_Delegate && [m_Delegate respondsToSelector:@selector(onSessionSyncFailed:)])
                [m_Delegate onSessionSyncFailed:self];
        }
    }
    else if (aConnection == m_LogoutConnection)
    {
        [aConnection cancel];
        if (statusCode == 200)
        {
            [self resetUserSession];
            if (m_Delegate && [m_Delegate respondsToSelector:@selector(onLogoutSuccessful:)])
                [m_Delegate onLogoutSuccessful:self];
        }
        else if (m_Delegate && [m_Delegate respondsToSelector:@selector(onLogoutFailed:)])
        {
            [m_Delegate onLogoutFailed:self];
        }
    }
    else if(aConnection == m_LoginConnection)
    {
        if (statusCode != 200)
        {
            [aConnection cancel];

            [self onLoginFailed];
        }
    }
    else if(aConnection == m_RegisterConnection)
    {
        if(statusCode != 200)
        {
            [aConnection cancel];

            [self onRegisterFailed];
        }
    }
    else if(aConnection == m_CheckUsernameConnection)
    {
        if (statusCode == 200 || statusCode == 404)
            [self checkUsernameSuccessful];
        else
            [self checkUsernameFailed];
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    if(aConnection == m_SessionSyncConnection)
    {
        [self onUserAuthenticationSuccessful:data];

        if (m_Delegate && [m_Delegate respondsToSelector:@selector(onSessionSyncSuccessful:)])
            [m_Delegate onSessionSyncSuccessful:self];
    }
    else if(aConnection == m_LoginConnection)
    {
        [self onUserAuthenticationSuccessful:data];

        [aConnection cancel];

        if ([m_Delegate respondsToSelector:@selector(onLoginSuccessful:)])
            [m_Delegate onLoginSuccessful:self];

        [m_LoginConnection start];
        m_LoginConnection = nil;

        [m_LoginPanel close];
    }
    else if(aConnection == m_RegisterConnection)
    {
        [aConnection cancel];

        m_csrfToken = data;

        [self setStatus:CPUserSessionLoggedInStatus];
        [self setUserIdentifier:[m_RegisterPanel username]];

        [self onRegisterSuccess];
    }
}

- (void)onUserAuthenticationSuccessful:(id)data
{
    if (!data)
        return;

    var responseBody = [data objectFromJSON];

    if (responseBody.username && responseBody.csrf_token)
    {
        m_csrfToken = responseBody.csrf_token;

        [self setStatus:CPUserSessionLoggedInStatus];
        [self setUserIdentifier:responseBody.username];
    }
}

/* @ignore */
- (void)connectionDidReceiveAuthenticationChallenge:(CPURLConnection)aConnection
{
    console.log("Connection Received Auth Challenge");

    m_LoginConnection = aConnection;
    [m_LoginConnection cancel];
    [self resetUserSession];
    [self openLoginPanel];

    if ([m_Delegate respondsToSelector:@selector(sessionManagerDidInterceptAuthenticationChallenge:forConnection:)])
        [m_Delegate sessionManagerDidInterceptAuthenticationChallenge:self forConnection:aConnection];

}

- (void)syncSession
{
    var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"SCAuthSyncURL"] || @"/session/"];

    [request setHTTPMethod:@"GET"];
    m_SessionSyncConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)checkUsername:(CPString)username
{
    var request = [CPURLRequest requestWithURL:([[CPBundle mainBundle] objectForInfoDictionaryKey:@"SCAuthUserCheckURL"] || @"/check_username/") + username];

    [request setHTTPMethod:@"GET"];
    m_CheckUsernameConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

/* @ignore */
- (void)loginUser:(CPString)username password:(CPString)password remember:(BOOL)rememberUser
{
    var loginObject     = {'username' : username, 'password' : password, 'remember' : rememberUser},
        request         = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"SCAuthLoginURL"] || @"/session/"];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:loginObject]];
    m_LoginConnection = [CPURLConnection connectionWithRequest:request delegate:self];
    m_LoginConnection.username = username;
}

- (void)registerUser:(CPString)username password:(CPString)password email:(CPString)email remember:(BOOL)rememberUser
{
    var registerObject = {'username' : username, 'password' : password, 'email' : email, 'remember' : rememberUser},
        request         = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"SCAuthLoginURL"] || @"/register/"];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:registerObject]];

    m_RegisterConnection = [CPURLConnection connectionWithRequest:request delegate:self];
    m_RegisterConnection.username = username;
}

- (void)openLoginPanel
{
    m_LoginPanel = [[SCLoginPanel alloc] init];
    [m_LoginPanel setDelegate:self];
    [m_LoginPanel orderFront:self];
}

- (void)triggerRegister
{
    [self resetUserSession];

    m_RegisterPanel = [[SCRegisterPanel alloc] init];
    [m_RegisterPanel setDelegate:self];
    [m_RegisterPanel orderFront:self];
}

- (void)triggerLogin
{
    [self resetUserSession];
    [self openLoginPanel];
}

- (void)triggerLogout
{
    var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"SCAuthLogoutURL"] || @"/session/"];
    [request setHTTPMethod:@"DELETE"];

    m_LogoutConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)resetUserSession
{
    m_csrfToken = "";
    [self setStatus:CPUserSessionLoggedOutStatus];
    [self setUserIdentifier:nil];
}

- (void)onLoginFailed
{
    console.log("onLoginFailed called");

    if ([m_Delegate respondsToSelector:@selector(onLoginFailed:)])
        [m_Delegate onLoginFailed:self];

    m_LoginConnection = nil;

    [m_LoginPanel loginFailed];
}

- (void)onRegisterFailed
{
    console.log("Registration Failed");

    if([m_Delegate respondsToSelector:@selector(onRegisterFailed:)])
        [m_Delegate onRegisterFailed:self];

    m_RegisterConnection = nil;

    [m_RegisterPanel registerFailed];
}

- (void)onRegisterSuccess
{
    console.log("Registration Sucessful");

    if ([m_Delegate respondsToSelector:@selector(onRegisterSuccessful:)])
        [m_Delegate onRegisterSuccessful:self];

    [m_RegisterConnection start];
    m_RegisterConnection = nil;

    [m_RegisterPanel close];
}

- (void)checkUsernameFailed
{
    console.log("checkUsername Failed");

    m_CheckUsernameConnection = nil;

    [m_RegisterPanel checkUsernameFailed];
}

- (void)checkUsernameSuccessful
{
    console.log("checkUsername Successful");

    m_CheckUsernameConnection = nil;

    [m_RegisterPanel checkUsernameSuccessful];
}

@end
