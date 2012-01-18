/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/*                          BloomFilter implementation in JavaScript                              */
/*                      (c) Jason Davies 2011 | Forked under MIT License                          */
/*         Cappucinno Implementation (c) eTech Ohio 2011 - Contributor Raymond Chandler III       */
/*                      Cappucinno Implementation Released under MIT License                      */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

@import <Foundation/CPObject.j>

@implementation BloomFilter : CPObject
{
    CPInteger m_nBits;
    CPInteger m_nHashs;

    var m_Buckets;
    var m_Locations;
}

- (void)init
{
    [self initWithBits:256*32 andHashs:16];
}

- (void)initWithBits:(CPInteger)bits andHashs:(CPInteger)hashs
{
    /*m = m_nBits k = m_nHashs */
    m_nBits = bits;
    m_nHashs = hashs;

    var n = Math.ceil(m_nBits / 32);
    var typedArrays = typeof ArrayBuffer !== "undefined";

    if (typedArrays) {
        var buffer = new ArrayBuffer(32 * n);
        var kbytes = 1 << Math.ceil(Math.log(Math.ceil(Math.log(m_nBits) / Math.LN2 / 8)) / Math.LN2);
        var kbuffer = new ArrayBuffer(kbytes * m_nHashs);

        if(kbytes === 1)
            array = Uint8Array;
        else if(kbytes === 2)
            array = Uint16Array;
        else
            array = Uint32Array;

        m_Buckets = new Uint32Array(buffer);
        m_Locations = new array(kbuffer);
    } else {
        var buckets = m_Buckets = [];
        var i = -1;
        while (++i < n) buckets[i] = 0;
        m_Locations = [];
    }
}

- (void)locations:(CPString)v
{
    var a = fnv_1a(v);
    var b = fnv_1a_b(a);
    var i = -1;
    var x = a % m_nBits;

    while (++i < m_nHashs) 
    {
        m_Locations[i] = x < 0 ? (x + m_nBits) : x;
        x = (x + b) % m_nBits;
    }

    return m_Locations;
}

- (void)add:(CPString)v
{
    var l = [self locations:v];
    var i = -1;

    while (++i < m_nHashs)
        m_Buckets[Math.floor(l[i] / 32)] |= 1 << (l[i] % 32);
}

- (void)test:(CPString)v
{
    var l = [self locations:v];
    var i = -1;
    var b;

    while (++i < m_nHashs) {
        b = l[i];
        if ((m_Buckets[Math.floor(b / 32)] & (1 << (b % 32))) === 0) {
            return false;
        }
    }
    return true;
}

// Fowler/Noll/Vo hashing.
- (void)fnv_1a:(CPString)v
{
    var n = v.length,
        a = 2166136261,
        c,
        d,
        i = -1;

    while (++i < n) {
        c = v.charCodeAt(i);
        if (d = c & 0xff000000) {
            a ^= d >> 24;
            a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
        }
        if (d = c & 0xff0000) {
            a ^= d >> 16;
            a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
        }
        if (d = c & 0xff00) {
            a ^= d >> 8;
            a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
        }
        a ^= c & 0xff;
        a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
    }

    // From http://home.comcast.net/~bretm/hash/6.html
    a += a << 13;
    a ^= a >> 7;
    a += a << 3;
    a ^= a >> 17;
    a += a << 5;
    return a & 0xffffffff;
}

- (void)fnv_1a_b:(CPString)v
{
    a += (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
    a += a << 13;
    a ^= a >> 7;
    a += a << 3;
    a ^= a >> 17;
    a += a << 5;
    return a & 0xffffffff;
}

@end
