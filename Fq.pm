package Logger::Fq;

require DynaLoader;

use strict;
use vars qw($VERSION @ISA);
$VERSION = "0.2.9";
@ISA = qw/DynaLoader/;

bootstrap Logger::Fq $VERSION ;

=head1 NAME

Logger::Fq - Log asynchronously to an Fq instance.

=head1 SYNOPSIS

	use Logger::Fq;
  Logger::Fq::enable_drain_on_exit(1);

	my $logger = Logger::Fq->new( host => '127.0.0.1', port => 8765,
                                exchange => 'logging );
  $logger->log("protocol.category", "Message");
	
=head1 DESCRIPTION

C<Logger::Fq> provides an asynchronous method of logging information via Fq.
Asynchronous in that the creation of the logging and publishing to it will
never block perl (assuming an IP address is used).

=head2 Methods

=over 4

=item new()

Creates a new Logger::Fq object.

     (
       user => $user,           #default 'guest'
       password => $password,   #default 'guest'
       port => $port,           #default 8765
       host => $vhost,          #default '127.0.0.1'
			 exchange => $exchange,   #default 'logging'
       heartbeat => $hearbeat,  #default 1000 (ms)
     )

=item log( $channel, $message )

C<$channel> is the routing key used for the Fq message.

C<$message> is the message payload (binary is allowed).

=head2 Static Functions

=item Logger::Fq::backlog()

Return the number of messages backlogged.

=item Logger::Fq::drain($s)

Wait up to $us seconds (microsecond resolution) waiting for messages to drain
to 0.  Returns then number of messages drained.  If no messages are backlogged,
this method does not wait.

=item Logger::Fq::enable_drain_on_exit($s)

This will cause Logger::Fq to register an END {} function that will wait up to
$s seconds (microsecond resolution) to drain backlogged messages.

=cut

our $should_wait_on_exit;
$should_wait_on_exit = 0;
sub enable_drain_on_exit {
  $should_wait_on_exit = shift 
}

use Time::HiRes qw/gettimeofday tv_interval/;
END {
  if($should_wait_on_exit) {
    my $start = [gettimeofday];
    my $drained = Logger::Fq::drain(int($should_wait_on_exit) * 1000000);
    my $elapsed = tv_interval ( $start, [gettimeofday] );
    print STDERR "Drained $drained messages in $elapsed s.\n";
  }
}
1;
