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
use Try::Tiny qw(try catch);
use autodie qw(:all);
use File::Find;

use FindBin qw($Bin);
my $script_path = "$Bin/../bin";

use constant COMPILE_SKIP => qw();

my $perl = $^X;

my @scripts;
find({ wanted => \&build_path_set, no_chdir => 1 }, $script_path);

for(@scripts) {
  my $script = $_;
  if( first {$script =~ m/$_$/} COMPILE_SKIP ) {
    note("SKIPPING: Script with known issues: $script");
    next;
  }
  my $message = "Compilation check: $script";
  my $command = "$perl -c $script";
  my ($pid, $process);
  try {
    $pid = open $process, $command.' 2>&1 |';
    while(<$process>){};
    close $process;
    pass($message);
  }
  catch {
    fail($message);
  };
}

done_testing();

sub build_path_set {
  push @scripts, $_ if($_ =~ m/\.pl$/);
}
