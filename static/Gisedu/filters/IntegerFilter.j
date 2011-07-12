@import "GiseduFilter.j"

@implementation IntegerFilter : GiseduFilter
{
    CPInteger m_nValue          @accessors(property=value);
}

- (id)initWithValue:(CPInteger)value
{
    self = [super init];

    if(self)
    {
        m_nValue = value;
    }

    return self;
}

@end