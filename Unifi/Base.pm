package Unifi::Base;

sub get_config {
    my $dbh = new_dbh();
    my $sth = $dbh->prepare("SELECT sitename, enable_sip_validation, INET_NTOA(sip_server) as sip_server,
                            sip_port, sip_user, sip_pass, sip_use_pin, sip_auth_login,
                            sip_send_char, sip_split_messages, sip_validate_surname, redirect_page,
                            INET_NTOA(unifi_controller_addr) as unifi_controller_addr , unifi_controller_port,
                            unifi_admin_user,unifi_admin_password,sip_location,field_ident,unifi_site_name,
                            sip_logging_enabled
                            FROM config");
    $sth->execute();
    return $sth->fetchall_arrayref({});
    
}

sub get_sip_validation_rules {
   my $dbh     = new_dbh();
   my $sth     = $dbh->prepare("SELECT s.sip_code, s.conditions, s.value, s.actions, s.message,
                               s.ord
                               FROM sip_validation_rules s
                               order by ord");
   $sth->execute();
   return $sth->fetchall_arrayref({});
}

sub new_dbh {
   my $cnf        = Config::Tiny->read('config/config');
   my $dbh = DBI->connect("DBI:mysql:dbname=$cnf->{mysql}->{MYSQL_DATABASE};
                          host=$cnf->{mysql}->{MYSQL_IP};
                          port=$cnf->{mysql}->{MYSQL_PORT}",
                          $cnf->{mysql}->{MYSQL_USER},
                          $cnf->{mysql}->{MYSQL_PASS},
                          {RaiseError=>1,
                          mysql_enable_utf8 => 1}
                          );

   return $dbh;
   }

sub change_admin_password {
    my ($dbh,$username,$password) = @_;
    my $ppr = Authen::Passphrase::BlowfishCrypt->new(
        cost => 12, salt_random => 1,
        passphrase => "$password");
    my $hash = $ppr->hash_base64;
    my $salt = $ppr->salt_base64;
    my $sth = $dbh->prepare("UPDATE admin_users
                            SET password =?, salt = ?
                            WHERE username = ?");
    eval { $sth->execute($hash,$salt,$username) };
    if ($@) {
        return $@
    }
    else {
        return "Password changed successfully for '$username'"
    }
}

sub add_admin_user {
    my $dbh = new_dbh();
    my ($username,$password) = @_;
    my $ppr = Authen::Passphrase::BlowfishCrypt->new(
        cost => 12, salt_random => 1,
        passphrase => "$password");
    my $hash = $ppr->hash_base64;
    my $salt = $ppr->salt_base64;
    my $sth  = $dbh->prepare('INSERT admin_users
                            (username,password,salt)
                            VALUES
                            (?,?,?) ') or die "Couldn't prepare statement: " . $dbh->errstr;
    eval { $sth->execute($username,$hash,$salt) };
    if($@) {
        return $@
    }
    else {return 0}

}

sub check_admin_user {
    my ($username, $passphrase)    = @_;
    my ($users_id,$user_name,$password,$salt,$sid);
    my $dbh = new_dbh();
    my $sth = $dbh->prepare("SELECT u.id,username, u.password, u.salt
                           FROM admin_users u
                           WHERE username = ?");
    $sth->execute($username) or die "Could not run statement: ";
    $sth->bind_columns(\$users_id,\$user_name,\$password,\$salt);
    $sth->fetch();
    if(defined $user_name)
    {
        my $ppr = Authen::Passphrase::BlowfishCrypt->new(
        cost => 12, salt_base64 => "$salt",
        passphrase => "$passphrase");
        my $compare_salt = $ppr->salt_base64;
        my $compare_hash = $ppr->hash_base64;
        if($password eq $compare_hash)
            {
                $result =1;
                my $session = new CGI::Session( 'driver:mysql', $sid, { Handle => $dbh } );
                my $cgi = new CGI;
                $sid = $session->id();
                $session->param('users_id',$users_id);
                $session->param('username',$user_name);

                $cookie = $cgi->cookie( -name    => $session->name,
                                        -value   => $session->id,
                                        -expires=>'+2h',
                                      );
                print $session->header(-cookie => $cookie);
            }
        if($password ne $compare_hash){$result =0}
        return ($result,$sid,$username,$cookie);
    }
    else {  $result = 0;
            return $result;
            }
}


sub update_config {
    my ($dbh,$redirect_page,$enable_sip_validation,$sip_server,
        $sip_port,$sip_auth_login,$sip_user,$sip_pass,$sip_use_pin,
        $sip_location, $sip_send_char, $sitename, $sip_split_messages,
        $unifi_site_name,$unifi_controller_addr,$unifi_controller_port,
        $unifi_admin_user,$unifi_admin_password) = @_;

    my $sth = $dbh->prepare("UPDATE config SET redirect_page = ?, enable_sip_validation = ?,
                            sip_server = INET_ATON(?), sip_port = ?,sip_auth_login = ?,
                            sip_user = ?, sip_pass = ?, sip_use_pin = ?,sip_location = ?,
                            sip_send_char = ?, sitename = ?, sip_split_messages = ?,
                            unifi_site_name = ?, unifi_controller_addr = INET_ATON(?),
                            unifi_controller_port = ?, unifi_admin_user = ?,
                            unifi_admin_password = ?
                            ");
    $sth->execute($redirect_page,$enable_sip_validation,$sip_server,$sip_port,$sip_auth_login,$sip_user,$sip_pass,
                  $sip_use_pin,$sip_location, $sip_send_char, $sitename, $sip_split_messages,$unifi_site_name,
                  $unifi_controller_addr,$unifi_controller_port,$unifi_admin_user,$unifi_admin_password);
    
    
}





1;
