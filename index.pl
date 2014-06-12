#!/usr/bin/perl

use strict;
use CGI;
use Template;
use Config::Tiny;
use DBI;
use Unifi::Base;

my $cgi     = new CGI;
my $mac     = $cgi->param('id');
my $denied  = $cgi->param('denied');
my $message = $cgi->param('message');
my $template = Template->new();

my $file = 'templates/index.tt';
my $conf = Unifi::Base->get_config();

if ($conf->[0]->{enable_sip_validation} == 0) {
    print "Content-type: text/html\n\n";
    print "<p>SIP Server not enabled. Please inform a member of staff</p>";
    exit;
}

my $vars = {
		mac     => $mac,
                denied  => $denied,
                message => $message,
                config  => $conf,
                title   => "Network Login",
	};

$template->process($file,$vars)
   || die $template->error(), "\n";
