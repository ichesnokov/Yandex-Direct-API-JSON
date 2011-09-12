use inc::Module::Install;

name     'Yandex-Direct-API-JSON';
all_from 'lib/Yandex/Direct/API/JSON.pm';
license  'perl';

build_requires 'Test::More';
requires 'Moose';
requires 'MooseX::Log::Log4perl';
requires 'LWP::UserAgent' => '6.00';
requires 'JSON::XS';

auto_install;

WriteAll;

