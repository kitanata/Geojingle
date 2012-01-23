@import <Foundation/CPObject.j>

@implementation CsvPolygonInsertView : CPView
{
    CPTextField m_ItemNameLabel;
    CPTextField m_ItemTypeLabel;
    CPTextField m_GeometryLabel;

    CPPopUpButton m_ItemNamePopUp;
    CPPopUpButton m_ItemTypePopUp;
    CPPopUpButton m_GeometryPopUp;

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

        m_AssignedColumns = [CPDictionary dictionary];

        m_ItemNameLabel = [self createLabelWithTitle:"Item Name" yOrg:0];
        m_ItemNamePopUp = [self createPopUpButton:[CPArray array] yOrg:0 action:@selector(onPopUpColumnSelected:)];

        m_ItemTypeLabel = [self createLabelWithTitle:"Item Type" yOrg:35];
        m_ItemTypePopUp = [self createPopUpButton:["None"] yOrg:35 action:@selector(onPopUpColumnSelected:)];

        m_GeometryLabel = [self createLabelWithTitle:"Geometry" yOrg:70];
        m_GeometryPopUp = [self createPopUpButton:[CPArray array] yOrg:70 action:@selector(onPopUpColumnSelected:)];

        [m_ItemTypePopUp addItemWithTitle:"None"];

        [self addSubview:m_ItemNameLabel];
        [self addSubview:m_ItemTypeLabel];
        [self addSubview:m_GeometryLabel];

        [self addSubview:m_ItemNamePopUp];
        [self addSubview:m_ItemTypePopUp];
        [self addSubview:m_GeometryPopUp];
    }

    return self;
}

- (CPString)itemNameColumnName
{
    return [m_ItemNamePopUp titleOfSelectedItem];
}

- (CPString)itemTypeColumnName
{
    return [m_ItemTypePopUp titleOfSelectedItem];
}

- (CPString)geometryColumnName
{
    return [m_GeometryPopUp titleOfSelectedItem];
}

- (id)createLabelWithTitle:(CPString)title yOrg:(CPInteger)yOrg
{
    var newLabel = [CPTextField labelWithTitle:title];
    [newLabel setFrameOrigin:CGPointMake(m_LabelsLeft, yOrg)];
    [newLabel sizeToFit];

    return newLabel;
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

- (void)onPopUpColumnSelected:(id)sender
{
    var popUps = [m_ItemNamePopUp, m_ItemTypePopUp, m_GeometryPopUp];

    var prevSelectedColumn = [m_AssignedColumns objectForKey:sender];
    var selectedColumn = nil;

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(columnWithTitle:)])
        selectedColumn = [m_Delegate columnWithTitle:[sender titleOfSelectedItem]];

    if(selectedColumn != prevSelectedColumn)
    {
        if(prevSelectedColumn && m_Delegate && [m_Delegate respondsToSelector:@selector(onColumnUnassigned:inPanel:)])
            [m_Delegate onColumnUnassigned:prevSelectedColumn inPanel:self];

        var assignedColumnTitles = [m_AssignedColumns allValues];

        if(selectedColumn && m_Delegate && [m_Delegate respondsToSelector:@selector(onColumnAssigned:inPanel:)])
            [m_Delegate onColumnAssigned:selectedColumn inPanel:self];

        [m_AssignedColumns setObject:selectedColumn forKey:sender];
    }
}

- (void)addColumnToColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_ItemNamePopUp addItemWithTitle:tableColTitle];
    [m_GeometryPopUp addItemWithTitle:tableColTitle];
    [m_ItemTypePopUp addItemWithTitle:tableColTitle];
}

- (void)removeColumnFromColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_ItemNamePopUp removeItemWithTitle:tableColTitle];
    [m_GeometryPopUp removeItemWithTitle:tableColTitle];
    [m_ItemTypePopUp removeItemWithTitle:tableColTitle];
}

- (void)initColumnPopUps:(CPArray)csvColumns
{
    [m_ItemNamePopUp removeAllItems];
    [m_ItemTypePopUp removeAllItems];
    [m_GeometryPopUp removeAllItems];

    [m_ItemNamePopUp addItemsWithTitles:csvColumns];
    [m_GeometryPopUp addItemsWithTitles:csvColumns];

    [csvColumns insertObject:"None" atIndex:0];

    [m_ItemTypePopUp addItemsWithTitles:csvColumns];
}

- (void)updateAttributePopUps:(CPArray)attributes
{
}

- (BOOL)validateColumnAssignments
{
    var popUps = [m_ItemNamePopUp, m_ItemTypePopUp, m_GeometryPopUp];

    var assignedCols = []

    for(var i=0; i < popUps.length; i++)
    {
        var cur = [popUps[i] titleOfSelectedItem];

        if(cur == "")
            return NO;
            
        if([cur uppercaseString] != "NONE")
        {
            if(assignedCols.indexOf(cur) == -1)
                assignedCols.push(cur)
            else
                return NO;
        }
    }

    return YES;
}

@end