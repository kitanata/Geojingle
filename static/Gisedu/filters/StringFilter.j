@import "GiseduFilter.j"

@implementation StringFilter : GiseduFilter
{
    CPString m_szValue          @accessors(property=value);
}

- (id)initWithValue:(CPString)value
{
    self = [super init];

    if(self)
    {
        m_szValue = value;
    }

    return self;
}

@end