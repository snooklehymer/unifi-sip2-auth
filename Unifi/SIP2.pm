package Unifi::SIP2;

use IO::Socket;
use POSIX qw(strftime);
use DBI;
use LWP::UserAgent;
use Time::Piece;

sub new {
	my ($class, $self) = @_;
	bless $self, $class;
	$self->init;
	return $self;
}

sub init {
    my ($self) = @_;
    if ( $self->{sip_logging_enabled} ) {
	$self->{logfile} = '/tmp/unifi.siptrace';
    }
    
    if ($self->{sip_auth_login}) {
		$self->make93;
    }
	else {
	   $self->make99 
	}

    return;
}


sub go {
	my $self = shift;
	my $userid = shift;
	my $pin	   = shift;
    if ($self->{sip_send_char} eq "NL") {
		$self->{send_char} = chr(0x0a)
	}
	else { $self->{send_char} = chr(0x0d) }
 	my $socket = IO::Socket::INET->new(PeerAddr => $self->{sip_server},
			PeerPort => $self->{sip_port},
			Proto    => 'tcp',
			Timeout  => '15',
			Type     => SOCK_STREAM)
			or return 99;
	if ( $self->{str_99} ) {
		my $response = $self->talk99($socket,$userid,$pin);
		return $response;
	}
	elsif ( $self->{str_93} ) { 
		my $response = $self->talk93($socket,$userid,$pin);
		return $response;
		}
	
	return { error => "Uh-oh, something went wrong\n" }
}

sub talk93 {
	my ($self,$socket,$userid,$pin) = @_;
	my $send93 = $self->{str_93};
	$send93 .= $self->{send_char};
	    if ( $self->{sip_logging_enabled} ) {logger($send93,$self->{logfile});
	$socket->send($send93);
	my $response;
	$socket->recv($response, 1024);
	chomp $response;
	if ( $self->{sip_logging_enabled} ) {logger($response,$self->{logfile}) }
		my $auth = substr $response,2,1;
		my $run_num = substr $response, 5,1;

	if ( $auth == "1" ) {
		my $str99 = $self->make99($run_num);
		my $sip_resp = $self->talk99($socket,$userid,$pin);
		
	return $sip_resp;
	}
	elsif ($auth == "0") {
		return {error => "Invalid SIP server login credentials"} 
	}
}

sub talk99 {
	my ($self,$socket,$userid,$pin) = @_;
	my $send99 = $self->{str_99};
	$send99 .= $self->{send_char};
		if ( $self->{sip_logging_enabled} ) { logger($send99,$self->{logfile}) }
	$socket->send($send99);
	my ($response,$split);
        $socket->recv($response, 1024);
        chomp $response;
		if ( $self->{sip_logging_enabled} ) { logger($response,$self->{logfile}) }
	if ( $self->{sip_split_messages} ) {
		$socket->recv($split,1024);
		chomp $split;
		$response .= $split;
		if ( $self->{sip_logging_enabled} ) { logger($response,$self->{logfile}) }
	}
	if ( (substr $response, 0,3) eq '98Y') {
		my ($chk, $end) = split /\|AY/ ,$response;
		$chk .= "|AY";
		my $run_num = substr($end,0,1);
		my $sip_response = $self->talk63($userid,$pin,$run_num,$socket) . $self->{send_char};
			if ( $self->{sip_logging_enabled} ) { logger($sip_response,$self->{logfile}) }
		$socket->send($sip_response);
		$socket->recv($response, 1024);
			if ( $self->{sip_logging_enabled} ) { logger($response,$self->{logfile}) }
	        if ( $self->{sip_split_messages} ) {
        	        $socket->recv($split,1024);
                	chomp $split;
	                $response .= $split;
			if ( $self->{sip_logging_enabled} ) { logger($response,$self->{logfile}) }
        	}
		$socket->close();
		return $response;
		} 
}

sub talk63 {
	my ($self,$userid,$pin,$run_num,$socket) = @_;
	my $summary = "          ";
	my $str = "63" . "001" . timestamp() . $summary;
	$str .= "AO" . $self->{sip_location} . $self->{field_ident} . "AA$userid" . $self->{field_ident} . "AC" . $self->{field_ident};
		if ( $self->{sip_use_pin} ) {
			$str .= "AD" . $pin . $self->{field_ident}
		}
	$resp = checksum($str,$run_num);
	return ($str . $resp)
	
}

sub make99 {
	my $self = shift;
	my $run_num = shift;
	# Sticking with fixed status code and width. SIP 2.00 only.
	my $string = "9900302.00";
	my $final = checksum($string,$run_num);
	$self->{str_99} = $string . $final;
	
}

sub make93 {
	my $self		=	shift;
	# Assuming no support for encrypted UID/PWD
	my $string		=   "9300";
	$string	.= "CN" . $self->{sip_user} . $self->{field_ident};
	$string	.= "CO" . $self->{sip_pass} . $self->{field_ident};
	$string	.= "CP";
		if( $self->{sip_location} ) { 
			$string .= $self->{sip_location} . $self->{field_ident};
		}
		else {
			$string .= " " . $self->{field_ident}; 
		}
    my $str_93 = checksum($string);
	$self->{str_93} = $string . $str_93;

	
}

sub checksum {
	my $str = shift;
	my $run_num = shift;
	 if ($run_num == 10) {
        $run_num = 0;
    }
    unless ($run_num) {$run_num = '0'}
    $run_num++;
	my $trail = "AY$run_num" . 'AZ';     
    $str .= $trail;
    my $checksum = -unpack('%16U*', $str) & 0xFFFF;
    $trail .= sprintf '%04.4X', $checksum;
    
    return $trail;
    
}
 sub timestamp {
    my $timestamp = strftime '%Y%m%d    %H%M%S', localtime;
    return $timestamp;
}


sub parse_64 {
	my $self = shift;
	my $str = shift;
	my %results;
	my @str = split /\|/,$str;
		foreach my $res (@str) {
			my $code = substr $res,0,2 ;
				$results{$code} = substr $res,2;
		}
                
	return \%results;
}

            

sub sip_validate_rules {
    my $config        = shift;
    my $six4          = shift;
    my $pin	      = shift;
# Some sites might not use PIN for validation. Here we check for surname instead
	 if ( $config->{sip_validate_surname} ) {
		 my ($surname,$firstname) = split /\,/,$six4->{'AE'};
		 $surname = lc $surname;
		 $pin = lc $pin;
		 unless ( "$surname" eq "$pin" )  {
			 return (3,"Invalid Username or Password");
		 }
	 }

    my $sip_rules     = Unifi::Base::get_sip_validation_rules();
    foreach my $rule (@$sip_rules){
         
         if ($rule->{conditions} eq "equal") {
				# If we are validating surname we need to skip the PIN check
				if ( $config->{sip_validate_surname} && $rule->{sip_code} eq "CQ" ) {
					next;
				} 
                if ( $six4->{ $rule->{sip_code} } eq $rule->{value}) {
                return ($rule->{actions},$rule->{message})
                }

         }
		 if ($rule->{conditions} eq "starts_with") {
                if ( $six4->{ $rule->{sip_code} } =~  m/^$rule->{value}/ ) {
                return ($rule->{actions},$rule->{message})
                }                            
         }
         if ($rule->{conditions} eq "less_than") {
			 # Unicorn
			 if ( $six4->{ $rule->{sip_code} }  ) {
				 my $now     = localtime();
				 my $age     = $six4->{'PD'};
				 my $year    = substr $age,0,4;
				 my $mon     = substr $age,4,2;
				 my $day     = substr $age,6,2;
				 $age     = "$year-$mon-$day";
				 my $sip_age = Time::Piece->strptime($age, "%Y-%m-%d");
				 my $today 	 = $now->ymd;
				 my $age_now = Time::Piece->strptime($today, "%Y-%m-%d");
				 my $difference = $age_now - $sip_age;
				 my $years = $difference->years;
				 if ( $years < $rule->{value} ) {
					return ($rule->{actions},$rule->{message})
				 }
			 }
		 }
        
    }
    return 10;
}

sub auth_unifi {
	my $self = shift;
	my $mac  = shift;
	my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0,
                                     SSL_verify_mode => 0x00,
                                     PERL_LWP_SSL_VERIFY_HOSTNAME => 0,
                                     SSL_cipher_list => "RC4-SHA"
                                     });
	my $cookies = HTTP::Cookies->new(
					file     => '/tmp/unificookies.txt',
					autosave => 1,
					);
	$ua->cookie_jar($cookies);
	my $login = $ua->post("https://$self->{unifi_controller_addr}:$self->{unifi_controller_port}/login", [
			      login    => 'login',
			      username => $self->{unifi_admin_user},
			      password => $self->{unifi_admin_password}, ]
			      );
	if ( $login->is_error ) {
		return 3
	}
	my $g_url = "https://$self->{unifi_controller_addr}:$self->{unifi_controller_port}/api/s/$self->{unifi_site_name}/cmd/stamgr";
	my $req = HTTP::Request->new(POST => $g_url);
	$req->content_type('application/json');
	my $json="{'cmd':'authorize-guest', 'mac':\'$mac\'}";
	$req->content($json);
	my $res = $ua->request($req);
	return $res;
}

 sub logger {
	my ($msg, $file) = @_;
	open(LOG,">>",$file) or warn "Can't open log file $file";
	my $time = strftime '%d/%m/%Y %H:%M:%S', localtime;
	print LOG "$time ~ $msg\n";
	close (LOG);
	}
}

1;
