#!/usr/bin/perl

use strict;
use CGI;
use Template;
use Config::Tiny;
use DBI;
use CGI::Session;
use Unifi::Base;
use Authen::Passphrase::BlowfishCrypt;

my $cgi      = new CGI;
my $template = Template->new();
my $file     = 'templates/change_pass.tt';
my $dbh      = Unifi::Base::new_dbh();


my $session = load CGI::Session( 'driver:mysql', undef, { Handle => $dbh }, ); 
    my $id    	    = $session->param("id");
    my $username    = $session->param("username");
    my $sessid      = $session->param("_SESSION_ID");
    my $sess 	    = $session->dataref();

    if ( $session->is_expired ) {
        print "Content-type: text/html\n\n";
        print "<meta http-equiv=\"REFRESH\" content=\"0;url=admin.pl?expired=true\">";
    }
    if ( $session->is_empty ) {
        print "Content-type: text/html\n\n";    
        print "<meta http-equiv=\"REFRESH\" content=\"0;url=admin.pl?empty=true\">";
        exit;
    }

my $pass     = $cgi->param("password");
my $eq_pass  = $cgi->param("new_equals_password");
my $message  = $cgi->param("message");
my $update   = $cgi->param("update");

# For the javascript-less browser 
if ( $pass ne $eq_pass) {
    print "Content-type: text/html\n\n";
    print "<meta http-equiv=\"REFRESH\" content=\"0;url=change_pass.pl?message=Password's don't match\">";
}

if ( $update ) {
    $message = Unifi::Base::change_admin_password($dbh,$username,$pass);
}


my $vars = {
                title   => "Change Password",
                message => $message,
                
	};

$template->process($file,$vars)
   || die $template->error(), "\n";
