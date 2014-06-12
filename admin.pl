#!/usr/bin/perl

use strict;
use CGI;
use Template;
use Config::Tiny;
use DBI;
use Unifi::Base;
use Authen::Passphrase::BlowfishCrypt;
use CGI::Session;

my $cgi     	= new CGI;
my $username	= $cgi->param('username');
my $password	= $cgi->param('password');
if ( ($username) && ($password)  ) {

	my ($res,$sid,$uname,$cookie) = Unifi::Base::check_admin_user($username,$password);

	if($res =="1"){
		print "<meta http-equiv=\"REFRESH\" content=\"0;url=dashboard.pl\">";
        exit;
	}
	
	else{
		print "Content-type: text/html\n\n";
		print "<meta http-equiv=\"REFRESH\" content=\"0;url=admin.pl?empty=true\">";
        exit;
    }
	
}


my $template = Template->new();
my $file = 'templates/admin.tt';

my $conf = Unifi::Base->get_config();


my $vars = {
	title => "Admin Login"
	};

$template->process($file,$vars)
   || die $template->error(), "\n";
