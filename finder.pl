#!/usr/bin/perl

use strict;
use warnings;
use HTML::TreeBuilder;
use XML::LibXML;

my $filename = $ARGV[0]; # source file
if($filename !~ /html$/i){
	die "Source file $filename is not HTML";
}
my $filename2 = $ARGV[1]; # file to search
if($filename !~ /html$/i){
	die "Destination file $filename2 is not HTML";
}

my $pattern;
if( defined($ARGV[2]) ){ # optional id to search
	$pattern = $ARGV[2];
}else{
	$pattern = 'make-everything-ok-button';
}


my $tree = HTML::TreeBuilder->new_from_file($filename) or die "Invalid file: $filename"; # broken first file

my $data = {};
my $atag = $tree->look_down('id' => $pattern);  # collect properties of source Tag
if($atag) {
	$data->{'id'} = $atag->attr('id');
	$data->{'class'} = $atag->attr('class');
	$data->{'href'} = $atag->attr('href');
	$data->{'title'} = $atag->attr('title');
	$data->{'rel'} = $atag->attr('rel');
	$data->{'onclick'} = $atag->attr('onclick');
	$data->{'tag'} = $atag->attr('_tag');
} else {
	die "No match in source: $filename"; # source Tag is invalid
}
$tree->delete;

  
my $posibles = {};
my $tree2 = HTML::TreeBuilder->new_from_file($filename2) or die "Invalid file: $filename2"; # broken second file
foreach my $atag2 ( $tree2->look_down( _tag => $data->{'tag'}) ) { #search potential candidates in destination
	$posibles->{$atag2->starttag()}->{'count'} = 0;
	$posibles->{$atag2->starttag()}->{'reason'} = '';
	$posibles->{$atag2->starttag()}->{'path'} = $data->{'tag'};
	if(defined($atag2->attr('id')) and ($atag2->attr('id') eq $data->{'id'}) ){
		$posibles->{$atag2->starttag()}->{'count'} = 100;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same Id ('. $data->{'id'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@id="'. $data->{'id'} .'"]';
	}
	if(defined($atag2->attr('class')) and ($atag2->attr('class') eq $data->{'class'}) ){
		$posibles->{$atag2->starttag()}->{'count'}++;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same class ('. $data->{'class'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@class="'. $data->{'class'} .'"]';
	}
	if(defined($atag2->attr('href')) and ($atag2->attr('href') eq $data->{'href'}) ){
		$posibles->{$atag2->starttag()}->{'count'}++;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same href ('. $data->{'href'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@href="'. $data->{'href'} .'"]';
	}
	if(defined($atag2->attr('title')) and ($atag2->attr('title') eq $data->{'title'}) ){
		$posibles->{$atag2->starttag()}->{'count'}++;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same title ('. $data->{'title'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@title="'. $data->{'title'} .'"]';
	}
	if(defined($atag2->attr('rel')) and ($atag2->attr('rel') eq $data->{'rel'}) ){
		$posibles->{$atag2->starttag()}->{'count'}++;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same rel ('. $data->{'rel'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@rel="'. $data->{'rel'} .'"]';
	}
	if(defined($atag2->attr('onclick')) and ($atag2->attr('onclick') eq $data->{'onclick'}) ){
		$posibles->{$atag2->starttag()}->{'count'}++;
		$posibles->{$atag2->starttag()}->{'reason'} .= ' Same onclick ('. $data->{'onclick'} .').';
		$posibles->{$atag2->starttag()}->{'path'} .= ' [./@onclick="'. $data->{'onclick'} .'"]';
	}
}
$tree2->delete;

my $probable_count = 0;
my $probable_tag = "";
my $always_reason = 'Same Tag Type ('. $data->{'tag'} .').';
my $probable_reason = '';
my $search_path = '';
my $probable_path = '';

foreach my $lkey (keys %{$posibles}) { # Finding best candidate
	if($posibles->{$lkey}->{'count'} > $probable_count){
		$probable_count = $posibles->{$lkey}->{'count'};
		$probable_tag = $lkey;
		$probable_reason = $always_reason . $posibles->{$lkey}->{'reason'};
		$search_path = $posibles->{$lkey}->{'path'};
	}
}

open(my $fh, '>>', 'result.txt') or die "Can't open file: result.txt";

my $header ="Result '$filename' vs '$filename2', ID '$pattern':";
my $dataprint;
if($probable_count){ # Print results
	#Search for path of candidate
	my $doc = XML::LibXML->load_xml(location => $filename2);
	foreach my $node ($doc->findnodes('//'. $search_path)) {
		$probable_path = $node->nodePath();
	}
	$dataprint = "$header\nProbable Tag in $filename2: $probable_tag\nReason: $probable_reason\nPath to Tag: $probable_path\n\n";
	print $fh $dataprint;
	print $dataprint;
}else{
	$dataprint = "$header\nNo match Tag found in destination: $filename2\n\n";
	print $fh $dataprint;
	print $dataprint;
}

close $fh;
