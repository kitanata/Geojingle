@import <AppKit/CPPanel.j>

var GenericRegisterErrorMessage = @"Something went wrong. Check your internet connection and try again.";
var InvalidAuthLoginErrorMessage = @"Incorrect username or password. Please try again.";
var UsernameTakenErrorMessage = "That username has been taken. Please choose another.";

@implementation AKRegisterPanel : CPPanel
{
    CPTextField m_UsernameLabel;
    CPTextField m_PasswordLabel;
    CPTextField m_PasswordConfirmLabel;
    CPTextField m_EmailLabel;

    CPTextField m_Username;
    CPTextField m_Password;
    CPTextField m_PasswordConfirm;
    CPTextField m_Email;

    CPImageView m_UserCheckSpinner;
    CPTextField m_ErrorMessage;

    CPButton m_RegisterButton;
    CPButton m_CancelButton;

    CPCheckBox m_RememberMe;

    id m_Delegate   @accessors(property=delegate);
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(150,150,370,270) styleMask:CPClosableWindowMask];

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
        m_PasswordConfirmLabel = [CPTextField labelWithTitle:"Confirm: "];
        m_EmailLabel = [CPTextField labelWithTitle:"Email: "];

        m_Username = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        m_Password = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        m_PasswordConfirm = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        m_Email = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:200];
        [m_Username setDelegate:self];
        [m_Password setSecure:YES];
        [m_PasswordConfirm setSecure:YES];

        [m_UsernameLabel setFrameOrigin:CGPointMake(40, 25)];
        [m_PasswordLabel setFrameOrigin:CGPointMake(40, 65)];
        [m_PasswordConfirmLabel setFrameOrigin:CGPointMake(40, 105)];
        [m_EmailLabel setFrameOrigin:CGPointMake(40, 145)];

        var spinner = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"spinner.gif"] size:CPSizeMake(16, 16)];
        m_UserCheckSpinner = [[CPImageView alloc] initWithFrame:CGRectMake(20, 25, 16, 16)];
        [m_UserCheckSpinner setImage:spinner];
        [m_UserCheckSpinner setHidden:YES];

        [m_UsernameLabel sizeToFit];
        [m_PasswordLabel sizeToFit];
        [m_PasswordConfirmLabel sizeToFit];
        [m_EmailLabel sizeToFit];

        var rightAlign = Math.max(CGRectGetWidth([m_UsernameLabel bounds]), CGRectGetWidth([m_PasswordLabel bounds])) + 60;

        [m_Username setFrameOrigin:CGPointMake(rightAlign, 20)];
        [m_Password setFrameOrigin:CGPointMake(rightAlign, 60)];
        [m_PasswordConfirm setFrameOrigin:CGPointMake(rightAlign, 100)];
        [m_Email setFrameOrigin:CGPointMake(rightAlign, 140)];

        m_RememberMe = [CPCheckBox checkBoxWithTitle:"Remember Me"];
        [m_RememberMe setFrameOrigin:CGPointMake(rightAlign + 5, 185)];
        [m_RememberMe sizeToFit];
        [m_RememberMe setState:CPOnState];

        m_RegisterButton = [CPButton buttonWithTitle:"Register"];
        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];

        [m_RegisterButton setTarget:self];
        [m_RegisterButton setAction:@selector(onRegisterButtonPressed:)];

        [m_CancelButton setTarget:self];
        [m_CancelButton setAction:@selector(onCancelButtonPressed:)];

        [m_RegisterButton sizeToFit];
        [m_CancelButton sizeToFit];

        [m_CancelButton setFrame:CGRectMake(rightAlign + 5, 220, 70, CGRectGetHeight([m_CancelButton bounds]))];
        [m_RegisterButton setFrame:CGRectMake(rightAlign + 95, 220, 100, CGRectGetHeight([m_RegisterButton bounds]))];

        contentView = [self contentView];
        
        [contentView addSubview:m_UsernameLabel];
        [contentView addSubview:m_PasswordLabel];
        [contentView addSubview:m_PasswordConfirmLabel];
        [contentView addSubview:m_EmailLabel];
        [contentView addSubview:m_UserCheckSpinner];

        [contentView addSubview:m_Username];
        [contentView addSubview:m_Password];
        [contentView addSubview:m_PasswordConfirm];
        [contentView addSubview:m_Email];
        [contentView addSubview:m_RememberMe];

        [contentView addSubview:m_RegisterButton];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_ErrorMessage];

        [self setDefaultButton:m_RegisterButton];
        [self setTitle:"Register"];
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

- (CPString)email
{
    return [m_Email objectValue];
}

- (BOOL)rememberUser
{
    return ([m_RememberMe state] == CPOnState);
}

- (void)onRegisterButtonPressed:(id)sender
{
    errorMessage = [self validateRegistration];
    if(errorMessage)
        [self setErrorMessageText:errorMessage];
    else
    {
        [self hideErrorMessage];

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onRegisterPanelFinished:)])
            [m_Delegate onRegisterPanelFinished:self];
    }
}

- (void)onCancelButtonPressed:(id)sender
{
    [self close];
}

- (void)registerFailed
{
    [self setErrorMessageText:GenericRegisterErrorMessage];
}

- (void)checkUsernameFailed
{
    [m_UserCheckSpinner setHidden:YES];
    [self setErrorMessageText:UsernameTakenErrorMessage];
}

- (void)checkUsernameSuccessful
{
    [m_UserCheckSpinner setHidden:YES];
    [self hideErrorMessage];
}

- (void)authenticationFailed
{
    [self setErrorMessageText:InvalidAuthLoginErrorMessage];
    [m_Password selectText:self];
}

- (void)controlTextDidChange:(id)sender
{
    //Activate Spinner - Do Username Check
    [m_UserCheckSpinner setHidden:NO];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onCheckUsername:)])
        [m_Delegate onCheckUsername:self];
}

/* @ignore */
- (void)setErrorMessageText:(CPString)anErrorMessage
{
    [m_RegisterButton setTitle:"Try Again"];
    [m_ErrorMessage setObjectValue:anErrorMessage];

    if([m_ErrorMessage isHidden])
    {
        [self setFrameSize:CGSizeMake(370, 350)];

        [m_ErrorMessage setHidden:NO];

        [m_UsernameLabel setFrameOrigin:CGPointMake([m_UsernameLabel frameOrigin].x, [m_UsernameLabel frameOrigin].y + 50)];
        [m_PasswordLabel setFrameOrigin:CGPointMake([m_PasswordLabel frameOrigin].x, [m_PasswordLabel frameOrigin].y + 50)];
        [m_PasswordConfirmLabel setFrameOrigin:CGPointMake([m_PasswordConfirmLabel frameOrigin].x, [m_PasswordConfirmLabel frameOrigin].y + 50)];
        [m_EmailLabel setFrameOrigin:CGPointMake([m_EmailLabel frameOrigin].x, [m_EmailLabel frameOrigin].y + 50)];

        [m_Username setFrameOrigin:CGPointMake([m_Username frameOrigin].x, [m_Username frameOrigin].y + 50)];
        [m_Password setFrameOrigin:CGPointMake([m_Password frameOrigin].x, [m_Password frameOrigin].y + 50)];
        [m_PasswordConfirm setFrameOrigin:CGPointMake([m_PasswordConfirm frameOrigin].x, [m_PasswordConfirm frameOrigin].y + 50)];
        [m_Email setFrameOrigin:CGPointMake([m_Email frameOrigin].x, [m_Email frameOrigin].y + 50)];
        [m_RememberMe setFrameOrigin:CGPointMake([m_RememberMe frameOrigin].x, [m_RememberMe frameOrigin].y + 50)];

        [m_RegisterButton setFrameOrigin:CGPointMake([m_RegisterButton frameOrigin].x, [m_RegisterButton frameOrigin].y + 50)];
        [m_CancelButton setFrameOrigin:CGPointMake([m_CancelButton frameOrigin].x, [m_CancelButton frameOrigin].y + 50)];
    }
}

- (void)hideErrorMessage
{
    if(![m_ErrorMessage isHidden])
    {
        [self setFrameSize:CGSizeMake(370, 300)];
        [m_ErrorMessage setHidden:YES];

        [m_UsernameLabel setFrameOrigin:CGPointMake([m_UsernameLabel frameOrigin].x, [m_UsernameLabel frameOrigin].y - 50)];
        [m_PasswordLabel setFrameOrigin:CGPointMake([m_PasswordLabel frameOrigin].x, [m_PasswordLabel frameOrigin].y - 50)];
        [m_PasswordConfirmLabel setFrameOrigin:CGPointMake([m_PasswordConfirmLabel frameOrigin].x, [m_PasswordConfirmLabel frameOrigin].y - 50)];
        [m_EmailLabel setFrameOrigin:CGPointMake([m_EmailLabel frameOrigin].x, [m_EmailLabel frameOrigin].y - 50)];

        [m_Username setFrameOrigin:CGPointMake([m_Username frameOrigin].x, [m_Username frameOrigin].y - 50)];
        [m_Password setFrameOrigin:CGPointMake([m_Password frameOrigin].x, [m_Password frameOrigin].y - 50)];
        [m_PasswordConfirm setFrameOrigin:CGPointMake([m_PasswordConfirm frameOrigin].x, [m_PasswordConfirm frameOrigin].y - 50)];
        [m_Email setFrameOrigin:CGPointMake([m_Email frameOrigin].x, [m_Email frameOrigin].y - 50)];
        [m_RememberMe setFrameOrigin:CGPointMake([m_RememberMe frameOrigin].x, [m_RememberMe frameOrigin].y - 50)];

        [m_RegisterButton setFrameOrigin:CGPointMake([m_RegisterButton frameOrigin].x, [m_RegisterButton frameOrigin].y - 50)];
        [m_CancelButton setFrameOrigin:CGPointMake([m_CancelButton frameOrigin].x, [m_CancelButton frameOrigin].y - 50)];
    }
}

- (CPString)validateRegistration
{
    var username = [m_Username objectValue];
    var password = [m_Password objectValue];
    var confirmPassword = [m_PasswordConfirm objectValue];
    var email = [m_Email objectValue];

    var reEmail = new RegExp("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\\b");

    if (!username || username == "")
        return "Your username cannot be blank.";
    else if (!password || password == "" || password == "blank")//So funny.
        return "Your password cannot be blank.";
    else if ([password length] < 8)
        return "Your password must be at least 8 characters long.";
    else if (password != confirmPassword)
        return "Your password doesn't match it's confirmation.";
    else if(!email || email == "")
        return "Your email cannot be blank.";
    else if(email.match(reEmail) == null)
        return "The email address you entered does not appear to be valid.";
    
    return nil;
}

@end