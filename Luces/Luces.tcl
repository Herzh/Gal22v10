
########## Tcl recorder starts at 04/05/17 18:13:38 ##########

set version "2.0"
set proj_dir "C:/Users/ALUCI/Documents/ispLEVER/Luces"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:13:38 ###########


########## Tcl recorder starts at 04/05/17 18:18:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:18:38 ###########


########## Tcl recorder starts at 04/05/17 18:19:49 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:19:49 ###########


########## Tcl recorder starts at 04/05/17 18:20:37 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:20:37 ###########


########## Tcl recorder starts at 04/05/17 18:31:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:31:14 ###########


########## Tcl recorder starts at 04/05/17 18:31:37 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:31:37 ###########


########## Tcl recorder starts at 04/05/17 18:31:46 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:31:46 ###########


########## Tcl recorder starts at 04/05/17 18:33:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:33:34 ###########


########## Tcl recorder starts at 04/05/17 18:34:27 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:34:27 ###########


########## Tcl recorder starts at 04/05/17 18:34:33 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:34:33 ###########


########## Tcl recorder starts at 04/05/17 18:36:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:36:24 ###########


########## Tcl recorder starts at 04/05/17 18:36:30 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:36:30 ###########


########## Tcl recorder starts at 04/05/17 18:36:36 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:36:36 ###########


########## Tcl recorder starts at 04/05/17 18:39:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:39:49 ###########


########## Tcl recorder starts at 04/05/17 18:40:07 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:40:07 ###########


########## Tcl recorder starts at 04/05/17 18:40:20 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:40:20 ###########


########## Tcl recorder starts at 04/05/17 18:49:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:49:01 ###########


########## Tcl recorder starts at 04/05/17 18:49:05 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:49:05 ###########


########## Tcl recorder starts at 04/05/17 18:49:12 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:49:12 ###########


########## Tcl recorder starts at 04/05/17 18:50:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:50:57 ###########


########## Tcl recorder starts at 04/05/17 18:51:00 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:51:00 ###########


########## Tcl recorder starts at 04/05/17 18:51:06 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:51:06 ###########


########## Tcl recorder starts at 04/05/17 18:56:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:56:36 ###########


########## Tcl recorder starts at 04/05/17 18:56:52 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:56:52 ###########


########## Tcl recorder starts at 04/05/17 18:57:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:57:02 ###########


########## Tcl recorder starts at 04/05/17 18:57:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:57:38 ###########


########## Tcl recorder starts at 04/05/17 18:57:42 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:57:42 ###########


########## Tcl recorder starts at 04/05/17 18:57:47 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:57:47 ###########


########## Tcl recorder starts at 04/05/17 18:58:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:58:33 ###########


########## Tcl recorder starts at 04/05/17 18:58:37 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:58:37 ###########


########## Tcl recorder starts at 04/05/17 18:58:43 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:58:43 ###########


########## Tcl recorder starts at 04/05/17 18:59:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:59:48 ###########


########## Tcl recorder starts at 04/05/17 18:59:51 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:59:51 ###########


########## Tcl recorder starts at 04/05/17 18:59:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:59:57 ###########


########## Tcl recorder starts at 04/05/17 19:00:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 19:00:34 ###########


########## Tcl recorder starts at 04/05/17 19:00:39 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"luces\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 19:00:39 ###########


########## Tcl recorder starts at 04/05/17 19:00:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [catch {open luces.cmd w} rspFile] {
	puts stderr "Cannot create response file luces.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: luces.sty
PROJECT: luces
WORKING_PATH: \"$proj_dir\"
MODULE: luces
VHDL_FILE_LIST: luces.vhd
OUTPUT_FILE_NAME: luces
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e luces -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete luces.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"luces.edi\" -out \"luces.bl0\" -err automake.err -log \"luces.log\" -prj luces -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"luces.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"luces.bl1\" -o \"luces.bl2\" -omod luces -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" luces.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" luces.bl3 -pla -o luces.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" luces.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" luces.tt3 -dev p22v10g -o luces.jed -ivec NoInput.tmv -rep luces.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj luces -if luces.jed -j2s -log luces.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 19:00:44 ###########


########## Tcl recorder starts at 04/05/17 19:12:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"luces.vhd\" -o \"luces.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 19:12:31 ###########

