@import <Foundation/CPObject.j>

@implementation CsvUpdateView : CPView
{
    CPTextField m_JoinLabel;
    CPTextField m_JoinToLabel;

    CPPopUpButton m_JoinPopUp;
    CPPopUpButton m_JoinToPopUp;

    var m_LabelsLeft;
    var m_ButtonsLeft;

    CPDictionary m_AssignedColumns  @accessors(getter=assignedColumns);
    id m_Delegate                   @accessors(property=delegate);
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 110)];

    if(self)
    {
        m_LabelsLeft = 10;
        m_ButtonsLeft = m_LabelsLeft + 130;
        
        m_JoinLabel = [self createLabelWithTitle:"Join Column" yOrg:0];
        m_JoinPopUp = [self createPopUpButton:[CPArray array] yOrg:0 action:@selector(onColumnSelected:)];

        m_JoinToLabel = [self createLabelWithTitle:"To Attribute" yOrg:40];
        m_JoinToPopUp = [self createPopUpButton:[CPArray array] yOrg:35];

        [self addSubview:m_JoinLabel];
        [self addSubview:m_JoinPopUp];

        [self addSubview:m_JoinToLabel];
        [self addSubview:m_JoinToPopUp];
    }

    return self;
}

- (id)createLabelWithTitle:(CPString)title yOrg:(CPInteger)yOrg
{
    var newLabel = [CPTextField labelWithTitle:title];
    [newLabel setFrameOrigin:CGPointMake(m_LabelsLeft, yOrg)];
    [newLabel sizeToFit];

    return newLabel;
}

- (id)createPopUpButton:(CPArray)items yOrg:(CPInteger)yOrg
{
    return [self createPopUpButton:items yOrg:yOrg action:nil];
}

- (id)createPopUpButton:(CPArray)items yOrg:(CPInteger)yOrg action:(SEL)action
{
    var newPopUp = [[CPPopUpButton alloc] init];
    [newPopUp addItemsWithTitles:items];
    [newPopUp setFrameOrigin:CGPointMake(m_ButtonsLeft, yOrg)];
    [newPopUp sizeToFit];
    [newPopUp setFrameSize:CGSizeMake(136, CGRectGetHeight([newPopUp bounds]))];

    if(action)
    {
        [newPopUp setTarget:self];
        [newPopUp setAction:action];
    }

    return newPopUp;
}

- (void)onColumnSelected:(id)sender
{
    var curColumn = [m_AssignedColumns objectForKey:sender];
    var newColumn = curColumn;

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(columnWithTitle:)])
        newColumn = [m_Delegate columnWithTitle:[sender titleOfSelectedItem]];

    if(newColumn != curColumn)
    {
        if(curColumn && m_Delegate && [m_Delegate respondsToSelector:@selector(onColumnUnassigned:inPanel:)])
            [m_Delegate onColumnUnassigned:curColumn inPanel:self];

        if(newColumn && m_Delegate && [m_Delegate respondsToSelector:@selector(onColumnAssigned:inPanel:)])
            [m_Delegate onColumnAssigned:newColumn inPanel:self];

        [m_AssignedColumns setObject:curColumn forKey:sender];
    }
}

- (void)addColumnToColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_JoinPopUp addItemWithTitle:tableColTitle];
}

- (void)removeColumnFromColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_JoinPopUp removeItemWithTitle:tableColTitle];
}

- (void)initColumnPopUps:(CPArray)csvColumns
{
    [m_JoinPopUp removeAllItems];
    [m_JoinPopUp addItemsWithTitles:csvColumns];

    [self onColumnSelected:m_JoinPopUp];
}

- (void)updateAttributePopUps:(CPArray)attributes
{
    [m_JoinToPopUp removeAllItems];
    [m_JoinToPopUp addItemsWithTitles:attributes];
}

@end