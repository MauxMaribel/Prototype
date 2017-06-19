use strict;

my $tile = shift @ARGV or die "provide the name of your tiles";
my $abbrev = shift @ARGV or die "provide an abbreviation for your tiles";

$tile =~ /^[a-z]+$/ or die "The tilename should be only lower-case letters";
$abbrev =~ /^[a-z][a-z][a-z]$/ or die "The abbreviation should be three lower-case letters";

my $tilesheet = sprintf("images/tiles/%s_tilesheet.png", $tile);
unless(-f $tilesheet) {
	die "Expected $tilesheet to exist with the tilesheet.";
}

print "Found tilesheet at $tilesheet.\n";

open TEMPLATE, "<data/tiles/grass.cfg" or die "Expected to find data/tiles/grass.cfg to use as a template.";

my $output = sprintf("data/tiles/%s.cfg", $tile);

open OUTPUT, ">$output" or die "Could not open $output to write to";

while(my $line = <TEMPLATE>) {
	$line =~ s/grs/$abbrev/g;
	$line =~ s/grass/$tile/g;
	print OUTPUT $line;
}

close OUTPUT;

close TEMPLATE;

print "Created $output based on data/tiles/grass.cfg\n";

open ZORDER, "<data/zorder.cfg" or die "Could not open zorders";

my $highest_zorder = -1000;

my @zorder = ();

while(my $line = <ZORDER>) {
	push @zorder, $line;
	if(my ($zorder) = $line =~ /[a-z]: ([0-9-]+),/) {
		if($zorder > $highest_zorder) {
			$highest_zorder = $zorder;
		}
	}
}

close ZORDER;

$highest_zorder += 10;

pop @zorder;
push @zorder, "	" . $tile . ": $highest_zorder,\n";
push @zorder, "}";


open OUT_ZORDER, ">data/zorder.cfg" or die "Could not write to zorders\n";
for my $line (@zorder) {
	print OUT_ZORDER $line;
}

close OUT_ZORDER;

print "Assigned a zorder of $highest_zorder ... you might want to change data/zorders.cfg to change this.\n";

my @tiles_cfg = ();

open TILES_CFG, "<data/tiles.cfg" or die "Could not read tiles.cfg";
while(my $line = <TILES_CFG>) {
	push @tiles_cfg, $line;
	if($line =~ /\{/) {
		push @tiles_cfg, sprintf('	%s: "%s.cfg",%s', $abbrev, $tile, "\n");

	}
}

close TILES_CFG;

open OUT_TILES, ">data/tiles.cfg" or die "Could not write tiles.cfg";

foreach my $line (@tiles_cfg) {
	print OUT_TILES $line;
}

close TILES_CFG;

print "Added entry to data/tiles.cfg for the new tileset\n";

my @editor = ();

open EDITOR, "<data/editor.cfg" or die "Could not open editor.cfg";
while(my $line = <EDITOR>) {
	push @editor, $line;
	if($line =~ /tileset: \[/) {
	push @editor, "
	{
		category: 'Outside',
		type: '$abbrev',
		zorder: '$tile',
		preview: {
			zorder: -1,
			tiles: '$abbrev,$abbrev,$abbrev
$abbrev,$abbrev,$abbrev
$abbrev,$abbrev,$abbrev', 
		},
	},
	";
	}
}

close EDITOR;

open OUT_EDITOR, ">data/editor.cfg" or die "Could not write editor.cfg";

foreach my $line (@editor) {
	print OUT_EDITOR $line;
}

close OUT_EDITOR;

print "Added entry to Outside section of data/editor.cfg\n";

print "All built, your new tile set should be good to go and available in the Outside section of the editor!\n";
