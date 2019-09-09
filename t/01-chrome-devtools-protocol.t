#!perl -w
use strict;
use Test::More;
use Data::Dumper;
use Chrome::DevToolsProtocol;
use WWW::Mechanize::Chrome; # for launching Chrome
use Log::Log4perl qw(:easy);

use lib '.';
use t::helper;

my @instances = t::helper::browser_instances();
Log::Log4perl->easy_init($ERROR);  # Set priority of root logger to ERROR

if (my $err = t::helper::default_unavailable) {
    plan skip_all => "Couldn't connect to Chrome: $@";
    exit
} else {
    plan tests => 3*@instances;
};

sub new_mech {
    my $chrome = WWW::Mechanize::Chrome->new(
        @_
    );
};

t::helper::run_across_instances(\@instances, \&new_mech, 3, sub {
    my( $file, $mech ) = splice @_;
    my $chrome = $mech->driver->transport;

    isa_ok $chrome, 'Chrome::DevToolsProtocol';

    my $version = $chrome->protocol_version->get;
    cmp_ok $version, '>=', '0.1', "We have a protocol version ($version)";

    #diag "Open tabs";

    my @tabs = $chrome->getTargets()->get;
    cmp_ok 0+@tabs, '>', 0,
        "We have at least one open (empty) tab";
});
