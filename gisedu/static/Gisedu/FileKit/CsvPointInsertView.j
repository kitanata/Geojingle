@import <Foundation/CPObject.j>

@implementation CsvPointInsertView : CPView
{
    CPTextField m_ItemNameLabel;
    CPTextField m_ItemTypeLabel;
    CPTextField m_LatitudeLabel;
    CPTextField m_LongitudeLabel;

    CPTextField m_StreetAddressLabel;
    CPTextField m_CityLabel;
    CPTextField m_StateLabel;
    CPTextField m_ZipLabel;

    CPPopUpButton m_ItemNamePopUp;
    CPPopUpButton m_ItemTypePopUp;
    CPPopUpButton m_LatitudePopUp;
    CPPopUpButton m_LongitudePopUp;

    CPPopUpButton m_StreetAddressPopUp;
    CPPopUpButton m_CityPopUp;
    CPPopUpButton m_StatePopUp;
    CPPopUpButton m_ZipPopUp;

    var m_LabelsLeft;
    var m_ButtonsLeft;

    CPDictionary m_AssignedColumns  @accessors(getter=assignedColumns);
    id m_Delegate                   @accessors(property=delegate);
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 280, 280)];

    if(self)
    {
        m_LabelsLeft = 10;
        m_ButtonsLeft = m_LabelsLeft + 130;

        m_AssignedColumns = [CPDictionary dictionary];

        m_ItemNameLabel = [self createLabelWithTitle:"Item Name" yOrg:0];
        m_ItemNamePopUp = [self createPopUpButton:[CPArray array] yOrg:0 action:@selector(onPopUpColumnSelected:)];

        m_ItemTypeLabel = [self createLabelWithTitle:"Item Type" yOrg:35];
        m_ItemTypePopUp = [self createPopUpButton:["None"] yOrg:35 action:@selector(onPopUpColumnSelected:)];

        m_LatitudeLabel = [self createLabelWithTitle:"Latitude" yOrg:70];
        m_LatitudePopUp = [self createPopUpButton:[CPArray array] yOrg:70 action:@selector(onPopUpColumnSelected:)];

        m_LongitudeLabel = [self createLabelWithTitle:"Longitude" yOrg:105];
        m_LongitudePopUp = [self createPopUpButton:[CPArray array] yOrg:105 action:@selector(onPopUpColumnSelected:)];


        m_StreetAddressLabel = [self createLabelWithTitle:"Street Address" yOrg:140];
        m_StreetAddressPopUp = [self createPopUpButton:["None"] yOrg:140 action:@selector(onPopUpColumnSelected:)];

        m_CityLabel = [self createLabelWithTitle:"City" yOrg:175];
        m_CityPopUp = [self createPopUpButton:["None"] yOrg:175 action:@selector(onPopUpColumnSelected:)];

        m_StateLabel = [self createLabelWithTitle:"State" yOrg:210];
        m_StatePopUp = [self createPopUpButton:["None"] yOrg:210 action:@selector(onPopUpColumnSelected:)];

        m_ZipLabel = [self createLabelWithTitle:"Zip" yOrg:245];
        m_ZipPopUp = [self createPopUpButton:["None"] yOrg:245 action:@selector(onPopUpColumnSelected:)];

        [m_ItemTypePopUp addItemWithTitle:"None"];
        [m_StreetAddressPopUp addItemWithTitle:"None"];
        [m_CityPopUp addItemWithTitle:"None"];
        [m_StatePopUp addItemWithTitle:"None"];
        [m_ZipPopUp addItemWithTitle:"None"];

        [self addSubview:m_ItemNameLabel];
        [self addSubview:m_ItemTypeLabel];
        [self addSubview:m_LatitudeLabel];
        [self addSubview:m_LongitudeLabel];

        [self addSubview:m_StreetAddressLabel];
        [self addSubview:m_CityLabel];
        [self addSubview:m_StateLabel];
        [self addSubview:m_ZipLabel];

        [self addSubview:m_ItemNamePopUp];
        [self addSubview:m_ItemTypePopUp];
        [self addSubview:m_LatitudePopUp];
        [self addSubview:m_LongitudePopUp];

        [self addSubview:m_StreetAddressPopUp];
        [self addSubview:m_CityPopUp];
        [self addSubview:m_StatePopUp];
        [self addSubview:m_ZipPopUp];
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
    var popUps = [m_ItemNamePopUp, m_ItemTypePopUp, m_LatitudePopUp, m_LongitudePopUp,
            m_StreetAddressPopUp, m_CityPopUp, m_StatePopUp, m_ZipPopUp];

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
    [m_LatitudePopUp addItemWithTitle:tableColTitle];
    [m_LongitudePopUp addItemWithTitle:tableColTitle];

    [m_ItemTypePopUp addItemWithTitle:tableColTitle];
    [m_StreetAddressPopUp addItemWithTitle:tableColTitle];
    [m_CityPopUp addItemWithTitle:tableColTitle];
    [m_StatePopUp addItemWithTitle:tableColTitle];
    [m_ZipPopUp addItemWithTitle:tableColTitle];
}

- (void)removeColumnFromColumnPopups:(CPTableColumn)tableColumn
{
    var tableColTitle = [[tableColumn headerView] stringValue];

    [m_ItemNamePopUp removeItemWithTitle:tableColTitle];
    [m_LatitudePopUp removeItemWithTitle:tableColTitle];
    [m_LongitudePopUp removeItemWithTitle:tableColTitle];

    [m_ItemTypePopUp removeItemWithTitle:tableColTitle];
    [m_StreetAddressPopUp removeItemWithTitle:tableColTitle];
    [m_CityPopUp removeItemWithTitle:tableColTitle];
    [m_StatePopUp removeItemWithTitle:tableColTitle];
    [m_ZipPopUp removeItemWithTitle:tableColTitle];
}

- (void)initColumnPopUps:(CPArray)csvColumns
{
    [m_ItemNamePopUp removeAllItems];
    [m_ItemTypePopUp removeAllItems];
    [m_LatitudePopUp removeAllItems];
    [m_LongitudePopUp removeAllItems];

    [m_StreetAddressPopUp removeAllItems];
    [m_CityPopUp removeAllItems];
    [m_StatePopUp removeAllItems];
    [m_ZipPopUp removeAllItems];

    var requiredPopUps = [m_ItemNamePopUp, m_LatitudePopUp, m_LongitudePopUp]
    var optionalPopUps = [m_ItemTypePopUp, m_StreetAddressPopUp, m_CityPopUp, m_StatePopUp, m_ZipPopUp];

    for(var i=0; i < requiredPopUps.length; i++)
        [requiredPopUps[i] addItemsWithTitles:csvColumns];

    [csvColumns addObject:"None"];

    for(var i=0; i < optionalPopUps.length; i++)
    {
        [optionalPopUps[i] addItemsWithTitles:csvColumns];
        [optionalPopUps[i] selectItemWithTitle:"None"];
    }

}

- (void)updateAttributePopUps:(CPArray)attributes
{
}

@end