#!/usr/bin/perl

use strict;
use CGI;
use Config::Tiny;
use DBI;
use CGI::Session;
use Template;
use Unifi::Base;

my $cgi 	= new CGI;
my $config	= Unifi::Base::get_config();
my $dbh		= Unifi::Base::new_dbh();
my $update	= $cgi->param('update');

my $template = Template->new();
my $file = 'templates/dashboard.tt';


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


if ($update =="1") {

    Unifi::Base::update_config($dbh,$cgi->param("redirect_page"),$cgi->param("enable_sip_validation"),$cgi->param("sip_server"),
			        $cgi->param("sip_port") ,$cgi->param("sip_auth_login"),
				$cgi->param("sip_user"),$cgi->param("sip_pass") ,$cgi->param("sip_use_pin"),
				$cgi->param("sip_location"),$cgi->param("sip_send_char"), $cgi->param("sitename"),
				$cgi->param("sip_split_messages"),$cgi->param("unifi_site_name"),$cgi->param("unifi_controller_addr"),
				$cgi->param("unifi_controller_port"),$cgi->param("unifi_admin_user"),$cgi->param("unifi_admin_password")
				);
    $config	= Unifi::Base::get_config();
}

my $vars = {
	    
	    session_id      => $sessid,
	    username        => $username,
	    config	    => $config->[0],
	    update          => $update,
	    title	    => "Unifi SIP Auth",
	    };

$template->process($file,$vars) || die $template->error(), "\n";
