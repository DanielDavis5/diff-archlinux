#!/bin/perl
use strict;
use warnings;
use File::DirCompare;
use File::Spec;

my $reference = File::Spec->rel2abs("reference");
if ( !-d $reference ) {
    print 'reference directory not found.\nType "pacstrap reference base"\n';
    exit(1);
}

sub match_any {
    my ( $path, $patterns ) = @_;
    foreach (@$patterns) {
        if ( $path =~ m/$_/ ) {
            return 1;
        }
    }
    return 0;
}

sub search {
    my ( $path, $exclude ) = @_;

    File::DirCompare->compare(
        $path,
        "$reference$path",
        sub {
            my ( $a, $b ) = @_;
            if ($a) {
                if ( !match_any( $a, $exclude ) ) {
                    if ( !$b ) {
                        print "(++) $a\n";
                    }
                    else {
                        print "(!=) $a\n";
                    }
                }
            }
            elsif ($b) {
                my $str = $b =~ s/$reference//gr;
                if ( !match_any( $str, $exclude ) ) {
                    print "(--) $b\n";
                }
            }
        }
    );
}

my @include = ('/etc/');

# my $exclude = [
#     '/var/cache/', '/var/lib/',     '/usr/share/man/', '/usr/share/',
#     '/usr/lib/',   '/usr/include/', '/usr/bin/',       '/proc/',
#     '/dev/',       '/tmp/',         '/var/log/',       '/boot/',
#     '/run/',       '/usr/local/',   '/mnt/',           'lost+found'
# ];
my $exclude = [];

search $_, $exclude foreach @include;
