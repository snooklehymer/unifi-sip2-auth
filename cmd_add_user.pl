#!/usr/bin/perl
# Unifi-SIP-auth Add admin user
# unifi-sip-auth June 2014

use strict;
use Unifi::Base;
use Config::Tiny;
use DBI;
use Authen::Passphrase::BlowfishCrypt;


print "\n-------------------------------------------------------------------------\n";
print "This scrip allows you to add Admin users to local Unifi-SIP-auth database\n";
print "-------------------------------------------------------------------------\n\n";


USERNAME:
print "Enter username to add: ";
chomp (my $user = <STDIN>);
unless ( $user ) {
   goto USERNAME
}

F_PASS:
print "Enter password : ";
chomp (my $f_pass = <STDIN> );
unless ($f_pass) {
    goto F_PASS
}
S_PASS:
print "Confirm password: ";
chomp (my $s_pass = <STDIN>);
unless ($s_pass) {
    goto S_PASS
}

if ( $f_pass ne $s_pass ) {
    print "Error: passwords don't match\n";
    sleep (1);
    goto F_PASS
}

my $res = Unifi::Base::add_admin_user($user,$f_pass);

if ( $res == 0 ) {
    print "User added successfully\n"
}
else { print "Error adding use\n" }


