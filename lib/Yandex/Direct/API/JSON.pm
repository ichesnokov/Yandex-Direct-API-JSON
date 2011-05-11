package Yandex::Direct::API::JSON;

use Moose;

=head1 NAME

Yandex::Direct::API::JSON - communication with Yandex Direct JSON API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use LWP::UserAgent;
use JSON::XS;

# Setup logging
use Log::Log4perl qw/ :easy /;
with 'MooseX::Log::Log4perl';
BEGIN {
    Log::Log4perl->easy_init();
}

has 'api_url' => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'https://soap.direct.yandex.ru/json-api/v3/',
    required => 1,
);

has 'api_locale' => (
    is       => 'rw',
    isa      => 'Str',
    default  => 'en',
    required => 1,
);

has 'ssl_cert_file' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'ssl_key_file' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'ssl_version'  => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'SSLv3',
    required => 1,
);

has 'verify_hostname' => (
    is       => 'ro',
    isa      => 'Int',
    default  => 0,
    required => 1,
);

has 'useragent' => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;

        LWP::UserAgent->new(
            parse_head => 0,
            env_proxy  => 1,
            agent      => 'Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 5.1; ru-RU)',
            ssl_opts   => {
                SSL_cert_file   => $self->ssl_cert_file,
                SSL_key_file    => $self->ssl_key_file,
                SSL_version     => $self->ssl_version,
                verify_hostname => $self->verify_hostname,
            }
        )
    },
    required => 1,
);

has 'coder' => (
    is       => 'rw',
    lazy     => 1,
    default  => sub {
        JSON::XS->new->utf8(1)
    },
    required => 1,
);

has 'max_logged_response_length' => (
    is       => 'rw',
    isa      => 'Int',
    default  => 10000,
    required => 1,
);



=head1 SYNOPSIS

    use Yandex::Direct::API::JSON;

    my $direct = Yandex::Direct::API::JSON->new(
        api_url       => 'https://soap.direct.yandex.ru/json-api/v3/
        ssl_cert_file => '/etc/pki/tls/certs/yandex_direct_cert.pem', 
        ssl_key_file  => '/etc/pki/tls/private/yandex_direct_key.pem',
        api_locale    => 'ru',
    );

    my $response = $direct->request({
        method => 'GetKeywordsSuggestion',
        param  => {
            Keywords => [ "bmw", "audi" ],
        },
    });

    my $phrases_ref = $response->{data};
    for my $phrase ( @{ $phrases_ref } ) {
        utf8::encode($phrase);
        print "$phrase\n";
    }


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 request

    Send API request to Yandex Direct.

=cut

sub request {
    my ($self, $content_ref) = @_;

    $content_ref->{locale} = $self->api_locale;

    my $json_request = $self->coder->encode($content_ref);

    $self->log->debug("Request: $json_request");

    my $response = $self->useragent->post( $self->api_url, Content => $json_request );

    my $content = $response->decoded_content;
    $self->log->debug( "Response length: " . length $content );

    if ( length $content < $self->max_logged_response_length ) {
        $self->log->debug("Response: $content");
    }

    if ( !$response->is_success ) {
        die "Error: " . $response->status_line;
    }

    return $self->coder->decode( $response->decoded_content );
}

=head1 AUTHOR

Ilya Chesnokov, C<< <chesnokov.ilya at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-yandex-direct-api-json at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Yandex-Direct-API-JSON>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Yandex::Direct::API::JSON


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Yandex-Direct-API-JSON>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Yandex-Direct-API-JSON>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Yandex-Direct-API-JSON>

=item * Search CPAN

L<http://search.cpan.org/dist/Yandex-Direct-API-JSON/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Ilya Chesnokov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

__PACKAGE__->meta->make_immutable;

1; # End of Yandex::Direct::API::JSON
