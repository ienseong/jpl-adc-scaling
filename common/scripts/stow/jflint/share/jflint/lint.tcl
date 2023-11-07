#=========================
# Buu Huynh
# Mentor Graphics Corp. 2015-05-02
# REVISION 1.1
# hds_map_libs_import_run_dc.tcl
#=========================
# 1. Creates a temp HDL Designer project workspace, named HDS
# 2. Imports in a design, controlled by a filelist text file
#
#=========================
puts "Starting lint.tcl"
set WORKSPACE [file normalize $::env(WORK_DIR)]
#=========================
# Buu Huynh
# Mentor Graphics Corp. 2010-10-29
# Updated script to save in the run log report the fully qualified pathnames
# of the User Preferences, Policy, & Ruleset used.
#=========================
puts "\n\n\n"
puts "========================================================================================="
puts "=================== IMPORTANT DesignChecker RUN INFORMATION BELOW ======================="
puts "=========================================================================================\n"
puts "HDL Designer - DesignChecker analysis workspace directory is set to:\n$WORKSPACE\n"
puts "HDS_USER_HOME is set to:\n[file normalize $::env(HDS_USER_HOME)]\n"
puts "HDS_POLICY_DIR is set to:\n[file normalize $::env(HDS_POLICY_DIR)]\n"
puts "HDS_RULESET_DIR is set to:\n[file normalize $::env(HDS_RULESET_DIR)]\n\n"
#=========================================================================================
# Buu Huynh
# Mentor Graphics Corp. 2010-06-17
# Updated script to use 3 user entered parameter fields from the launch batch call.
#
#============
set PROJ_NAME $::env(PROJ_NAME)
set TOP_LEVEL $::env(TOP_LEVEL)
#set FILENAME [file normalize $::env(FILELIST)]
# The following assigns which DesignChecker Rule Policy to apply to the analysis run
set POLICY $::env(RULES_POLICY)
set PLUS_DEFINES $::env(PLUS_DEFINES)
set BLACKBOX $::env(BLACKBOX)
#=========================
# Buu Huynh
# Mentor Graphics Corp. 2010-10-29
# Updated script to save in the run log report the DesignChecker Policy name,
# the design project, and filelist used.
#=========================
puts "\n\n\n"
puts "========================================================================================="
puts "=================== IMPORTANT DesignChecker RUN INFORMATION BELOW ======================="
puts "=========================================================================================\n"
puts "This DesignChecker analysis run's POLICY is set to:\n$POLICY\n"
#puts "This DesignChecker run analyzed source code specified by the FILELIST:\n$FILENAME\n"
puts "=========================================================================================\n\n"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PROC DEF's <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#=========================================================================================
#>>>>>>> PROCEDURE:        setDontTouchLib_DC
#>>>>>>> Expected Args:    library (type: HDL Designer handle)
#
#>>  B.L.Huynh        (2013-10-22)
#>>  This procedure sets the HDL Designer Don't Touch property for DesignChecker   <<
#>>  parsing on ALL design source files contained in the library designated by the <<
#>>  input "lib" argument.                                                         <<
#=========================================================================================
proc setDontTouchLib_DC {lib} {
  set libName [$lib configure name]
  foreach file [$lib files] {
    puts "Setting DesignChecker DON'T TOUCH property for: [$file configure relativePathname]"
    set fileRef [$file configure relativePathname]
    puts "File reference name = $fileRef"
    setDontTouchFile $libName $fileRef -libraryPath -tool DESIGNCHECKER
  }
  puts "Finish DesignChecker DON'T TOUCH property for LIBRARY: [$lib configure name]"
}
#=========================================================================================
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End of PROC DEF's <<<<<<<<<<<<<<<<<<<<<<<<<<<<

#=========================================================================================
#                 XILINX unisim library pre-mapping for VHDL
#>>>>>>>  POINT TO COMP PACKAGE file in XILINX installation area
#>>>>>>>  Additional Xilinx library files pointed to:
#>>>>>>>          unisim vital, primitive, secureip
#=========================================================================================
# set XILINX_ROOT [set ::env(XILINX_ROOT)]
# addLibraryMapping unisim -hdl $XILINX_ROOT/ISE_DS/ISE/vhdl/src/unisims
# addLibraryMapping unisim -hds $WORKSPACE/$PROJ_NAME/xlx_unisim/hds
#
#>>>>>>>   Assign DON'T TOUCH propery to the Xilinx unisim VHDL lib files  <<<<<<<<<
#>>>>>>>   For all files under directories: unisims/primitive/, unisims/secureip/
#>>>>>>>   and the file unisim_VPKG.vhd (VITAL file)
# set LIBR1 [library open unisim]
# puts "Open LIBRARY: [$LIBR1 configure name]"
# setDontTouchLib_DC $LIBR1
#
#=========================================================================================
#                 ACTEL Axcelerator library pre-mapping for VHDL
#>>>>>>>  Copy from the Actel Libero tool installation directory tree the required VHDL
#>>>>>>>  declaration files - component PACKAGE & Vital (entity) declaration files
#=========================================================================================
set ACTEL_ROOT [set ::env(ACTEL_ROOT)]
addLibraryMapping axcelerator -hdl $WORKSPACE/$PROJ_NAME/axcelerator/hdl
addLibraryMapping axcelerator -hds $WORKSPACE/$PROJ_NAME/axcelerator/hds
#
setupHdlImport -importDirectoryStructure ON
setupHdlImport -importReferencedText ON
setupHdlImport -overwrite ON
setupHdlImport -defaultVerilogDialect SYSTEM_VERILOG_2002
#
#>>>>>>>   Copy in the Actel Axcelerator VITAL & Axcelerator package files:
#>>>>>>>     comps.vhd       (from ../Libero_vX.Y/Designer/lib/actel/vhdl/ax/)
#>>>>>>>     axcelerator.vhd (from ../Libero_vX.Y/Designer/lib/vtl/95/)
#
# JB modify path 5/515
#runHdlImport axcelerator $ACTEL_ROOT/Designer/lib/actel/vhdl/ax/comps.vhd $ACTEL_ROOT/Designer/lib/vtl/95/axcelerator.vhd
#runHdlImport axcelerator $ACTEL_ROOT/lib/actel/vhdl/ax/comps.vhd $ACTEL_ROOT/lib/vtl/95/axcelerator.vhd
#
#>>>>>>>   Assign DON'T TOUCH propery to the Actel Axcelerator VHDL lib files
#>>>>>>>   Files in this library:
#set LIBR2 [library open axcelerator]
#puts "Open LIBRARY: [$LIBR2 configure name]"
#setDontTouchLib_DC $LIBR2
#
#=========================================================================================
#          Change all FPGA vendor libraries to "Protected" library type
#>>>>>>>     First we need to close the openned libs before changes       <<<<<<<<<
#>>>>>>>     can be made to their mapping type setup.                     <<<<<<<<<
#=========================================================================================
proc onUserAsk {type title prompt severity} {return YES}
    catch {::CvTcl::captureAsk onUserAsk}
    catch {::Browser::closeAllTabs}
    catch {::CvTcl::captureAsk {}}
#
#>>>>>>>   Change unisim library to "Protected" library type
# addLibraryMapping unisim -protected -all
#>>>>>>>   Change Axcelerator library to "Protected" library type
addLibraryMapping axcelerator -protected -all
#
#
#=========================================================================================
#             DESIGN IMPORT, OPTION-1: POINT TO DESIGN DIRECTORY TREE
#>>>>>>>  The following is the main HDL Designer project's library mapping       <<<<<<<<<
#=========================================================================================
 set SBOX [set ::env(SBOX)]
 set TOP [set ::env(TOP_LEVEL)]
 set FILELIST [set ::env(FILELIST)]
 #addLibraryMapping $PROJ_NAME -hdl $SBOX
 #addLibraryMapping $PROJ_NAME -hds $WORKSPACE/$PROJ_NAME/hds

#=========================================================================================
#         DESIGN IMPORT, OPTION-2: USE ASCII FILE LIST TO CALL OUT DESIGN FILES
#>>>>>>>  The following is the main HDL Designer project's library mapping       <<<<<<<<<
#=========================================================================================
addLibraryMapping $PROJ_NAME -hdl $WORKSPACE/$PROJ_NAME/work/hdl -hds $WORKSPACE/$PROJ_NAME/work/hds
#
#=========================================================================================
#set LIBR3 [library open $PROJ_NAME.]
#puts "COPYING - design files into LIBRARY: [$LIBR3 configure name]"
#=========================================================================================
#>>>>>>> Setup options for VHDL files import
#setupHdlImport -importDirectoryStructure ON
#
#>>>>>>> Setup options for VHDL files import,
#>>>>>>> copy in source files into $WORKSPACE/hdl directory area
#setupHdlImport -importReferencedText OFF
#
#>>>>>>> Setup options for VHDL files import
#setupHdlImport -overwrite ON
#
#>>>>>>> Run the import of design source files
#runHdlImport $PROJ_NAME -filelist $FILENAME
runHdlImport $PROJ_NAME -filelist $FILELIST

#=========================================================================================
#         ENABLE THE DESIGNCHECKER GENERATE MISSING DECLARATION OPTION
#>>>>>>>>>>>   <<<<<<<<<<<<<
#=========================================================================================
setupTask DesignChecker -setting  ReportMissingDeclarations  1
setupTask DesignChecker -setting  ReportMissingDeclarationsLocation  "%(library_downstream_HdsLintPlugin)/%(library)_missingDeclarations.csv"
setupTask DesignChecker -setting  AllowHandlingMissingDeclarations 1
setupTask DesignChecker -setting  GeneratingMissingDeclarationsOption  "2"
setupTask DesignChecker -setting  GeneratedMissingDeclarationsLocation  "%(library_downstream_HdsLintPlugin)/generatedMissingDecls"
setupTask DesignChecker -setting  CopyBeforeOverwriteGeneratedFiles  1
setupTask DesignChecker -setting  TreatDonttouchAsMissingDeclarations 1
setupTask DesignChecker -setting  CopyBeforeOverwritePrefix ".bak"

#=========================================================================================
# Running the DesginChecker in batch mode on the batch imported HDL design files
#
# B.Huynh (Mentor Graphics) 2010-03-04
#=========================================================================================

#=========================
# EXAMPLE FOR RUNNING DesignChecker ANALYSIS ON EACH DESIGN FILE
# PARSING ===> FLAT, no top-level file designated
#
# B.Huynh (Mentor Graphics) 2010-03-26
#=========================
setupTask {DesignChecker} -throughCpt
setupTask {DesignChecker} -setting SummaryFile $WORKSPACE/${TOP_LEVEL}/summary.csv
setupTask {DesignChecker} -setting SummaryFormat CSV
#
setupTask {DesignChecker} -setting Policy $POLICY
#=========================
#  You can modify the following API command call's optional parameter fields to add,
#  remove, and change the ordering for what is written into the DesignChekcer report
#  file's content.  Reference the DesignChecker User Manual for the most up to date
#  list of available DesignChecker report contents.
#  List from HDS 2009.2 release:
#       Rule Severity, Rule Category, Ruleset, Rule Name, Library, Design Unit Name,
#       Scope, Filename, Line Number, Message, Hint
#
# B.Huynh (Mentor Graphics) 2010-03-26
#=========================
setupTask {DesignChecker} -setting OutputReportContent {{Filename} {Rule Name} {Rule Path} {Rule Severity} {Rule Category} {Ruleset} {Library} {Design Unit Name} {Scope} {File and Line} {Line Number} {Message} {Hint}}
#==== For comma-separated-format report ====
setupTask {DesignChecker} -setting OutputFile $WORKSPACE/${TOP_LEVEL}/violations.csv
setupTask {DesignChecker} -setting OutputFormat CSV
#==== For HTML format report ====
#setupTask {DesignChecker} -setting OutputFile $WORKSPACE/${TOP_LEVEL}_DesignChecker_violation_report.html
#setupTask {DesignChecker} -setting OutputFormat HTML
#
#=========================
# HDS 2010.2 release version's vastly expanded analysis artifacts reporting
# capability.  Reference the DesignChecker User Manual for the most up to date
# list of available DesignChecker report contents.
#
# List of HDS 2010.2
#
# B.Huynh (Mentor Graphics) 2010-11-08
#====================== generate HDS_DC_ConfigFile.tcl, START =================
#
foreach F [glob -nocomplain $WORKSPACE/HDS_DC_*] {
    catch {file delete $F}
}
#
set FileId [open $WORKSPACE/${TOP_LEVEL}/config.tcl w]
set Commands {
    # Blackbox Xilinx simulation libraries
    setDownstreamLibraries [list $BLACKBOX]

    enableDumpCodeSnippet
    setSnippetLinesBefore 2
    setSnippetLinesAfter 2
    setRulesCheckedReport {$WORKSPACE/${TOP_LEVEL}/checked_rules_report.csv} {CSV}
    #
    setCheckedFileDUsReport {$WORKSPACE/${TOP_LEVEL}/checked_filelist.csv} {CSV}
    setCheckedFileDUsReportContents {{Checked Files} {Checked DesignUnits}}
    #
    setExclusionReport {$WORKSPACE/${TOP_LEVEL}/exclusion_report.csv} {CSV}
    setExclusionReportContents {{Black Boxed Files} {Don't Touch Files} {Rule Exclusions} {Code Exclustions} {Exclusion Pragmas} {Pragma Code Excluded} {Unbound Component} {Unbound Instances} {Summary}}
}
#
puts $FileId [subst $Commands]
close $FileId
#======================= generate HDS_DC_ConfigFile.tcl, END =================
#
# Use the generated report formatting file below
setupTask {DesignChecker} -setting ConfigFile $WORKSPACE/${TOP_LEVEL}/config.tcl
#

#Setup any macro switches that switch out non-synthesizable code
setLibraryMacroDefinitions $PROJ_NAME $PLUS_DEFINES




runTask {DesignChecker} $PROJ_NAME $TOP_LEVEL
#=========================
