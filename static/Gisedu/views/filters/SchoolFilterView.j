@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"

@implementation SchoolFilterView : CPControl
{
    OverlayManager m_OverlayManager;
    
    CPPopUpButton m_SchoolType;

    CPButton m_UpdateButton;

    SchoolFilter m_Filter @accessors(property=filter);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(SchoolFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        
        m_OverlayManager = [OverlayManager getInstance];

        m_SchoolType = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_SchoolType addItemWithTitle:"All"];

        schoolTypes = [[m_OverlayManager schoolTypes] allKeys];
        if([schoolTypes count] < 100)
            [m_SchoolType addItemsWithTitles:schoolTypes];

        orgTypeLabel = [CPTextField labelWithTitle:"School Type"];
        [orgTypeLabel sizeToFit];
        [orgTypeLabel setFrameOrigin:CGPointMake(20, 0)];

        [m_SchoolType sizeToFit];
        [m_SchoolType setFrameOrigin:CGPointMake(20, 20)];
        [m_SchoolType setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SchoolType bounds]))];
        [m_SchoolType selectItemWithTitle:[m_Filter schoolType]];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 60)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [m_SchoolType selectItemWithTitle:[m_Filter schoolType]];

        [self addSubview:orgTypeLabel];
        [self addSubview:m_SchoolType];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setSchoolType:[m_SchoolType titleOfSelectedItem]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end