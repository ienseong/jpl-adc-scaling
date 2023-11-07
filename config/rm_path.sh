############################################################################
#
# Remove a path from the PATH variable either directly or indirectly via an 
# environment variable.
#
# Example of direct removal:
#|
#| export RM_PATH=/path/to/some/dir
#| source rm_path.sh
#|
# If the path is found in the PATH variable then it is safely removed.
#
#
# Example of indirect removal:
#|
#| export MY_DIR_HOME=/path/to/som/dir
#| export RM_PATH_VAR=MY_DIR_HOME
#| source rm_path.sh
#|
# If the variable name is found in the environment, then the value stored
# there will be safely removed from the PATH variable.
#
# Caveats:
#     1 - always use exported environment variables RM_PATH or RM_PATH_VAR,
#         never shell variables, before sourcing this file
#     2 - do *NOT* use on special paths like: "." or ".." or the like,
#         this script is not that smart
#     3 - RM_PATH and RM_PATH_VAR are unset at conclusion of this script
#
############################################################################
# Created by  : Jeremy.G.Ridgeway@jpl.nasa.gov
# Created date: May 13, 2022
############################################################################


# Remove specified path variable from PATH
if ! test -z "${RM_PATH_VAR}" ; then
    export RM_PATH=$(printenv $RM_PATH_VAR)
fi

# Remove specified path from PATH
if ! test -z "${RM_PATH}" ; then
    export PATH=$(echo "${PATH}" | \
        sed 's|:| |g' | \
        sed "s|${RM_PATH}||g" | \
        sed 's|^ ||' | sed 's| $||' | \
        sed 's|  *|:|g')
fi

unset RM_PATH
unset RM_PATH_VAR


