#!/usr/bin/perl

#################################################
#  Send Mail                                    # 
#  perl script to send e-mails using templates  #
#                                               # 
#  v 1.0 Malcata, 18-Apr-2011   	        #
#################################################

# MAC OS X Perl libs (CPAN...)
#use lib '/System/Library/Perl/';
#use lib '/opt/local/lib/perl5/5.12.3/';
use lib '/opt/local/lib/perl5/site_perl/5.12.3/';

use MIME::Lite;
use Net::SMTP;
use AppConfig;

# load configuration file
my $config = AppConfig->new;
$config->define( 'file=s'     	  );
$config->define( 'from_address=s' );
$config->define( 'to_address=s'   );
$config->define( 'mailhost=s'     );
$config->define( 'subject=s'      );
$config->define( 'message_body=s' );
$config->define( 'attach_file=s'  );
$config->define( 'attach_name=s'  );


#extract filename from 
$config->args() or die "Error loading args $!\n";
my $file = $config->get( 'file' ) or die "Error loading config file $!\n";

#extract configurations from config file
$config->file( $file );
$config->args();

# load configurations from config file
my $from_address = $config->get( 'from_address' );
my $to_address = $config->get( 'to_address' );
my $mailhost = $config->get( 'mailhost' );
my $subject = $config->get( 'subject' );
my $message_body = $config->get( 'message_body' );
my $attach_file = $config->get( 'attach_file' );
my $attach_name = $config->get( 'attach_name' );


### Create the multipart container
$msg = MIME::Lite->new (
From => $from_address,
To => $to_address,
Subject => $subject,
Type =>'multipart/mixed'
) or die "Error creating multipart container: $!\n";        

### Add the text message part
$msg->attach (
Type => 'TEXT',
Path => $message_body,
#Data => $message_body
) or die "Error adding the text message part: $!\n";
            
### Add the attach file
$msg->attach (
Type => 'text/plain',
Path => $attach_file,
Filename => $attach_name,
Disposition => 'attachment'
) or die "Error adding $attach_file: $!\n";
                        
### Send the Message
MIME::Lite->send('smtp', $mailhost, Timeout=>60);
$msg->send;
