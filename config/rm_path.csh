############################################################################
#
# Remove a path from the PATH variable either directly or indirectly via an 
# environment variable.
#
# Example of direct removal:
#|
#| setenv RM_PATH /path/to/some/dir
#| source rm_path.csh
#|
# If the path is found in the PATH variable then it is safely removed.
#
#
# Example of indirect removal:
#|
#| setenv MY_DIR_HOME /path/to/som/dir
#| setenv RM_PATH_VAR MY_DIR_HOME
#| source rm_path.csh
#|
# If the variable name is found in the environment, then the value stored
# there will be safely removed from the PATH variable.
#
# Caveats:
#     1 - always use environment variables RM_PATH or RM_PATH_VAR,
#         never shell variables, before sourcing this file
#     2 - do *NOT* use on special paths like: "." or ".." or the like,
#         this script is not that smart
#     3 - RM_PATH and RM_PATH_VAR are unsetenv at conclusion of this script
#
############################################################################
# Created by  : Jeremy.G.Ridgeway@jpl.nasa.gov
# Created date: May 13, 2022
############################################################################

unset RM_PATH      # ONLY USE ENV VARS : this exposes the env var
unset RM_PATH_VAR  # ONLY USE ENV VARS : this exposes the env var

# Remove specified path variable from PATH
if ( $?RM_PATH_VAR ) then
    set RM_PATH_VAR2 = ( $RM_PATH_VAR )
    if ( "$RM_PATH_VAR2" != "" ) then
        setenv RM_PATH `printenv $RM_PATH_VAR2`
    endif
    unset RM_PATH_VAR2
endif

# Remove specified path from PATH
if ( $?RM_PATH ) then
    if ( "$RM_PATH" != "" ) then
        set path = ( `echo $path | sed "s|$RM_PATH||g"` )
    endif
endif

unsetenv RM_PATH
unsetenv RM_PATH_VAR

