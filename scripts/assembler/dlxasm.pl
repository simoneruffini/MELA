#! env perl
#
# Assemble dlx code into machine code.  This program only works for a single
# file, and generates binary code that can be loaded into a simulator.
#
# Copyright (C) 1999 by Ethan L. Miller
#
# The main data structure is the symbol table that tracks the symbols defined
# in the code.  They're defined in the first pass and used in the second
# pass.
#
# $Id: dlxasm,v 1.3 2003/10/03 08:09:20 elm Exp $
#

use Getopt::Long;

# Parse options.  These include the file to assemble, output file, and
# start locations for text (code) & data.
$pn = $0;
$pn =~ s?.*\/??g;
$debug = 0;
$asmfile = "";
$symfile = "";
$listfile = "";
$startlabel="_main";
$exefile = "";
$executable = "";
$exemagic = 0x444c5821;

sub printusageandexit {
  die ("Unrecognized option.  Correct usage is $pn <srcfile> with options:\n" .
       "\t-output <dstfile> : specify output file\n" .
       "\t-init <startsymbol> : initial location to start exeuction\n" .
       "\t-sym <symfile> : file to print a symbol table in\n" .
       "\t-list <listfile> : file to print a listing in\n" .
       "\t-debug : turn on debugging\n" .
       "NOTE: options may be specified with just the first letter if desired.\n");
};

&GetOptions ("debug" => \$debug,
	     "o=s" => \$exefile,
	     "executable=s" => \$exefile,
	     "sym=s" => \$symfile,
	     "list=s" => \$listfile,
	     "init=s" => \$startlabel,
	     "X=s" => \$asmfile,
	     "help" => \&printusageandexit,
	    );

&printusageandexit if ($#ARGV != 0);

$srcfile = pop @ARGV;
if ($srcfile =~ /^(.*)\.dlx$/) {
  $exefile = $1 . ".exe" if $exefile eq "";
} else {
  $exefile = $srcfile . ".exe" if $exefile eq "";
}

%instTbl = (
# Register-register instructions
  "sll"  => "r,0x04",
  "srl"  => "r,0x06",
  "sra"  => "r,0x07",
  "add"  => "r,0x20",
  "addu" => "r,0x21",
  "sub"  => "r,0x22",
  "subu" => "r,0x23",
  "and"  => "r,0x24",
  "or"   => "r,0x25",
  "xor"  => "r,0x26",
  "seq"  => "r,0x28",
  "sne"  => "r,0x29",
  "slt"  => "r,0x2a",
  "sgt"  => "r,0x2b",
  "sle"  => "r,0x2c",
  "sge"  => "r,0x2d",
  "movi2s" => "r2,0x30",
  "movs2i" => "r2,0x31",
  "movf" => "r2,0x32",
  "movd" => "r2,0x33",
  "movfp2i" => "r2,0x34",
  "movi2fp" => "r2,0x35",
  "movi2t" => "r,0x36",
  "movt2i" => "r,0x37",
  "sltu"  => "r,0x3a",
  "sgtu"  => "r,0x3b",
  "sleu"  => "r,0x3c",
  "sgeu"  => "r,0x3d",
# Floating-point instructions
  "addf"  => "f,0x00",
  "subf"  => "f,0x01",
  "multf" => "f,0x02",
  "divf"  => "f,0x03",
  "addd"  => "f,0x04",
  "subd"  => "f,0x05",
  "multd" => "f,0x06",
  "divd"  => "f,0x07",
  "cvtf2d" => "fd,0x08",
  "cvtf2i" => "fd,0x09",
  "cvtd2f" => "fd,0x0a",
  "cvtd2i" => "fd,0x0b",
  "cvti2f" => "fd,0x0c",
  "cvti2d" => "fd,0x0d",
  "mult"  => "f,0x0e",
  "div"   => "f,0x0f",
  "eqf"   => "f2,0x10",
  "nef"   => "f2,0x11",
  "ltf"   => "f2,0x12",
  "gtf"   => "f2,0x13",
  "lef"   => "f2,0x14",
  "gef"   => "f2,0x15",
  "multu" => "f,0x16",
  "divu"  => "f,0x17",
  "eqd"   => "f2,0x18",
  "ned"   => "f2,0x19",
  "ltd"   => "f2,0x1a",
  "gtd"   => "f2,0x1b",
  "led"   => "f2,0x1c",
  "ged"   => "f2,0x1d",
# General instructions
  "j"    => "j,0x02",
  "jal"  => "j,0x03",
  "beqz" => "b,0x04",
  "bnez" => "b,0x05",
  "bfpt" => "b0,0x06",
  "bfpf" => "b0,0x07",
  "addi" => "i,0x08",
  "addui" => "i,0x09",
  "subi" => "i,0x0a",
  "subui" => "i,0x0b",
  "andi" => "i,0x0c",
  "ori"  => "i,0x0d",
  "xori" => "i,0x0e",
  "lhi"  => "i1,0x0f",
  "rfe"  => "n,0x10",
  "trap" => "t,0x11",
  "jr"   => "jr,0x12",
  "jalr" => "jr,0x13",
  "slli" => "i,0x14",
  "nop"  => "n,0x15",
  "srli" => "i,0x16",
  "srai" => "i,0x17",
  "seqi" => "i,0x18",
  "snei" => "i,0x19",
  "slti" => "i,0x1a",
  "sgti" => "i,0x1b",
  "slei" => "i,0x1c",
  "sgei" => "i,0x1d",
  "lb"   => "l,0x20",
  "lh"   => "l,0x21",
  "lw"   => "l,0x23",
  "lbu"  => "l,0x24",
  "lhu"  => "l,0x25",
  "lf"   => "l,0x26",
  "ld"   => "l,0x27",
  "sb"   => "s,0x28",
  "sh"   => "s,0x29",
  "sw"   => "s,0x2b",
  "sf"   => "s,0x2e",
  "sd"   => "s,0x2f",
  "itlb" => "n,0x38",
  "sltui" => "i,0x3a",
  "sgtui" => "i,0x3b",
  "sleui" => "i,0x3c",
  "sgeui" => "i,0x3d",
);
%specialreg = ("pc" => 0,
	       "ir31" => 2,
	       "isr" => 3,
	       "iar" => 4,
	       "status" => 5,
	       "cause" => 6,
	       "intrvec" => 8,
	       "fault" => 9,
	       "ptbase" => 16,
	       "ptsize" => 17,
	       "ptbits" => 18,
	       "tlbentry" => 20,
	       "tlbvaddr" => 21,
	       "tlbpaddr" => 22,
	      );

# Do pass one.  In this pass, we just figure out label values.  To allow
# for relocation as late as possible, both text and data labels are
# computed as offsets from start of text or data.

$section = "t";
$start{"t"} = $start{"d"} = -1;
open (SRC, $srcfile) or die "Couldn't open $srcfile for assembly.";
open (ASM, ">$asmfile") or die "Couldn't open $asmfile for output."
  if $asmfile ne "";
open (EXE, ">$exefile") or die "Couldn't open $exefile for output." if
  $exefile ne "";
open (HDR, ">$exefile.hdr") or die "Couldn't open $exefile.hdr for output." if
  $exefile ne "";


for ($pass = 1; $pass <= 2; $pass++) {
  if ($pass != 1) {
    $maxdaddr = $addr{"d"};
    $maxtaddr = $addr{"t"};
    if (defined $val{$startlabel}) {
      $startloc = $val{$startlabel};
    } else {
      $startloc = $textstart;
    }
    $endaddr = (($maxtaddr > $maxdaddr) ? $maxtaddr : $maxdaddr);
    if ($start{"t"} == -1) {
      $start{"t"} = 0;
    }
    if ($start{"d"} == -1) {
      $start{"d"} = 0;
    }
    if ($asmfile ne "") {
      printf ASM "start:%08x %08x ", $startloc, $endaddr;
      printf (ASM "%08x %08x %08x %08x\n", $start{"t"},
	      $maxtaddr-$start{"t"}, $start{"d"}, $maxdaddr-$start{"d"});
    }
    if ($listfile ne "") {
      open (LISTING, ">$listfile") or
	die "Couldn't open $listfile for output.";
      printf LISTING "%5s  %8s\t%8s\n", "line", "address", "contents";
    }
    if ($exefile ne "") {
      $executable = "\x00" x $endaddr;
      $hdr = pack ("L*", $exemagic, $endaddr, $startloc,
		   $start{"t"}, $maxtaddr-$start{"t"},
		   $start{"d"}, $maxdaddr-$start{"d"},
		   $start{"b"}, $bsslen);
      # substr ($executable, 0, length ($hdr), $hdr);
    }
  }
  $addr{"d"} = 0;
  $addr{"t"} = 0;
  seek (SRC, 0, 0);
  print "Starting pass $pass.\n";
  $lineno = 0;
line:
  while (<SRC>) {
    $lineno++;
    $curaddr = $addr{$section};
    $out = "";
    # remove leading whitespace
    s/^\s+//;
    $curline = $_;
    chomp $curline;
    # skip comments
    if (/^\;/) {
      if (($pass == 2) and ($listfile ne "")) {
	printf LISTING "%5d  %20s%s\n", $lineno, "", $curline;
      }
      next line;
    }
    # Do an operation based on the first word on the line
    /^([a-zA-Z0-9:_.]+)/;
    if ($1 eq "") {
      next line;
    }
    $op = $1;
    print STDERR "Op is '$op'\n" if ($debug);
    if ($op =~ /^([a-zA-Z0-9_]+)\:$/) {
      if ($pass == 1) {
	# set label value
	$val{$1} = $addr{$section};
      }
    } elsif (/^[a-zA-Z]+/) {
      if ($pass == 1) {
	if ($section eq "d") {
	  warn "Instructions not allowed in data segment " .
	    "(at line $lineno)\n";
	  $error = 1;
	}
      } else {
	# Handle instructions for second pass.  This means outputting
	# the correct code.
	$out = pack ("N", &forminstr ($_));
      }
      $addr{$section} += 4;
    } elsif (/^\.(text|data)/) {
      s/\;.*$//;
      $tmp = "";
      ($section, $tmp) = split (/\s+/, $_, 3);
      $section = substr($section, 1, 1);
      if ($tmp ne "") {
	if ($tmp =~ /^0/) {
	  $addr{$section} = oct ($tmp);
	} else {
	  $addr{$section} = $tmp;
	}
	if ($start{$section} == -1) {
	  $start{$section} = $addr{$section};
	}
      }
      print "Section $section now at $addr{$section}.\n" if ($debug);
    } elsif (/^\.(proc|endproc|global)/) {
      # Ignore directives - we don't need them yet
    } elsif (/^\.space/) {
      # .space simply adds to the address pointer
      ($op, $n, $rest) = split (/\s+/, $_, 3);
      print "SPACE: line is '$_' op = $op, n = $n, rest = $rest\n" if ($debug);
      if ($section eq "t") {
	warn ".space can't be used in the text segment " .
	  "(at line $lineno)!\n";
	$error = 1;
      }
      $addr{$section} += $n;
    } elsif (/^\.ascii(z?)/) {
      $out = &getascii ($_, ($1 eq "z"));
      $addr{$section} += length ($out);
    } elsif (/^\.(byte|word|float|double)/) {
      # Add one byte for each entry.  The first "entry" is the word
      # itself, so pop it off.
      my $tp = $1;
      s /\;.*$//;
      my @args = split (/\s*,\s*/);
      $args[0] =~ s/\.[a-z]+\s+//;
      if ($tp =~ /byte|word/) {
	for ($i = 0; $i <= $#args; $i++) {
	  $args[$i] = &getimm ($args[$i]);
	}
      }
      $out = pack ("C*", @args) if ($tp eq "byte");
      $out = pack ("N*", @args) if ($tp eq "word");
      $out = pack ("f*", @args) if ($tp eq "float");
      $out = pack ("d*", @args) if ($tp eq "double");
      $addr{$section} += length ($out);
    } elsif (/^\.align/) {
      # Align so that the lowest n bits are all 0's.
      ($op, $n, $rest) = split (/\s+/, $_, 3);
      my $mask = (1 << $n) - 1;
      # This will leave things alone if the address is already
      # correctly aligned, and align to the next possible point if
      # it's not aligned.
      if (($addr{$section} & $mask) != 0) {
	$addr{$section} += $mask;
	$addr{$section} &= ~$mask;
	# Force the next line to include an address at the start
	$prevaddr = $addr{$section};
      }
    }
    if ($pass == 2) {
      if ($out ne "") {
	# Output the current value
	if ($asmfile ne "") {
	  if ($curaddr != ($prevaddr + 4)) {
	    printf (ASM "%08x", $curaddr);
	  }
	  my $data = unpack ("H*", $out);
	  my $j;
	  for ($j = 0; $j < length ($data); $j += 8) {
	    print ASM ":" . substr ($data,$j,8) . "\n";
	  }
	  $prevaddr = $curaddr;
	}
	if ($exefile ne "") {
	  substr ($executable, $curaddr, length ($out), $out);
	}
      }
      if ($listfile ne "") {
	# Generate the list of numbers to output
	my $data = unpack ("H*", $out);
	my $i = $curaddr;
	my $j;
	$data = " " if ($data eq "");
	for ($j = 0; $j < length ($data); $j += 8) {
	  printf (LISTING "%5d  %08x  %-8s\t%s\n", $lineno,
		  $i, substr ($data, $j, 8), $curline);
	  $i += 4;
	  $curline = "";
	}
      }
    }
  }
  if ($error == 1) {
    die "Errors occurred during assembly.  Exiting....\n";
  }
  if (($pass == 1) && ($symfile ne "")) {
    open (SYM, ">$symfile") or die "Couldn't open symbol file $symfile.";
    foreach $sym (sort keys %val) {
      printf SYM "%-20s %08x\n", $sym, $val{$sym};
    }
    close SYM;
  }
}

printf ("Last text address: 0x%x\n", $addr{'t'});
printf ("Last data address: 0x%x\n", $addr{'d'});

close ASM if $asmfile ne "";
print HDR $hdr if $exefile ne "";
close HDR if $exefile ne "";
print EXE $executable if $exefile ne "";
close EXE if $exefile ne "";

exit;

sub getreg {
  my $r = lc (@_[0]);
  my $rnum = -1;
  if ($r =~ /^[f$r]([0-9]+)/) {
    $rnum = $1;
  } elsif (defined $specialreg{$r}) {
    $rnum = $specialreg{$r};
  }
  if ($rnum == -1) {
    warn "Illegal register number ($r) at line $lineno.\n";
    $rnum = 0;
  }
  return ($rnum);
}

sub getimm {
  my $imm = @_[0];
  $imm =~ s/#//g;
  my @p = split (/\b/, $imm);
  my ($ival, $i);
  for ($i = 0; $i <= $#p; $i++) {
    if ($p[$i] =~ /^[_a-zA-Z]/) {
      # Look up value in symbol table, and replace it
      if (! defined ($val{$p[$i]})) {
	if ($pass != 1) {
	  warn "Undefined symbol: $p[$i]\n";
	}
	$p[$i] = 0;
      } else {
	$p[$i] = $val{$p[$i]};
      }
    }
  }
  $ival = eval (join ("", @p));
  return ($ival);
}

sub forminstr {
  my ($itype, $op);
  my ($src1, $src2, $dst, $out);
  my @a;
  chomp @_[0];
  @_[0] =~ s/\;.*$//;
  @a = split (/[\s,]+/, @_[0]);
  ($itype,$op) = split (/,/, $instTbl{$a[0]});
  $itype = lc ($itype);
  if ($itype eq "") {
    warn "Illegal instruction ($a[0]) at line $lineno\n";
  }
  $op = hex ($op);
  if ($itype =~ /^r/) {
    $src1 = &getreg ($a[2]);
    if ($itype eq "r") {
      $src2 = &getreg ($a[3]);
    } else {
      $src2 = 0;
    }
    $dst = &getreg ($a[1]);
    $out = 0x00000000 | ($src1 << 21) | ($src2 << 16) | ($dst << 11) |
      $op;
  } elsif ($itype eq "i") {
    $src1 = &getreg ($a[2]);
    $dst = &getreg ($a[1]);
    $src2 = &getimm ($a[3]);
    $out = ($op << 26) | ($src1 << 21) | ($dst << 16) | ($src2 & 0xffff);
  } elsif ($itype eq "i1") {
    # Immediates with a single operand
    $dst = &getreg ($a[1]);
    $src2 = &getimm ($a[2]);
    $out = ($op << 26) | ($dst << 16) | ($src2 & 0xffff);
  } elsif ($itype eq "n") {
    # Instructions with no operands
    $out = ($op << 26);
  } elsif (($itype eq "s") || ($itype eq "l")) {
    # load and store operations
    if ($itype eq "s") {
      $src1 = $a[1];
      $dst = &getreg ($a[2]);
    } else {
      $src1 = $a[2];
      $dst = &getreg($a[1]);
    }
    $src1 =~ /(.*)\((r[0-9]+)\)$/;
    if ($1 ne "") {
      $src2 = &getimm ($1);
    } else {
      $src2 = 0;
    }
    $src1 = &getreg ($2);
    $out = ($op << 26) | ($src1 << 21) | ($dst << 16) | ($src2 & 0xffff);
  } elsif ($itype =~ /^f/) {
    # floating point operations
    if ($itype eq "f") {
      $dst = &getreg ($a[1]);
      $src1 = &getreg ($a[2]);
      $src2 = &getreg ($a[3]);
    } elsif ($itype eq "f2") {
      $src1 = &getreg ($a[1]);
      $src2 = &getreg ($a[2]);
      $dst = 0;
    } else {
      # type fd
      $dst = &getreg ($a[1]);
      $src1 = &getreg ($a[2]);
      $src2 = 0;
    }
    $out = 0x04000000 | ($src1 << 21) | ($src2 << 16) | ($dst << 11) | $op;
  } elsif ($itype =~ /^b/) {
    if ($itype eq "b") {
      $src1 = &getreg ($a[1]);
      $dst = &getimm ($a[2]);
    } else {	# b0 - branches w/o operands
      $src1 = 0;
      $dst = &getimm ($a[1]);
	   }
    $dst -= $addr{t} + 4;
    $out = ($op << 26) | ($src1 << 21) | ($dst & 0xffff);
  } elsif ($itype eq "j") {
    $dst = &getimm ($a[1]);
    $dst -= $addr{t} + 4;
    $out = ($op << 26) | ($dst & 0x3ffffff);
  } elsif ($itype eq "jr") {
    $dst = &getreg ($a[1]);
    $out = ($op << 26) | ($dst << 21);
  } elsif ($itype eq "t") {
    $dst = &getimm ($a[1]);
    $out = ($op << 26) | ($dst & 0x3ffffff);
  }
  return ($out);
}

sub getascii {
  local $val;
  local $str = @_[0];
  local $zpad = @_[1];
  $str =~ s/^\.ascii(z?)\s+//;
  $str = "\$val = " . $str;
  eval ($str);
  local $pstr = "a*";
  $pstr = "a*x" if ($zpad);
  return (pack ($pstr, $val));
}
