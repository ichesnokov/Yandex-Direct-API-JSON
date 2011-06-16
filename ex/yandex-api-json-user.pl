#!/usr/bin/perl 
use utf8;
use v5.10;
use strict;
use warnings;

use Yandex::Direct::API::JSON;

my ($ssl_cert_file, $ssl_key_file) = @ARGV;

if ( !$ssl_key_file ) {
    die "Usage: $0 SSL_CERTIFICATE_FILE SSL_KEY_FILE\n";
}

for my $file ( $ssl_cert_file, $ssl_key_file ) {
    if ( !-f $file ) {
        die "No such file: $file\n";
    }
}

my $direct = Yandex::Direct::API::JSON->new(
    ssl_cert_file => $ssl_cert_file,
    ssl_key_file  => $ssl_key_file,
    api_locale    => 'ru',
);


my $keywords_ref
    = $direct->GetKeywordsSuggestion( { Keywords => [ "тойота" ] } )->{data};

for my $phrase ( @{ $keywords_ref } ) {
    utf8::encode($phrase);
    say $phrase;
}
