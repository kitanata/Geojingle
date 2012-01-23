@import <Foundation/CPObject.j>

@implementation GiseduModule : CPObject
{
    var m_AppController;
}

- (id)initFromApp:(CPObject)app
{
    self = [super init];

    if(self)
    {
        m_AppController = app;
    }

    return self;
}

- (void)loadIntoMenu:(CPMenu)theMenu { }

- (void)updateMenu:(BOOL)sessionActive { }

- (void)enable {}
- (void)disable {}

@end
