log_progress "ENTERING BUILD SCRIPT: MUDDLE"

# STINK 121T, used to build Muddle
respond "*" ":midas mudsys;ts stink_sysen2;stink 121t\r"
expect ":KILL"

mkdir "mudsav"

proc build_muddle {dir version} {
	respond "*" ":cwd $dir\r"

	respond "*" ":xfile mud$version assem\r"
	expect -timeout 300 "Assembly done!"

	respond "*" ":mudsys;stink\r"
	respond "STINK." "MMUD$version STINK\033@\033\033"
	expect  "SETPUR"
	respond "\n" "D\033\033"
	respond "\n" ":xfile mud$version init\r"
	expect -timeout 100 "Init done!"
}

build_muddle "muds54" "54"
build_muddle "mudsys" "56"

# Generate SAV FILE and FIXUP FILE for Muddle pure code library
respond "*" ":midas mudsys; ts mksvfl_mudsys;mksvfl\r"
expect ":KILL"

# Run mksvfl to create pure library for MDL 54 for the purposes of the 500-point zork
respond "*" ":mudsys;mksvfl\r"
expect ":KILL"

respond "*" ":midas sys3; ts mudinq_sysen2; mudinq\r"
expect ":KILL"
respond "*" ":link sys3; ts purge, sys3; ts mudinq\r"
respond "*" ":link sys3; ts makscr, sys3; ts mudinq\r"
respond "*" ":link sys3; ts status, sys3; ts mudinq\r"
respond "*" ":link sys3; ts whomud, sys3; ts mudinq\r"

respond "*" ":link sys3; ts mdl,mudsav; ts mud56\r"
respond "*" ":link sys3; ts muddle,mudsav; ts mud56\r"

respond "*" ":midas sys3; ts mudcom_sysen3; mudcom\r"
respond "(Y OR N)" "Y\r"
expect ":KILL"
respond "*" ":link sys3; ts mudchk, sys3; ts mudcom\r"
respond "*" ":link sys3; ts mudlst, sys3; ts mudcom\r"
respond "*" ":link sys3; ts mudfnd, sys3; ts mudcom\r"

respond "*" ":midas sys3; ts combat_sysen3; combat\r"
respond "(Y OR N)" "Y\r"
expect ":KILL"

respond "*" ":midas sys3; ts pick_sysen2; pick\r"
expect ":KILL"

respond "*" ":link sys1;ts mud55,mudsav;ts mud55\r"

#Build Muddle PCOMP compiler.
respond "*" ":midas sys1;ts pcomp_mudsys;subsys maker\r"
respond "Type in Subsystem (Save File) name:" "pcomp\r"
respond "Type Y if you wish to have Save File directly restored:" "y\r"
respond "Type Second Name of Save File:" "55save\r"
respond "Type Sname of Save File:" "mudsav\r"
expect ":KILL"

#Build Muddle ASSEM assembler.
respond "*" ":midas sys1;ts assem_mudsys;subsys maker\r"
respond "Type in Subsystem (Save File) name:" "assem\r"
respond "Type Y if you wish to have Save File directly restored:" "y\r"
respond "Type Second Name of Save File:" "55save\r"
respond "Type Sname of Save File:" "mudsav\r"
expect ":KILL"

mkdir "mbprog"
respond "*" ":assem \"mprog2;lsrtns >\" \"mbprog;lsrtns nbin\"\r"
expect ":KILL"
