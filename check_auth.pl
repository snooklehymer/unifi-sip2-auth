#!/usr/bin/perl
use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use LWP::Protocol::https;
use Unifi::Base;
use Unifi::SIP2;
use Config::Tiny;
use Template;
use CGI;
use DBI;
use JSON::XS;

my $conf        = Unifi::Base->get_config();
my $template    = Template->new();
my $file        = 'templates/check_auth.tt';
my $cgi         = new CGI;
my $mac         = $cgi->param('mac');
my $user        = $cgi->param('username');
my $pass        = $cgi->param('password');

unless ( ($user) && ($pass) ) {
    print $cgi->redirect("index.pl?denied=true&message=Invalid Username or Password");
}

my $sip  = Unifi::SIP2->new(@$conf);
my $res  = $sip->go($user,$pass);

# RC 99 means we can't contact the SIP server
if ( $res eq '99') {
    print $cgi->redirect("index.pl?denied=true&message=SIP Server down. Contact staff");
}

# We got this far, SIP server must be up, parse the 64 string and check for SIP rules
my $parse = $sip->parse_64($res);
my ($action,$message) = $sip->sip_validate_rules($parse,$pass);

# SIP Rules returned codes here
if ( ( $action eq '3' ) || ( $action eq '10' ) ) {
    print $cgi->redirect("index.pl?denied=true&message=$message");
   
}

# All is good with SIP, check the Unifi Controller and see if we can get access
if ( $action eq '0') {
    my $allow_res =  $sip->auth_unifi($mac);
    # Problem connecting to the Unifi Controller - let the user know
    if ( $allow_res == 3 ) {
        print "Content-type: text/html\n\n";    
        print "<meta http-equiv=\"REFRESH\" content=\"0;url=index.pl?denied=true&message=Cannot connect to Unifi Controller\">";
        exit;
    }
    my $res =  $allow_res->{_content};
    my $json = JSON::XS->new->utf8->decode ($res);
    if ( $json->{meta}->{rc} eq 'ok' ) {
        print $cgi->redirect($conf->[0]->{redirect_page} )
    }
    # Issues here with authentication to the Unifi Controller -  let the user know
    else {
        print "Content-type: text/html\n\n";    
        print "<meta http-equiv=\"REFRESH\" content=\"0;url=index.pl?denied=true&message=Controller denied access\">";
        exit;
        }
}


my $vars = {};

$template->process($file,$vars)
   || die $template->error(), "\n";
