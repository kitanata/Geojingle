@import <Foundation/CPObject.j>

@import "FKUploadButton.j"
@import "CsvUpdateView.j"
@import "CsvPointInsertView.j"
@import "CsvPolygonInsertView.j"
@import "../FilterManager.j"

@implementation CsvImportPanel : CPPanel
{
    FilterManager m_FilterManager;

    CPScrollView m_TableScrollView;
    CPTableView m_TableView;
    CPMenu m_ContextMenu;

    CPDictionary m_TableColumns;
    CPDictionary m_AttributeMatches;
    CPArray m_UnassignedTableColumns;
    
    FKUploadButton m_UploadButton;
    CPTextField m_UploadLabel;

    CPTextField m_GeometryTypeLabel;
    CPTextField m_FilterTypeLabel;
    CPTextField m_OperationTypeLabel;

    CPPopUpButton m_GeometryTypePopUp;
    CPPopUpButton m_FilterTypePopUp;
    CPPopUpButton m_OperationTypePopUp;

    CPScrollView m_ImportOptionsScrollView;
    CsvUpdateView m_UpdateOptionsView;
    CsvPointInsertView m_PointInsertOptionsView;
    CsvPolygonInsertView m_PolygonInsertOptionsView;

    CPTextField m_MatchLabel;
    CPTextField m_MatchToLabel;
    
    CPPopUpButton m_MatchPopUp;
    CPPopUpButton m_MatchToPopUp;

    CPButton m_MatchAddButton;
    CPButton m_MatchRemoveButton;

    CPScrollView m_MatchTableScrollView;
    CPTableView m_MatchTableView;

    CPTableColumn m_ColumnTableColumn;
    CPTableColumn m_AttributeTableColumn;

    CPButton m_CancelButton;
    CPButton m_ImportButton;

    var m_LabelsLeft;
    var m_ButtonsLeft;
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(150,150,900,700) styleMask:CPClosableWindowMask];

    if(self)
    {
        m_FilterManager = [FilterManager getInstance];
        var contentView = [self contentView];

        // BEGIN THE MAIN TABLE

        m_TableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([contentView bounds]) - 300, CGRectGetHeight([contentView bounds]))];
        [m_TableScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_TableView = [[CPTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([m_TableScrollView bounds]), CGRectGetHeight([m_TableScrollView bounds]))];
        [m_TableScrollView setDocumentView:m_TableView];

        [m_TableView setCornerView:nil];
        [m_TableView setDataSource:self];
        [m_TableView setDelegate:self];
        [m_TableView setGridColor:[CPColor grayColor]];
        [m_TableView setGridStyleMask:CPTableViewSolidVerticalGridLineMask];
        [m_TableView setUsesAlternatingRowBackgroundColors:YES];

        m_ContextMenu = [[CPMenu alloc] initWithTitle:"table_context_menu"];
            var duplicateRowItem = [[CPMenuItem alloc] initWithTitle:@"Duplicate Row" action:@selector(onDuplicateRow:) keyEquivalent:@"D"];

            var insertRowItem = [[CPMenuItem alloc] initWithTitle:@"Insert Row" action:@selector(onInsertRow:) keyEquivalent:@"iR"];
            var insertColItem = [[CPMenuItem alloc] initWithTitle:@"Insert Column NYI" action:@selector(onInsertCol:) keyEquivalent:@"iC"];

            var deleteRowItem = [[CPMenuItem alloc] initWithTitle:@"Delete Row" action:@selector(onDeleteRow:) keyEquivalent:@"dR"];
            var deleteColItem = [[CPMenuItem alloc] initWithTitle:@"Delete Column NYI" action:@selector(onDeleteCol:) keyEquivalent:@"dC"];

            [m_ContextMenu addItem:duplicateRowItem];
            [m_ContextMenu addItem:[CPMenuItem separatorItem]];
            [m_ContextMenu addItem:insertRowItem];
            [m_ContextMenu addItem:insertColItem];
            [m_ContextMenu addItem:[CPMenuItem separatorItem]];
            [m_ContextMenu addItem:deleteRowItem];
            [m_ContextMenu addItem:deleteColItem];
        // END THE MAIN TABLE

        m_LabelsLeft = CGRectGetWidth([contentView bounds]) - 290;
        m_ButtonsLeft = m_LabelsLeft + 130;

        m_UploadLabel = [self createLabelWithTitle:"No CSV File Opened" yOrg:28];

        m_UploadButton = [[FKUploadButton alloc] initWithFrame:CGRectMake(m_ButtonsLeft, 25, 60, 20)];
        [m_UploadButton setTitle:"Open CSV File"];
        [m_UploadButton setBordered:YES];
        [m_UploadButton sizeToFit];
        [m_UploadButton setFrameSize:CGSizeMake(136, CGRectGetHeight([m_UploadButton bounds]))];
        [m_UploadButton allowsMultipleFiles:NO];
        [m_UploadButton setURL:"/upload_csv"];
        [m_UploadButton setDelegate:self];

        m_GeometryTypeLabel = [self createLabelWithTitle:"Geometry Type" yOrg:68];
        m_GeometryTypePopUp = [self createPopUpButton:["Point", "Polygon"] yOrg:65 action:@selector(onGeometryTypeChanged:)];

        m_FilterTypeLabel = [self createLabelWithTitle:"Filter Type" yOrg:103];
        m_FilterTypePopUp = [self createPopUpButton:[CPArray array] yOrg:100 action:@selector(onFilterTypeChanged:)];

        m_OperationTypeLabel = [self createLabelWithTitle:"Operation Type" yOrg:138];
        m_OperationTypePopUp = [self createPopUpButton:["Update", "Insert"] yOrg:135 action:@selector(onOperationTypeChanged:)];

        m_ImportOptionsScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth([contentView bounds]) - 300, 180, 300, 160)];
        [m_ImportOptionsScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_UpdateOptionsView = [[CsvUpdateView alloc] init];
        m_PointInsertOptionsView = [[CsvPointInsertView alloc] init];
        m_PolygonInsertOptionsView = [[CsvPolygonInsertView alloc] init];
        [m_UpdateOptionsView setDelegate:self];
        [m_PointInsertOptionsView setDelegate:self];
        [m_PolygonInsertOptionsView setDelegate:self];
        
        [m_ImportOptionsScrollView setDocumentView:m_UpdateOptionsView];

        m_MatchLabel = [self createLabelWithTitle:"Set Column" yOrg:378];
        m_MatchPopUp = [self createPopUpButton:[CPArray array] yOrg:375];

        m_MatchToLabel = [self createLabelWithTitle:"To Match Attribute" yOrg:413];
        m_MatchToPopUp = [self createPopUpButton:[CPArray array] yOrg:410];

        m_MatchRemoveButton = [CPButton buttonWithTitle:"Remove Match"];
        [m_MatchRemoveButton setFrameOrigin:CGPointMake(m_LabelsLeft, 445)];
        [m_MatchRemoveButton sizeToFit];
        [m_MatchRemoveButton setFrameSize:CGSizeMake(116, CGRectGetHeight([m_MatchRemoveButton bounds]))];
        [m_MatchRemoveButton setTarget:self];
        [m_MatchRemoveButton setAction:@selector(onRemoveMatchButton:)];

        m_MatchAddButton = [CPButton buttonWithTitle:"Add Match"];
        [m_MatchAddButton setFrameOrigin:CGPointMake(m_ButtonsLeft, 445)];
        [m_MatchAddButton sizeToFit];
        [m_MatchAddButton setFrameSize:CGSizeMake(136, CGRectGetHeight([m_MatchAddButton bounds]))];
        [m_MatchAddButton setTarget:self];
        [m_MatchAddButton setAction:@selector(onAddMatchButton:)];

        m_MatchTableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth([contentView bounds]) - 300, 490, 300, 150)];
        [m_MatchTableScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_MatchTableView = [[CPTableView alloc] initWithFrame:CGRectMake(10, 0,
            CGRectGetWidth([m_MatchTableScrollView bounds]) - 10, CGRectGetHeight([m_MatchTableScrollView bounds]))];
        [m_MatchTableScrollView setDocumentView:m_MatchTableView];

        [m_MatchTableView setCornerView:nil];
        [m_MatchTableView setDataSource:self];
        [m_MatchTableView setDelegate:self];
        [m_MatchTableView setGridColor:[CPColor grayColor]];
        [m_MatchTableView setGridStyleMask:CPTableViewSolidVerticalGridLineMask];
        [m_MatchTableView setUsesAlternatingRowBackgroundColors:YES];
        [[m_MatchTableView headerView] setFrameOrigin:CGPointMake(10, 0)];

        m_ColumnTableColumn = [self createTableColumnForTable:m_MatchTableView
            identifier:"column_table_column" title:"CSV Column" width:127];

        m_AttributeTableColumn = [self createTableColumnForTable:m_MatchTableView
            identifier:"attribute_table_column" title:"Match Attribute" width:140];

        m_AttributeMatches = [CPDictionary dictionary];
        [m_AttributeMatches setObject:[CPArray array] forKey:m_ColumnTableColumn];
        [m_AttributeMatches setObject:[CPArray array] forKey:m_AttributeTableColumn];

        m_UnassignedTableColumns = [CPArray array];

        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];
        [m_CancelButton setFrameOrigin:CGPointMake(m_LabelsLeft, 660)];
        [m_CancelButton sizeToFit];
        [m_CancelButton setFrameSize:CGSizeMake(126, CGRectGetHeight([m_CancelButton bounds]))];
        [m_CancelButton setTarget:self];
        [m_CancelButton setAction:@selector(onCancelButton:)];

        m_ImportButton = [CPButton buttonWithTitle:"Import Data"];
        [m_ImportButton setFrameOrigin:CGPointMake(m_ButtonsLeft + 10, 660)];
        [m_ImportButton sizeToFit];
        [m_ImportButton setFrameSize:CGSizeMake(126, CGRectGetHeight([m_ImportButton bounds]))];

        [contentView addSubview:m_UploadButton];
        [contentView addSubview:m_UploadLabel];
        [contentView addSubview:m_TableScrollView];

        [contentView addSubview:m_GeometryTypeLabel];
        [contentView addSubview:m_FilterTypeLabel];
        [contentView addSubview:m_OperationTypeLabel];

        [contentView addSubview:m_GeometryTypePopUp];
        [contentView addSubview:m_FilterTypePopUp];
        [contentView addSubview:m_OperationTypePopUp];

        [contentView addSubview:m_ImportOptionsScrollView];

        [contentView addSubview:m_MatchLabel];
        [contentView addSubview:m_MatchToLabel];

        [contentView addSubview:m_MatchPopUp];
        [contentView addSubview:m_MatchToPopUp];
        [contentView addSubview:m_MatchRemoveButton];
        [contentView addSubview:m_MatchAddButton];

        [contentView addSubview:m_MatchTableScrollView];

        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_ImportButton];

        [self center];

        [self updateFilterTypePopUp];

        [self updateOptionAttributePopUps];
    }

    return self;
}

- (CPTextField)createLabelWithTitle:(CPString)title yOrg:(CPInteger)yOrg
{
    var newLabel = [CPTextField labelWithTitle:title];
    [newLabel setFrameOrigin:CGPointMake(m_LabelsLeft, yOrg)];
    [newLabel sizeToFit];

    return newLabel;
}

- (CPPopUpButton)createPopUpButton:(CPArray)item yOrg:(CPInteger)yOrg action:(SEL)action
{
    var newPopUp = [self createPopUpButton:item yOrg:yOrg];

    [newPopUp setTarget:self];
    [newPopUp setAction:action];
        
    return newPopUp;
}

- (CPPopUpButton)createPopUpButton:(CPArray)items yOrg:(CPInteger)yOrg
{
    var newPopUp = [[CPPopUpButton alloc] init];
    [newPopUp addItemsWithTitles:items];
    [newPopUp setFrameOrigin:CGPointMake(m_ButtonsLeft, yOrg)];
    [newPopUp sizeToFit];
    [newPopUp setFrameSize:CGSizeMake(136, CGRectGetHeight([newPopUp bounds]))];

    return newPopUp;
}

- (CPTableColumn)createTableColumnForTable:(CPTableView)tableView identifier:(CPInteger)identifier
    title:(CPString)title width:(CPInteger)width
{
    var newColumn = [[CPTableColumn alloc] initWithIdentifier:identifier];
    [newColumn setWidth:width];
    [newColumn setEditable:YES];
    [[newColumn headerView] setStringValue:title];
    [tableView addTableColumn:newColumn];

    return newColumn;
}

// this tell the table how many rows it has…
- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    var dataSource = nil;
    if(aTableView == m_TableView)
        dataSource = m_TableColumns;
    else if(aTableView == m_MatchTableView)
        dataSource = m_AttributeMatches;

    var mostRows = 0;
    var colRows = [dataSource allValues];

    for(var i=0; i < [colRows count]; i++)
    {
        if([[colRows objectAtIndex:i] count] > mostRows)
            mostRows = [[colRows objectAtIndex:i] count];
    }

    return mostRows;
}

// this defines what text will display for each row, in each column, for each table view.
- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRow
{
    if(aTableView == m_TableView)
        return [[m_TableColumns objectForKey:aTableColumn] objectAtIndex:aRow];
    else if(aTableView == m_MatchTableView)
        return [[m_AttributeMatches objectForKey:aTableColumn] objectAtIndex:aRow];

    return nil;
}

- (void)tableView:(CPTableView)aTableView setObjectValue:(CPControl)anObject forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
    if(aTableView == m_TableView)
        [[m_TableColumns objectForKey:aTableColumn] replaceObjectAtIndex:rowIndex withObject:anObject];
}

- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
    if(aTableView == m_TableView)
        return YES;

    return NO;
}

- (CPMenu)tableView:(CPTableView)aTableView menuForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    if(aTableView == m_TableView)
        return m_ContextMenu;

    return nil;
}

- (CPTableColumn)columnWithTitle:(CPString)columnTitle
{
    var tableCols = [m_TableColumns allKeys];

    for(var i=0; i < [tableCols count]; i++)
    {
        var curCol = [tableCols objectAtIndex:i];

        if([[curCol headerView] stringValue] == columnTitle)
            return curCol;
    }

    return nil;
}

- (void)onDuplicateRow:(id)sender
{
    var rowIndex = [m_TableView selectedRow];

    var tableColumns = [m_TableColumns allKeys];

    for(var i=0; i < [tableColumns count]; i++)
    {
        var curKey = [tableColumns objectAtIndex:i];
        var curRowList = [m_TableColumns objectForKey:curKey];
        var curData = [curRowList objectAtIndex:rowIndex];
        [curRowList insertObject:curData atIndex:rowIndex];
    }

    [m_TableView reloadData];
}

- (void)onInsertRow:(id)sender
{
    var rowIndex = [m_TableView selectedRow];

    var tableColumns = [m_TableColumns allValues];

    for(var i=0; i < [tableColumns count]; i++)
    {
        var curCol = [tableColumns objectAtIndex:i];
        [curCol insertObject:"" atIndex:rowIndex];
    }

    [m_TableView reloadData];
}

- (void)onInsertCol:(id)sender
{

}

- (void)onDeleteRow:(id)sender
{
    var rowIndex = [m_TableView selectedRow];

    var tableColumns = [m_TableColumns allValues];

    for(var i=0; i < [tableColumns count]; i++)
    {
        var curCol = [tableColumns objectAtIndex:i];
        [curCol removeObjectAtIndex:rowIndex];
    }

    [m_TableView reloadData];
}

- (void)onDeleteCol:(id)sender
{

}

-(void) uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
{
    [m_UploadLabel setObjectValue:"Viewing file: " + selection];

    [m_UploadButton submit];
}

-(void) uploadButton:(UploadButton)button didFailWithError:(CPString)anError
{
    console.log("Upload failed with this error: " + anError);
}

-(void) uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
{
    var jsonResponse = JSON.parse(response)

    var columnKeys = [m_TableColumns allKeys];
    for(var i=0; i < [columnKeys count]; i++)
    {
        [m_TableView removeTableColumn:[columnKeys objectAtIndex:i]];
    }

    [m_MatchPopUp removeAllItems];
    m_TableColumns = [CPDictionary dictionary];

    for(key in jsonResponse)
    {
        var newColumn = [self createTableColumnForTable:m_TableView identifier:key title:key width:120];

        var newRowArr = [CPArray arrayWithObjects:jsonResponse[key] count:jsonResponse[key].length];
        [m_TableColumns setObject:newRowArr forKey:newColumn];
        [m_UnassignedTableColumns addObject:newColumn];
    }

    [m_TableView reloadData];
    [m_UploadButton resetSelection];

    [self initColumnPopUps];
}

-(void) uploadButtonDidBeginUpload:(UploadButton)button
{
    console.log("Upload has begun with selection: " + [button selection]);
}

- (void)updateImportOptionsView
{
    var geomType = [[m_GeometryTypePopUp titleOfSelectedItem] uppercaseString];
    var operationType = [[m_OperationTypePopUp titleOfSelectedItem] uppercaseString];

    var oldAssignedCols = [[[m_ImportOptionsScrollView documentView] assignedColumns] allValues];

    for(var i=0; i < [oldAssignedCols count]; i++)
    {
        var curColumn = [oldAssignedCols objectAtIndex:i];
        var tableColTitle = [[curColumn headerView] stringValue];

        [m_MatchPopUp addItemWithTitle:tableColTitle];
        [m_UnassignedTableColumns removeObject:curColumn];
    }

    if(operationType == "UPDATE")
        [m_ImportOptionsScrollView setDocumentView:m_UpdateOptionsView];
    else if(geomType == "POINT")
        [m_ImportOptionsScrollView setDocumentView:m_PointInsertOptionsView];
    else
        [m_ImportOptionsScrollView setDocumentView:m_PolygonInsertOptionsView];

    var newAssignedCols = [[[m_ImportOptionsScrollView documentView] assignedColumns] allValues];

    for(var i=0; i < [newAssignedCols count]; i++)
    {
        var curColumn = [newAssignedCols objectAtIndex:i];
        var tableColTitle = [[curColumn headerView] stringValue];

        [m_MatchPopUp removeItemWithTitle:tableColTitle];
        [m_UnassignedTableColumns addObject:curColumn];
    }

}

- (void)updateFilterTypePopUp
{
    var geometryType = [[m_GeometryTypePopUp titleOfSelectedItem] uppercaseString];
    var filterDesc = [[m_FilterManager filterDescriptions] allValues];

    [m_FilterTypePopUp removeAllItems];

    for(var i=0; i < [filterDesc count]; i++)
    {
        var curDesc = [filterDesc objectAtIndex:i];
        
        if([curDesc dataType] == geometryType)
            [m_FilterTypePopUp addItemWithTitle:[curDesc name]];
    }
}

- (void)initColumnPopUps
{
    var csvTableColumns = m_UnassignedTableColumns;
    var columnHeaderNames = [CPArray array];

    for(var i=0; i < [csvTableColumns count]; i++)
        [columnHeaderNames addObject:[[[csvTableColumns objectAtIndex:i] headerView] stringValue]];

    [m_MatchPopUp removeAllItems];
    [m_MatchPopUp addItemsWithTitles:columnHeaderNames];

    [m_UpdateOptionsView initColumnPopUps:columnHeaderNames];
    [m_PointInsertOptionsView initColumnPopUps:columnHeaderNames];
    [m_PolygonInsertOptionsView initColumnPopUps:columnHeaderNames];
}

- (void)addColumnToColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];
    
    [m_MatchPopUp addItemWithTitle:tableColTitle];

    [m_UpdateOptionsView addColumnToColumnPopups:tableColumn];
    [m_PointInsertOptionsView addColumnToColumnPopups:tableColumn];
    [m_PolygonInsertOptionsView addColumnToColumnPopups:tableColumn];
}

- (void)removeColumnFromColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_MatchPopUp removeItemWithTitle:tableColTitle];

    [m_UpdateOptionsView removeColumnFromColumnPopups:tableColumn];
    [m_PointInsertOptionsView removeColumnFromColumnPopups:tableColumn];
    [m_PolygonInsertOptionsView removeColumnFromColumnPopups:tableColumn];
}

- (void)onColumnAssigned:(CPTableColumn)tableColumn inPanel:(CPView)panel
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_UnassignedTableColumns removeObject:tableColumn];

    [m_MatchPopUp removeItemWithTitle:tableColTitle];
    [m_MatchPopUp selectItemAtIndex:0];
}

- (void)onColumnUnassigned:(CPTableColumn)tableColumn inPanel:(CPView)panel
{
    console.log("Table Column = "); console.log(tableColumn);

    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_UnassignedTableColumns addObject:tableColumn];

    console.log("Table Column Title = "); console.log(tableColTitle);

    [m_MatchPopUp addItemWithTitle:tableColTitle];
    [m_MatchPopUp selectItemAtIndex:0];
}

- (void)updateOptionAttributePopUps
{
    var filterDesc = [m_FilterManager filterDescriptions];
    var curAttributes = [[self curSelectedFilterTypeDescription] attributeFilters];

    var attributeNames = [CPArray array];

    for(var i=0; i < [curAttributes count]; i++)
        [attributeNames addObject:[[filterDesc objectForKey:[curAttributes objectAtIndex:i]] name]];

    [m_MatchToPopUp removeAllItems];
    [m_MatchToPopUp addItemsWithTitles:attributeNames];

    [[m_AttributeMatches objectForKey:m_ColumnTableColumn] removeAllObjects];
    [[m_AttributeMatches objectForKey:m_AttributeTableColumn] removeAllObjects];

    [[m_ImportOptionsScrollView documentView] updateAttributePopUps:attributeNames];

    [m_MatchTableView reloadData];
}

- (GiseduFilterDescription)curSelectedFilterTypeDescription
{
    var selectedFilterTypeName = [m_FilterTypePopUp titleOfSelectedItem];
    var filterDesc = [[m_FilterManager filterDescriptions] allValues];

    for(var i=0; i < [filterDesc count]; i++)
    {
        var curFilterDesc = [filterDesc objectAtIndex:i];

        if([curFilterDesc name] == selectedFilterTypeName)
           return curFilterDesc;
    }

    return nil;
}

- (void)onGeometryTypeChanged:(id)sender
{
    [self updateFilterTypePopUp];
    [self updateImportOptionsView];
    [self updateOptionAttributePopUps];
}

- (void)onFilterTypeChanged:(id)sender
{
    [self updateOptionAttributePopUps];
}

- (void)onOperationTypeChanged:(id)sender
{
    [self updateImportOptionsView];
    //[self updateOptionAttributePopUps];
}

- (void)onRemoveMatchButton:(id)sender
{
    var curSelectedRow = [m_MatchTableView selectedRow];

    if(curSelectedRow != CPNotFound)
    {
        var columnValue = [[m_AttributeMatches objectForKey:m_ColumnTableColumn] objectAtIndex:curSelectedRow];
         
        [[m_AttributeMatches objectForKey:m_ColumnTableColumn] removeObjectAtIndex:curSelectedRow];
        [[m_AttributeMatches objectForKey:m_AttributeTableColumn] removeObjectAtIndex:curSelectedRow];

        var removedCol = [self columnWithTitle:columnValue];

        if(removedCol)
        {
            [m_UnassignedTableColumns addObject:removedCol];
            [self addColumnToColumnPopups:removedCol];
        }

        [m_MatchTableView reloadData];
    }
}

- (void)onAddMatchButton:(id)sender
{
    var matches = [m_AttributeMatches allValues];

    var columnValue = [m_MatchPopUp titleOfSelectedItem];
    var attributeValue = [m_MatchToPopUp titleOfSelectedItem];

    if(columnValue && attributeValue)
    {
        [[m_AttributeMatches objectForKey:m_ColumnTableColumn] addObject:columnValue];
        [[m_AttributeMatches objectForKey:m_AttributeTableColumn] addObject:attributeValue];

        var addedCol = [self columnWithTitle:columnValue];

        if(addedCol)
        {
            [m_UnassignedTableColumns removeObject:addedCol];
            [self removeColumnFromColumnPopups:addedCol];
        }

        [m_MatchTableView reloadData];
    }
}

- (void)onCancelButton:(id)sender
{
    [self close];
}

+ (id)csvImportPanel
{
    var newPanel = [[CsvImportPanel alloc] init];

    [newPanel setFloatingPanel:YES];
    [newPanel setTitle:"Import CSV File"];
    [newPanel setBackgroundColor:[CPColor whiteColor]];

    return newPanel;
}

@end