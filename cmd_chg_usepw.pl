#!/usr/bin/perl
# Unifi-SIP-auth Change Admin User Password
# unifi-sip-auth June 2014

use strict;
use Unifi::Base;
use Config::Tiny;
use DBI;
use Authen::Passphrase::BlowfishCrypt;
my $dbh = Unifi::Base::new_dbh();

print "\n-------------------------------------------------------------------------------------\n";
print "This scrip allows you to change an Admin users password on the Unifi-SIP-auth database\n";
print "--------------------------------------------------------------------------------------\n\n";


USERNAME:
print "Enter username of user to change password: ";
chomp (my $user = <STDIN>);
unless ( $user ) {
   goto USERNAME
}

F_PASS:
print "Enter new password : ";
chomp (my $f_pass = <STDIN> );
unless ($f_pass) {
    goto F_PASS
}
S_PASS:
print "Confirm new password: ";
chomp (my $s_pass = <STDIN>);
unless ($s_pass) {
    goto S_PASS
}

if ( $f_pass ne $s_pass ) {
    print "Error: passwords don't match\n";
    sleep (1);
    goto F_PASS
}

my $res = Unifi::Base::change_admin_password($dbh,$user,$f_pass);

if ( $res == 0 ) {
    print "User password changed successfully\n"
}
else { print "Error adding use\n" }

