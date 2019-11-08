#!perl -w
use strict;
use Test::More;
use Cwd;
use URI::file;
use File::Basename;
use File::Spec;
use Data::Dumper;

use Log::Log4perl qw(:easy);

use WWW::Mechanize::Chrome;
use lib '.';
use t::helper;
use Test::HTTP::LocalServer;

Log::Log4perl->easy_init($ERROR);  # Set priority of root logger to ERROR

# What instances of Chrome will we try?
my @instances = t::helper::browser_instances();

if (my $err = t::helper::default_unavailable) {
    plan skip_all => "Couldn't connect to Chrome: $@";
    exit
} else {
    plan tests => 4*@instances;
};

sub new_mech {
    t::helper::need_minimum_chrome_version( '62.0.0.0', @_ );
    WWW::Mechanize::Chrome->new(
        autodie => 1,
        @_,
    );
};

sub load_file_ok {
    my ($mech, $htmlfile,@options) = @_;
    my $fn = File::Spec->rel2abs(
                 File::Spec->catfile(dirname($0),$htmlfile),
                 getcwd,
             );
    #$mech->allow(@options);
    #diag "Loading $fn";
    $mech->get_local($fn);
    ok $mech->success, "Loading $htmlfile is considered a success";
    is $mech->title, $htmlfile, "We loaded the right file (@options)"
        or diag $mech->content;
};

t::helper::run_across_instances(\@instances, \&new_mech, 4, sub {
    my ($browser_instance, $mech) = @_;
    isa_ok $mech, 'WWW::Mechanize::Chrome';

    my @alerts;

    $mech->on_dialog( sub {
        my ( $mech, $dialog ) = @_;
        push @alerts, $dialog;
        $mech->handle_dialog(1); # I always click "OK", why?
    });

    load_file_ok($mech, '58-alert.html', javascript => 1);

    is 0+@alerts, 2, "got two alerts";

    undef $mech;
});
