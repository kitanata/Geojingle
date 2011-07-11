@import "GiseduFilter.j"

@implementation IntegerFilter : GiseduFilter
{
    CPInteger m_nValue          @accessors(property=value);
    CPArray m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_nValue = 100;
    }

    return self;
}

@end