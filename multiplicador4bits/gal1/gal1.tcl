
########## Tcl recorder starts at 04/19/17 07:14:27 ##########

set version "2.0"
set proj_dir "C:/Users/ALUCI/Documents/ispLEVER/gal1"
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

########## Tcl recorder end at 04/19/17 07:14:27 ###########


########## Tcl recorder starts at 04/19/17 07:16:27 ##########

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

########## Tcl recorder end at 04/19/17 07:16:27 ###########


########## Tcl recorder starts at 04/19/17 07:16:36 ##########

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

########## Tcl recorder end at 04/19/17 07:16:36 ###########


########## Tcl recorder starts at 04/19/17 07:16:47 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
PROJECT: multiplicador
WORKING_PATH: \"$proj_dir\"
MODULE: multiplicador
VHDL_FILE_LIST: multiplicador.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:16:47 ###########


########## Tcl recorder starts at 04/19/17 07:18:10 ##########

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

########## Tcl recorder end at 04/19/17 07:18:10 ###########


########## Tcl recorder starts at 04/19/17 07:18:45 ##########

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

########## Tcl recorder end at 04/19/17 07:18:45 ###########


########## Tcl recorder starts at 04/19/17 07:18:55 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/vhd2jhd\" \"sumador.vhd\" -o \"sumador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/naf2sym\" \"sumador\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:18:55 ###########


########## Tcl recorder starts at 04/19/17 07:19:03 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:19:03 ###########


########## Tcl recorder starts at 04/19/17 07:20:37 ##########

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

########## Tcl recorder end at 04/19/17 07:20:37 ###########


########## Tcl recorder starts at 04/19/17 07:20:46 ##########

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

########## Tcl recorder end at 04/19/17 07:20:46 ###########


########## Tcl recorder starts at 04/19/17 07:20:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:20:54 ###########


########## Tcl recorder starts at 04/19/17 07:23:24 ##########

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

########## Tcl recorder end at 04/19/17 07:23:24 ###########


########## Tcl recorder starts at 04/19/17 07:23:33 ##########

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

########## Tcl recorder end at 04/19/17 07:23:33 ###########


########## Tcl recorder starts at 04/19/17 07:23:41 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:23:41 ###########


########## Tcl recorder starts at 04/19/17 07:26:53 ##########

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

########## Tcl recorder end at 04/19/17 07:26:53 ###########


########## Tcl recorder starts at 04/19/17 07:26:57 ##########

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

########## Tcl recorder end at 04/19/17 07:26:57 ###########


########## Tcl recorder starts at 04/19/17 07:27:06 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:27:06 ###########


########## Tcl recorder starts at 04/19/17 07:27:39 ##########

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

########## Tcl recorder end at 04/19/17 07:27:39 ###########


########## Tcl recorder starts at 04/19/17 07:27:44 ##########

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

########## Tcl recorder end at 04/19/17 07:27:44 ###########


########## Tcl recorder starts at 04/19/17 07:27:50 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:27:50 ###########


########## Tcl recorder starts at 04/19/17 07:31:04 ##########

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

########## Tcl recorder end at 04/19/17 07:31:04 ###########


########## Tcl recorder starts at 04/19/17 07:31:18 ##########

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

########## Tcl recorder end at 04/19/17 07:31:18 ###########


########## Tcl recorder starts at 04/19/17 07:31:28 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 07:31:28 ###########


########## Tcl recorder starts at 04/19/17 11:06:34 ##########

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

########## Tcl recorder end at 04/19/17 11:06:34 ###########


########## Tcl recorder starts at 04/19/17 11:06:43 ##########

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

########## Tcl recorder end at 04/19/17 11:06:43 ###########


########## Tcl recorder starts at 04/19/17 11:06:49 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open multiplicador.cmd w} rspFile] {
	puts stderr "Cannot create response file multiplicador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal1.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"multiplicador.edi\" -out \"multiplicador.bl0\" -err automake.err -log \"multiplicador.log\" -prj gal1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"multiplicador.bl1\" -o \"gal1.bl2\" -omod multiplicador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" gal1.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal1.bl3 -pla -o gal1.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal1.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal1.tt3 -dev p22v10g -o gal1.jed -ivec NoInput.tmv -rep gal1.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal1 -if gal1.jed -j2s -log gal1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/19/17 11:06:49 ###########

