@import <AppKit/CPPanel.j>

var GenericLoginErrorMessage = @"Something went wrong. Check your internet connection and try again.";
var InvalidAuthLoginErrorMessage = @"Incorrect username or password. Please try again.";

@implementation SCLoginPanel : CPPanel
{
    CPTextField m_UsernameLabel;
    CPTextField m_PasswordLabel;
    CPTextField m_Username;
    CPTextField m_Password;

    CPTextField m_ErrorMessage;

    CPButton m_LoginButton;
    CPButton m_CancelButton;

    CPCheckBox m_RememberMe;

    id m_Delegate   @accessors(property=delegate);
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(150,150,370,180) styleMask:CPClosableWindowMask];

    if(self)
    {
        m_ErrorMessage = [CPTextField labelWithTitle:"You've entered an incorrect username or password. Please try again."];
        [m_ErrorMessage setFrame:CGRectMake(0,0,370,50)];
        [m_ErrorMessage setBackgroundColor:[CPColor colorWithHexString:"96062A"]];
        [m_ErrorMessage setTextFieldBackgroundColor:[CPColor colorWithHexString:"96062A"]];
        [m_ErrorMessage setTextColor:[CPColor whiteColor]];
        [m_ErrorMessage setLineBreakMode:CPLineBreakByWordWrapping];
        [m_ErrorMessage setValue:CGInsetMake(9.0, 9.0, 9.0, 9.0) forThemeAttribute:@"content-inset"];

        var border = [[CPView alloc] initWithFrame:CPRectMake(0, CPRectGetHeight([m_ErrorMessage bounds]) - 1, CPRectGetWidth([m_ErrorMessage bounds]), 1)];
        [border setAutoresizingMask: CPViewWidthSizable | CPViewMinYMargin];
        [border setBackgroundColor:[CPColor grayColor]];
        [m_ErrorMessage addSubview:border];

        [m_ErrorMessage setHidden:YES];
        
        m_UsernameLabel = [CPTextField labelWithTitle:"Username: "];
        m_PasswordLabel = [CPTextField labelWithTitle:"Password: "];

        m_Username = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        m_Password = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        [m_Password setSecure:YES];

        [m_UsernameLabel setFrameOrigin:CGPointMake(40, 25)];
        [m_PasswordLabel setFrameOrigin:CGPointMake(40, 65)];

        [m_UsernameLabel sizeToFit];
        [m_PasswordLabel sizeToFit];

        var rightAlign = Math.max(CGRectGetWidth([m_UsernameLabel bounds]), CGRectGetWidth([m_PasswordLabel bounds])) + 60;

        [m_Username setFrameOrigin:CGPointMake(rightAlign, 20)];
        [m_Password setFrameOrigin:CGPointMake(rightAlign, 60)];

        m_RememberMe = [CPCheckBox checkBoxWithTitle:"Remember Me"];
        [m_RememberMe setFrameOrigin:CGPointMake(rightAlign + 5, 100)];
        [m_RememberMe sizeToFit];
        [m_RememberMe setState:CPOnState];

        m_LoginButton = [CPButton buttonWithTitle:"Login"];
        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];

        [m_LoginButton setTarget:self];
        [m_LoginButton setAction:@selector(onLoginButtonPressed:)];

        [m_CancelButton setTarget:self];
        [m_CancelButton setAction:@selector(onCancelButtonPressed:)];

        [m_LoginButton sizeToFit];
        [m_CancelButton sizeToFit];

        [m_CancelButton setFrame:CGRectMake(rightAlign + 5, 130, 70, CGRectGetHeight([m_CancelButton bounds]))];
        [m_LoginButton setFrame:CGRectMake(rightAlign + 95, 130, 100, CGRectGetHeight([m_LoginButton bounds]))];

        contentView = [self contentView];
        
        [contentView addSubview:m_UsernameLabel];
        [contentView addSubview:m_PasswordLabel];
        [contentView addSubview:m_Username];
        [contentView addSubview:m_Password];
        [contentView addSubview:m_RememberMe];
        [contentView addSubview:m_LoginButton];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_ErrorMessage];

        [self setDefaultButton:m_LoginButton];
        [self setTitle:"Login"];
    }

    return self;
}

- (CPString)username
{
    return [m_Username objectValue];
}

- (CPString)password
{
    return [m_Password objectValue];
}

- (BOOL)rememberUser
{
    return ([m_RememberMe state] == CPOnState);
}

- (void)onLoginButtonPressed:(id)sender
{
    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onLoginPanelFinished:)])
        [m_Delegate onLoginPanelFinished:self];
}

- (void)onCancelButtonPressed:(id)sender
{
    [self close];
}

- (void)loginFailed
{
    [self _setErrorMessageText:GenericLoginErrorMessage];
}

- (void)authenticationFailed
{
    [self _setErrorMessageText:InvalidAuthLoginErrorMessage];
    [m_Password selectText:self];
}

/* @ignore */
- (void)_setErrorMessageText:(CPString)anErrorMessage
{
    [m_LoginButton setTitle:"Try Again"];

    [self setFrameSize:CGSizeMake(370, 250)];

    if([m_ErrorMessage isHidden])
    {
        [m_ErrorMessage setHidden:NO];
        [m_ErrorMessage setObjectValue:anErrorMessage];

        [m_UsernameLabel setFrameOrigin:CGPointMake([m_UsernameLabel frameOrigin].x, [m_UsernameLabel frameOrigin].y + 50)];
        [m_PasswordLabel setFrameOrigin:CGPointMake([m_PasswordLabel frameOrigin].x, [m_PasswordLabel frameOrigin].y + 50)];
        [m_Username setFrameOrigin:CGPointMake([m_Username frameOrigin].x, [m_Username frameOrigin].y + 50)];
        [m_Password setFrameOrigin:CGPointMake([m_Password frameOrigin].x, [m_Password frameOrigin].y + 50)];
        [m_RememberMe setFrameOrigin:CGPointMake([m_RememberMe frameOrigin].x, [m_RememberMe frameOrigin].y + 50)];

        [m_LoginButton setFrameOrigin:CGPointMake([m_LoginButton frameOrigin].x, [m_LoginButton frameOrigin].y + 50)];
        [m_CancelButton setFrameOrigin:CGPointMake([m_CancelButton frameOrigin].x, [m_CancelButton frameOrigin].y + 50)];
    }
}

@end