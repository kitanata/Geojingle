@import "../GiseduModule.j"
@import "CsvImportPanel.j"

@implementation CsvImporterModule : GiseduModule
{
    CPMenuItem m_FileImportCSVItem;
}

- (id)initFromApp:(CPObject)app
{
    self = [super initFromApp:app];

    if(self)
    {
    }

    return self;
}

- (void)loadIntoMenu:(CPMenu)theMenu
{
    m_FileSeparatorItem = [CPMenuItem separatorItem];
    m_FileImportCSVItem = [[CPMenuItem alloc] initWithTitle:@"Import CSV" 
        action:@selector(onImportCSV:) keyEquivalent:nil];

    [m_FileImportCSVItem setTarget:self];

    [theMenu addItem:m_FileSeparatorItem];
    [theMenu addItem:m_FileImportCSVItem];
}

- (void)updateMenuItems:(BOOL)sessionActive
{
    [m_FileSeparatorItem setHidden:!sessionActive];
    [m_FileImportCSVItem setHidden:!sessionActive];
}

- (void)onImportCSV:(id)sender
{
    importPanel = [CsvImportPanel csvImportPanel];
    [importPanel orderFront:self];
}

@end
