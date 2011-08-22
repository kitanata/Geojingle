@import <Foundation/CPObject.j>

@implementation FKFilePanel : CPPanel
{
    CPScrollView m_ScrollView;
    CPTableView m_TableView;

    CPTableColumn m_FileNameCol;
    CPTableColumn m_FileDateCol;

    BOOL m_bSaveDialogMode      @accessors(property=mode); //YES for Save NO for Open
    CPTextField m_SelectedFilename;
    CPButton m_CancelButton;
    CPButton m_OpenSaveButton   @accessors(property=openSaveButton);

    CPDictionary m_FileMap; //name:date

    id m_Delegate               @accessors(property=delegate);
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(150,150,450,300) styleMask:CPClosableWindowMask];

    if(self)
    {
        var contentView = [self contentView];

        m_ScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([contentView bounds]), CGRectGetHeight([contentView bounds]) - 50)];
        [m_ScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
        [contentView addSubview:m_ScrollView];

        m_TableView = [[CPTableView alloc] initWithFrame:CGRectMake(0, 0, 280, CGRectGetHeight([m_ScrollView bounds]))];
        [m_ScrollView setDocumentView:m_TableView];

        [m_TableView setCornerView:nil];

        m_FileNameCol = [[CPTableColumn alloc] initWithIdentifier:@"FileName"];
        [m_FileNameCol setWidth:280];
        [[m_FileNameCol headerView] setStringValue:"Project Name"];
        [m_TableView addTableColumn:m_FileNameCol];

        m_FileDateCol = [[CPTableColumn alloc] initWithIdentifier:@"FileDate"];
        [m_FileDateCol setWidth:148];
        [[m_FileDateCol headerView] setStringValue:"Date Last Modified"];
        [m_TableView addTableColumn:m_FileDateCol];

        [m_TableView setAction:@selector(onTableItemSelected:)];
        [m_TableView setTarget:self];

        [m_TableView setDataSource:self];

        m_SelectedFilename = [CPTextField roundedTextFieldWithStringValue:"" placeholder:"" width:280];
        [m_SelectedFilename sizeToFit];
        [m_SelectedFilename setFrameOrigin:CGPointMake(0, 260)];

        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];
        m_OpenSaveButton = [CPButton buttonWithTitle:"Open / Save"];

        [m_CancelButton sizeToFit];
        [m_OpenSaveButton sizeToFit];

        [m_CancelButton setFrameOrigin:CGPointMake(290, 263)];
        [m_OpenSaveButton setFrameOrigin:CGPointMake(360, 263)];

        [m_CancelButton setAction:@selector(onCancelButton:)];
        [m_CancelButton setTarget:self];
        [m_OpenSaveButton setAction:@selector(onOpenSaveButton:)];
        [m_OpenSaveButton setTarget:self];

        [contentView addSubview:m_SelectedFilename];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_OpenSaveButton];
    }

    return self;
}

- (CPString)fileName
{
    return [m_SelectedFilename objectValue];
}

- (void)setFileMap:(CPDictionary)fileMap
{
    m_FileMap = fileMap;
    [m_TableView reloadData];
}

// this tell the table how many rows it has…
- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    console.log("FileMaps count is " + [m_FileMap count]);
    return [m_FileMap count];
}

// this defines what text will display for each row, in each column, for each table view.
- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRow
{
    fileNames = [m_FileMap allKeys];

    if(aRow > [m_FileMap count] || aRow < 0)
        return "";
    else if(aTableColumn == m_FileNameCol)
        return [fileNames objectAtIndex:aRow];
    else if(aTableColumn == m_FileDateCol)
        return [m_FileMap objectForKey:[fileNames objectAtIndex:aRow]]; 
}

- (void)onTableItemSelected:(id)sender
{
    var curProjectName = [self tableView:m_TableView objectValueForTableColumn:m_FileNameCol row:[m_TableView selectedRow]];

    [m_SelectedFilename setObjectValue:curProjectName];
}

- (void)onCancelButton:(id)sender
{
    [self close];
}

- (void)onOpenSaveButton:(id)sender
{
    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilePanelFinished:)])
        [m_Delegate onFilePanelFinished:self];

    [self close];
}

+ (id)openPanelWithProjectList:(CPDictionary)fileMap
{
    var newPanel = [[FKFilePanel alloc] init];
    
    [newPanel setFloatingPanel:YES];
    [newPanel setTitle:"Open Project"];
    [newPanel setBackgroundColor:[CPColor whiteColor]];
    [newPanel setFileMap:fileMap];
    [[newPanel openSaveButton] setTitle:"Open"];
    [newPanel setMode:NO];

    return newPanel;
}

+ (id)savePanelWithProjectList:(CPDictionary)fileMap
{
    var newPanel = [[FKFilePanel alloc] init];

    [newPanel setFloatingPanel:YES];
    [newPanel setTitle:"Save Project As"];
    [newPanel setBackgroundColor:[CPColor whiteColor]];
    [newPanel setFileMap:fileMap];
    [[newPanel openSaveButton] setTitle:"Save"];
    [newPanel setMode:YES];

    return newPanel;
}

@end