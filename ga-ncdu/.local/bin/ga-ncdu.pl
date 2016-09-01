#!/usr/bin/env perl

package App::ga_ncdu;

use strict;
use warnings;

use File::Find qw();
use File::Spec;

use Scalar::Util qw(reftype);

if (!caller) {
    my $self = __PACKAGE__ -> new;
    $self -> main;
}

sub new {
    my $class = shift;

    my $self = bless {
        directories => {},
        path_count  => 0,
    }, $class;

    return $self;
}

sub main {
    my $self = shift;

    my $path = shift @ARGV;
    die 'Directory has not been specified' if !defined $path;
    die sprintf 'Directory "%s" does not exist', $path  if !-e $path;
    die sprintf 'Path "%s" is not a directory', $path   if !-d $path;

    my %find_arguments = (
        no_chdir    => 1,
        wanted      => sub { $self -> process_path ($_); },
    );

    File::Find::find(\%find_arguments, $path);

    $path =~ s{/\z}{}msx;
    $self -> export ($self->{'directories'}->{$path});

    return $self;
}

sub process_path {
    my ($self, $path) = @_;

    my $dir     = $File::Find::dir;
    my $file    = File::Spec -> abs2rel ($path, $dir);

    $self->{'path_count'} += 1;
    if ($self->{'path_count'} % 100 == 0) {
        printf STDERR "%i paths processed: %s\n", $self->{'path_count'}, $path;
    }

    if ($file eq '.git') {
        $File::Find::prune = 1;
    }

    my $directories = $self->{'directories'};

    if (-d $path) {
        my $array = [{
            name    => $file,
        }];

        push @{ $directories->{$dir} }, $array;
        $directories->{$path} = $array;
    }
    elsif (-l $path) {
        my $target_path = readlink($path);
        my (undef, undef, $key) = File::Spec -> splitpath ($target_path);

        my @components  = split /-/, $key;
        my $backend     = shift @components;

        my %fields;
        while ($components[0] ne '') {
            my $component       = shift @components;
            my ($field, $value) = ($component =~ m/\A (.) (.+?) \z/msx);
            $fields{$field}     = $value;
        }
        my $abs_path = File::Spec -> rel2abs ($target_path, $dir);

        push @{ $directories->{$dir} }, {
            name    => $file,
            asize   => $fields{'s'} + 0,
            dsize   => -s $abs_path || 0,
        };
    }

    return $self;
}

sub export {
    my ($self, $directory) = @_;

    $self -> export_object ([
        1,
        0, {
            progname    => 'ga-ncdu',
            progver     => '0.001_000',
            timestamp   => time,
        },
        $directory,
    ]);

    return $self;
}

sub export_object {
    my ($self, $object) = @_;

    my $type = reftype($object);

    if (!defined $type) {
        $self -> export_value ($object);
    }
    elsif ($type eq 'ARRAY') {
        $self -> export_array ($object);
    }
    elsif ($type eq 'HASH') {
        $self -> export_hash ($object);
    }
    else {
        die sprintf 'Reftype "%s" is not handled', $type;
    }

    return $self;
}

sub export_value {
    my ($self, $value) = @_;

    if (!defined $value) {
        print 'null';
    }
    elsif ($value =~ m/\A \d+? \z/msx) {
        print $value;
    }
    else {
        printf '"%s"', $self -> json_escape ($value);
    }

    return $self;
}

sub export_array {
    my ($self, $array) = @_;

    my $count = scalar @{$array};

    print '[';
    foreach my $index (0 .. $count - 1) {
        my $item = $array->[$index];
        $self -> export_object ($item);

        if ($index < $count - 1) {
            print ',';
        }
    }
    print ']';

    return $self;
}

sub export_hash {
    my ($self, $hash) = @_;

    my @keys    = keys %{$hash};
    my $count   = scalar @keys;

    print '{';
    foreach my $index (0 .. $count - 1) {
        my $key = $keys[$index];
        printf '"%s":', $key;

        if ($key eq 'name') {
            printf '"%s"', $self -> json_escape ($hash->{$key});
        }
        else {
            $self -> export_object ($hash->{$key});
        }

        if ($index < $count - 1) {
            print ',';
        }
    }
    print '}';

    return $self;
}

sub json_escape {
    my ($self, $value) = @_;

    $value =~ s{"}{\\"}gmsx;

    return $value;
}
