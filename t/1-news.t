#!/usr/bin/perl
use strict;
use Test::More tests => 3;

use WWW::Google::News::TW qw( get_news );

my $results;

$results = get_news();

#use Data::Dumper;
#print STDERR "\n",Dumper($results);

ok(defined($results),'GNTW: At least we got something');

ok(exists($results->{'國際'}),'GN-TW: Top National Stories Exists');
#ok(keys(%{$results->{'焦點'}}),'GN-TW: Top Stories Is Not Empty');
ok(exists(${$results->{'社會'}}[0]),'GN-TW: Top Social Stories Story 1 Exists');
