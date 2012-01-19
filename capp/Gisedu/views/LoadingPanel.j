@import <Foundation/CPObject.j>

@implementation LoadingPanel : CPPanel
{
    CPImageView m_SpinnerView;
    CPTextField m_Status;
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(0,0,300,150) 
                styleMask:CPBorderlessWindowMask | CPTitledWindowMask];

    if(self)
    {
        [self setTitle:"Loading..."];
        [self center];
        [self setBackgroundColor:[CPColor whiteColor]];

        m_Status = [CPTextField labelWithTitle:"Loading Maps... please wait."];
        [m_Status setFrameOrigin:CGPointMake(10, 120)];
        [m_Status sizeToFit];

        m_SpinnerView = [[CPImageView alloc] initWithFrame:CGRectMake(126, 41, 48, 48)];

        var mainBundle = [CPBundle mainBundle];
        var img = [[CPImage alloc] initWithContentsOfFile:[mainBundle 
                                            pathForResource:@"spinner_lrg.gif"] 
                                    size:CPSizeMake(48, 48)];

        [m_SpinnerView setImage:img];

        contentView = [self contentView];
        [contentView addSubview:m_SpinnerView];
        [contentView addSubview:m_Status];
    }

    return self;
}

- (void)showWithStatus:(CPString)status
{
    [m_Status setObjectValue:status];
    [self orderFront:self];
}

- (void)setStatus:(CPString)status
{
    [m_Status setObjectValue:status];
    [m_Status display];
}

@end
