#!/bin/sh
ctags -R --langdef=objj --langmap=objj:.j \
    --regex-objj="/^[[:space:]]*[-+][[:space:]]*\([[:alpha:]]+[[:space:]]*\*?\)[[:space:]]*([[:alnum:]]+):[[:space:]]*\(/\1/m,method/" \
    --regex-objj="/^[[:space:]]*[-+][[:space:]]*\([[:alpha:]]+[[:space:]]*\*?\)[[:space:]]*([[:alnum:]]+)[[:space:]]*\{?/\1/m,method/" \
    --regex-objj="/^[[:space:]]*[-+][[:space:]]*\([[:alpha:]]+[[:space:]]*\*?\)[[:space:]]*([[:alnum:]]+)[[:space:]]*\;/\1/m,method/" \
    --regex-objj="/^[[:space:]]*\@implementation[[:space:]]+(.*)$/\1/c,class/" *
