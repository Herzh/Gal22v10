
########## Tcl recorder starts at 04/19/17 07:40:42 ##########

set version "2.0"
set proj_dir "C:/Users/ALUCI/Documents/ispLEVER/gal2"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:40:42 ###########


########## Tcl recorder starts at 04/19/17 07:47:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:47:57 ###########


########## Tcl recorder starts at 04/19/17 07:48:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"sumador.vhd\" -o \"sumador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:48:18 ###########


########## Tcl recorder starts at 04/19/17 07:48:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"sumador.vhd\" -o \"sumador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:48:45 ###########


########## Tcl recorder starts at 04/19/17 07:48:51 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"sumador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:48:51 ###########


########## Tcl recorder starts at 04/19/17 07:48:54 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"multiplicador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:48:54 ###########


########## Tcl recorder starts at 04/19/17 07:49:00 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal2.sty
PROJECT: multiplicador
WORKING_PATH: \"$proj_dir\"
MODULE: multiplicador
VHDL_FILE_LIST: sumador.vhd multiplicador.vhd
OUTPUT_FILE_NAME: multiplicador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e multiplicador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete multiplicador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal2 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"multiplicador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal2.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal2.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal2.bl3 -pla -o gal2.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal2.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal2.tt3 -dev p22v10g -o gal2.jed -ivec NoInput.tmv -rep gal2.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal2 -if gal2.jed -j2s -log gal2.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:49:00 ###########


########## Tcl recorder starts at 04/19/17 07:50:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:50:26 ###########


########## Tcl recorder starts at 04/19/17 07:50:31 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"multiplicador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:50:31 ###########


########## Tcl recorder starts at 04/19/17 07:50:37 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal2.sty
PROJECT: multiplicador
WORKING_PATH: \"$proj_dir\"
MODULE: multiplicador
VHDL_FILE_LIST: sumador.vhd multiplicador.vhd
OUTPUT_FILE_NAME: multiplicador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e multiplicador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete multiplicador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal2 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"multiplicador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal2.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal2.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal2.bl3 -pla -o gal2.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal2.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal2.tt3 -dev p22v10g -o gal2.jed -ivec NoInput.tmv -rep gal2.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal2 -if gal2.jed -j2s -log gal2.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:50:37 ###########


########## Tcl recorder starts at 04/19/17 07:51:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:51:11 ###########


########## Tcl recorder starts at 04/19/17 07:51:15 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"multiplicador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:51:15 ###########


########## Tcl recorder starts at 04/19/17 07:51:20 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal2.sty
PROJECT: multiplicador
WORKING_PATH: \"$proj_dir\"
MODULE: multiplicador
VHDL_FILE_LIST: sumador.vhd multiplicador.vhd
OUTPUT_FILE_NAME: multiplicador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e multiplicador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete multiplicador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal2 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"multiplicador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal2.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal2.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal2.bl3 -pla -o gal2.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal2.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal2.tt3 -dev p22v10g -o gal2.jed -ivec NoInput.tmv -rep gal2.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal2 -if gal2.jed -j2s -log gal2.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:51:20 ###########


########## Tcl recorder starts at 04/19/17 11:01:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:01:32 ###########


########## Tcl recorder starts at 04/19/17 11:01:36 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"multiplicador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:01:36 ###########


########## Tcl recorder starts at 04/19/17 11:02:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"multiplicador.vhd\" -o \"multiplicador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:02:27 ###########


########## Tcl recorder starts at 04/19/17 11:02:31 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"multiplicador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:02:31 ###########


########## Tcl recorder starts at 04/19/17 11:02:37 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal2.sty
PROJECT: multiplicador
WORKING_PATH: \"$proj_dir\"
MODULE: multiplicador
VHDL_FILE_LIST: sumador.vhd multiplicador.vhd
OUTPUT_FILE_NAME: multiplicador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e multiplicador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete multiplicador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal2 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"multiplicador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal2.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal2.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal2.bl3 -pla -o gal2.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal2.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal2.tt3 -dev p22v10g -o gal2.jed -ivec NoInput.tmv -rep gal2.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal2 -if gal2.jed -j2s -log gal2.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:02:37 ###########

