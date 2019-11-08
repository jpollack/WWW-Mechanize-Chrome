#!perl -w
use strict;
use Test::More;
use WWW::Mechanize::Chrome;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);  # Set priority of root logger to ERROR

use lib '.';
use t::helper;


my $mech = eval {
    t::helper::need_minimum_chrome_version( '62.0.0.0', @_ );
    
    WWW::Mechanize::Chrome->new(
    autodie => 0,
    startup_timeout => 4,
    headless => 1,
)};

if (! $mech) {
    my $err = $@;
    plan skip_all => "Couldn't connect to Chrome: $@";
    exit
} else {
    plan tests => 1;
};

isa_ok $mech, 'WWW::Mechanize::Chrome';
