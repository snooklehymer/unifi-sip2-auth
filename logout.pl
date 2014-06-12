#!/usr/bin/perl

use strict;
use Template;
use CGI;
use CGI::Session;
use DBI;
use Config::Tiny;
use Unifi::Base;

my $dbh = Unifi::Base::new_dbh();
my $cgi = new CGI;

my $session = load CGI::Session( 'driver:mysql', undef, { Handle => $dbh }, );
$session->delete();

print "Content-type: text/html\n\n";
print "<meta http-equiv=\"REFRESH\" content=\"0;url=admin.pl\">";