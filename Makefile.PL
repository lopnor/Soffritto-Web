#!perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'Soffritto-Web',
	AUTHOR => 'Nobuo Danjou <nobuo.danjou@gmail.com>',
	VERSION_FROM => 'lib/Soffritto/Web.pm',
	ABSTRACT_FROM => 'lib/Soffritto/Web.pm',
	LICENSE => 'perl',
    MIN_PERL_VERSION => 5.012000,
	PREREQ_PM => {
        Plack => '0.9980',
        'Plack::Session' => 0,
        DBI => 0,
        'DBD::SQLite' => 0,
        'SQL::Abstract::Limit' => 0,
        Encode => 0,
        'Scalar::Util' => 0,
        'Try::Tiny' => 0,
        'HTTP::Status' => 0,
        'URI::WithBase' => 0,
        'HTML::Shakan' => 0,
        'Digest::SHA1' => 0,
	},
);
