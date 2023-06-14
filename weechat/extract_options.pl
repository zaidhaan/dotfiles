#!/usr/bin/perl

use strict;
use warnings;

# example usage:
# $ ./extract_options.pl < $XDG_DATA_HOME/weechat/logs/core.weechat.weechatlog > weechatrc

my %options;

while (<>) {
    # 2023-01-23 12:34:56  Option changed: weechat.foo.bar = baz (default: qux)
    if (/Option changed: (?<option>\S+)\s+=\s+(?<value>\S+)\s+\(default/) {
        $options{$+{option}} = $+{value};
    }
}

while (my ($option, $value) = each %options) {
    print "set $option = $value\n";
}

