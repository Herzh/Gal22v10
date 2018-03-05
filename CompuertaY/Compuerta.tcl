
########## Tcl recorder starts at 04/05/17 17:47:48 ##########

set version "2.0"
set proj_dir "C:/Users/ALUCI/Documents/ispLEVER"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" \"compuertay.vhd\" -o \"compuertay.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 17:47:48 ###########


########## Tcl recorder starts at 04/05/17 17:50:48 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"entY\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 17:50:48 ###########


########## Tcl recorder starts at 04/05/17 17:54:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"compuertay.vhd\" -o \"compuertay.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 17:54:52 ###########


########## Tcl recorder starts at 04/05/17 18:02:26 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/exp\" -lhdl -ext=.ltv -testpt simy.wdl -network=compuerta"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open entY.cmd w} rspFile] {
	puts stderr "Cannot create response file entY.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: compuerta.sty
PROJECT: entY
WORKING_PATH: \"$proj_dir\"
MODULE: entY
VHDL_FILE_LIST: compuertay.vhd
OUTPUT_FILE_NAME: entY
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e entY -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entY.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"entY.edi\" -out \"entY.bl0\" -err automake.err -log \"entY.log\" -prj compuerta -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"entY.bl0\" -o \"entY.blo\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"entY.blo\" -o \"compuerta.blh\" -omod compuerta -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"compuerta.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"compuerta.bli\" -o \"compuerta.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaig_pvhd.fdk \"simy.ltv\" -map \"entY.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:02:26 ###########


########## Tcl recorder starts at 04/05/17 18:05:16 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/iblifopt\" \"entY.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"entY.bl1\" -o \"compuerta.bl2\" -omod entY -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" compuerta.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" compuerta.bl3 -pla -o compuerta.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" compuerta.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" compuerta.tt3 -dev p22v10g -o compuerta.jed -ivec NoInput.tmv -rep compuerta.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj compuerta -if compuerta.jed -j2s -log compuerta.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/05/17 18:05:17 ###########

