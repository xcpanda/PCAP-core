##########LICENCE##########
# PCAP - NGS reference implementations and helper code for the ICGC/TCGA Pan-Cancer Analysis Project
# Copyright (C) 2014-2018 ICGC PanCancer Project
# Copyright (C) 2018-2021 Cancer, Ageing and Somatic Mutation, Genome Research Limited
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not see:
#   http://www.gnu.org/licenses/gpl-2.0.html
##########LICENCE##########

# this is a catch all to ensure all modules do compile
# added as lots of 'use' functionality is dynamic in pipeline
# and need to be sure that all modules compile.
# simple 'perl -c' is unlikely to work on head scripts any more.

use strict;
use Data::Dumper;
use Test::More;
use List::Util qw(first);
use File::Find;
use Cwd;
use Try::Tiny qw(try finally);
use File::Spec;

use FindBin qw($Bin);
my $lib_path = "$Bin/../lib";

# Add modules here that cannot be instantiated (should be extended and have no 'new')
# or need a set of inputs - these should be tested in own test script
use constant MODULE_SKIP => qw(PCAP::Threaded PCAP::Bwa::Meta PCAP::Bam::Bas PCAP::Bam::Coverage PCAP::Bam::Stats);


my $init_cwd = getcwd;

my @modules;
try {
  chdir($lib_path);
  find({ wanted => \&build_module_set, no_chdir => 1 }, './');
} finally {
  chdir $init_cwd;
  die "The try block died with: @_\n" if(@_);
};

for my $mod(@modules) {
  use_ok($mod) or BAIL_OUT("Unable to 'use' module $mod");
}

for my $mod(@modules) {
  ok($mod->VERSION, "Check version inheritance exists ($mod)");
  if($mod->can('new')) { # only try new on things that have new defined
    new_ok($mod) unless( first {$mod eq $_} MODULE_SKIP );
  }
}

done_testing();

sub build_module_set {
  if($_ =~ m/\.pm$/) {

    my ($dir_str,$file) = (File::Spec->splitpath( $_ ))[1,2];
    $file =~ s/\.pm$//;
    my @dirs = File::Spec->splitdir( $dir_str );
    shift @dirs;
    push @modules, (join '::', @dirs).$file;
  }
}
