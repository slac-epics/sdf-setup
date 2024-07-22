#-=-=-=-=-=-=-=-=
#
# newlist.sh
# Doug Murray
# 1991-2024
#

#
# newlist.sh
# Common file usable with bash or zsh
#
# Manage environment variables as lists rather than
# lengthy text strings which are difficult to read.
#
# Usage:
#       source this file, then afterwards in the
#       .bashrc or .zshrc file, add commands like
#          newlist path  PATH
#          newlist lib   LD_LIBRARY_PATH
#          newlist man   MANPATH
#          newlist class CLASSPATH -n
#          newlist cd    CDPATH
#          newlist ca    EPICS_CA_ADDR_LIST -s' ' -e
#          newlist pva   EPICS_PVA_ADDR_LIST -s' ' -e
#          newlist edm   EDMDATAFILES -e
#
# The function "newlist" creates a set of functions
# to make the contents of an environment variable
# appear to be an array of text.
#   These functions are named according to a suffix
# given to the newlist command.  For example:
#      newlist mine SOME_ENV_VAR
#    will create
#      insmine     <- to insert some text to the start of SOME_ENV_VAR
#      addmine     <- to append some text to the end of SOME_ENV_VAR
#      delmine     <- to delete some text (all instances) from SOME_ENV_VAR
#      remmine     <- to remove all functions, leave SOME_ENV_VAR as is
#      showmine    <- to display all contents of SOME_ENV_VAR
#      setmine     <- to create a list, setting SOME_ENV_VAR to contain the given arguments
# By default the environment variable is assumed to
# be a list separated by colons (:) and each entry
# is assumed to exist in the filesystem.  See the
# newlist command below to change those options.
#
# As a more complete example, consider
# a PATH variable that is set to:
# "/usr/local/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/Apple/usr/bin:/home/me/bin:/bin:/usr/bin"
# By saying "newlist path PATH", the functions
# described above are created, including "showpath":
#
#       showpath
#        1:               /usr/local/bin
#        2:               /usr/sbin
#        3:               /sbin
#        4:  unavailable->/opt/X11/bin
#        5:               /Library/Apple/usr/bin
#        6:               /home/me/bin
#        7:               /bin
#        8:               /usr/bin
#
# Details are described below.
#

#
# Determine if we're using bash or zsh.
# Assume zsh by default, but change to
# bash if 'shopt' builtin cmd is available.
#
SHELL_USED=zsh
if type shopt &>/dev/null
then
        SHELL_USED=bash
fi

#
# commonly used separator for list fields
# ($PATH, etc). can be changed with '-s' flag.
# The REPL_SEP is used in substitutions, but
# changed if the '-s' flag specifies the same
# symbol, in which case the _BACKUP_SEP separator
# will be used instead.
# Only used in zsh version, bash uses IFS.
#
_LIST_MANAGE_SEP=':'
_LIST_REPL_SEP='/'
_LIST_BACKUP_SEP=':'

#
# Remove all current content from the named variable, then add new list entries
#
# usage: _ListMgrCreate VarName [-e][-n][-q][-v][-sX] arg1 ... 
#
# refer to 'newlist' below.
#
function _ListMgrCreate
        {
        let verbose=0
        local component
        local envVar

        #
        # get the env variable to create
        #
        envVar="$1"
        shift

        #
        # consume options
        #
        for component in "$@";
        do
                case $component in
                        -e | -n | -q | -s)
                                continue
                                ;;
                        -v)
                                let verbose=1
                                continue
                                ;;
                esac
        done

        eval "unset $envVar"
        _ListMgrChange append "$envVar" "$@"

        if (( $verbose == 1 ))
        then
                printf "Created the '%s' list\n" "$envVar"
                _ListMgrShow $envVar
        fi
        }

#
# Insert the given arguments in front of
# those already in the named variable.
# Duplicates are removed first.
#
# usage: _ListMgrInsert VarName [-e][-n][-q][-v][-sX] arg1 ...
#
# refer to 'newlist' below.
#
function _ListMgrInsert
        {

        _ListMgrChange insert "$@"
        }

#
# Append the given arguments after
# those already in the named variable.
# Duplicates are removed first.
#
# usage: _ListMgrAppend VarName [-e][-n][-q][-v][-sX] arg1 ...
#
# refer to 'newlist' below.
#
function _ListMgrAppend
        {

        _ListMgrChange append "$@"
        }

#
# Insert or Append the given arguments in front
# or at the end of the named variable.
# Duplicates are removed first.
#
# usage: _ListMgrChange [append|insert] VarName [-e][-n][-q][-v][-sX] arg1 ...
#
# refer to 'newlist' below.
#
function _ListMgrChange
        {
        let needExist=1
        let needDir=1
        let verbose=0
        let quiet=0
        local component
        local doInsert
        local envVar
        _list_sep="${_LIST_MANAGE_SEP}"

        #
        # get the operation; insert or append
        #
        doInsert=$1
        shift

        #
        # first delete the items from the list
        #
        _ListMgrDelete "$@"

        #
        # get the variable to manage...
        #
        envVar=$1
        _ListContent=$(eval echo ${envVar:+'$'}${envVar:-})
        shift

        NC=
        for component in "$@";
        do
                case $component in
                        -e)
                                let needExist=0
                                continue
                                ;;
                        -n)
                                let needDir=0
                                continue
                                ;;
                        -v)
                                let verbose=1
                                continue
                                ;;
                        -q)
                                let quiet=1
                                continue
                                ;;
                        -s*)
                                _list_sep=${component:2:1}
                                _list_sep=${_list_sep:-" "}
                                continue
                                ;;
                esac
                if (( $needExist == 1 ))
                then
                        if (( $needDir == 1 ))
                        then
                                if [[ "${component:0:1}" != "/" &&  "${component:0:2}" != "~/" ]];
                                then
                                        if (( $quiet != 1))
                                        then
                                                printf "Warning: %s\n" "'$component' does not start with '/' or '~/'"
                                        fi
                                fi
                                if [[ ! -d "$component" || ! -x "$component" ]];
                                then
                                        if (( $quiet != 1))
                                        then
                                                printf "%s\n" "$component is Unavailable."
                                        fi
                                        continue
                                fi
                        else
                                if [[ ! -r "$component" ]];
                                then
                                        if (( $quiet != 1))
                                        then
                                                printf "%s\n" "$component is not readable."
                                        fi
                                        continue
                                fi
                        fi
                fi
                #
                # construct New Content with each argument
                # to append or insert to the list later
                #
                NC="$NC${NC:+$_list_sep}$component"
                if (( $verbose == 1 ))
                then
                        if [[ "$doInsert" = "append" ]];
                        then
                                printf "Added %s to the end of the '%s' list\n" "$component" "$envVar" 
                        else
                                printf "Inserted %s at the beginning of the '%s' list\n" "$component" "$envVar" 
                        fi
                fi
        done

        #
        # append value to end, or insert at beginning
        #
        if [[ "$doInsert" = "append" ]];
        then
                _ListContent="$_ListContent${_ListContent:+${NC:+$_list_sep}}$NC"
        else
                _ListContent="$NC${NC:+$_list_sep}$_ListContent"
        fi

        eval "export $envVar='$_ListContent'"
        if (( $verbose == 1 ))
        then
                _ListMgrShow $envVar
        fi
        }

#
# List the contents of the named variable, in a reasonable
# and readable form.
#
# usage: _ListMgrShow VarName [-e][-n][-q][-v][-sX]
#
# refer to 'newlist' below.
#
function _ListMgrShow
        {
        local component
        let needExist=1
        let needDir=1
        let verbose=0
        let quiet=0
        let index=0
        _list_sep="${_LIST_MANAGE_SEP}"
        _repl_sep="${_LIST_REPL_SEP}"

        #
        # get the variable (list) to manage...
        #
        _ListContent=$(eval echo ${1:+'$'}${1:-})
        shift

        #
        # gather arguments
        #
        for argument in "$@";
        do
                case $argument in
                -e)
                        let needExist=0
                        continue
                        ;;
                -n)
                        let needDir=0
                        continue
                        ;;
                -v | -q)
                        continue
                        ;;
                -s*)
                        _list_sep=${argument:2:1}
                        _list_sep=${_list_sep:-" "}

                        if [[ "${_list_sep}" == "${_repl_sep}" ]];
                        then
                                _repl_sep="${_LIST_BACKUP_SEP}"
                        fi
                        continue
                        ;;
                esac
        done

        #
        # For zsh, convert the list to an array (because IFS isn't
        # available here), then traverse and legibly print
        # For bash, just traverse the variable and legibly print
        #
        if [[ $SHELL_USED == "bash" ]];
        then
                IFS="$_list_sep"
        else
                eval $(printf "%s" "_ListContent=(\${(s${_repl_sep}${_list_sep}${_repl_sep})_ListContent})")
        fi

        for component in $_ListContent;
        do
                let index=$index+1;
                printf "%4.3s: " "$index"
                if (( $needExist == 1 ))
                then
                        if (( $needDir == 1 ))
                        then
                                if [[ ! -d $component || ! -x $component ]];
                                then
                                        printf "%s" " unavailable->"
                                else
                                        printf "%s" "              "
                                fi
                        else
                                if [[ ! -r $component ]];
                                then
                                        printf "%s" "not readable->"
                                else
                                        printf "%s" "              "
                                fi
                        fi
                else
                        printf "%s" "              "
                fi
                printf "%s\n" "$component"
        done

        if [[ $SHELL_USED == "bash" ]];
        then
                unset IFS
        fi
        }

#
# Delete all instances of each argument from the
# variable (list) given as the first argument.
#
# usage: _ListMgrDelete VarName [-e][-n][-q][-v][-sX] arg1 ...
#
# refer to 'newlist' below.
#
function _ListMgrDelete
        {
        let verbose=0
        let changed=0
        local component
        local envVar
        _list_sep="${_LIST_MANAGE_SEP}"
        _repl_sep="${_LIST_REPL_SEP}"

        #
        # get the variable to
        # manage and it's value.
        #
        envVar=$1
        _ListContent=$(eval echo ${envVar:+'$'}${envVar:-})
        shift

        for toDelete in "$@";
        do
                case $toDelete in
                -e | -n | -q)
                        continue
                        ;;
                -v)
                        let verbose=1
                        continue
                        ;;
                -s*)
                        _list_sep=${toDelete:2:1}
                        _list_sep=${_list_sep:-" "}

                        if [[ "${_list_sep}" == "${_repl_sep}" ]];
                        then
                                _repl_sep="${_LIST_BACKUP_SEP}"
                        fi
                        continue
                        ;;
                esac

                #
                # If zsh, convert the list to an
                # array because IFS isn't available.
                # In bash or zsh, rebuild the list without
                # the deleted element.
                #
                if [[ $SHELL_USED == "bash" ]];
                then
                        IFS=$_list_sep
                else
                        eval $(printf "%s" "_ListContent=(\${(s${_repl_sep}${_list_sep}${_repl_sep})_ListContent})")
                fi

                NC=''
                for component in $_ListContent;
                do
                        if [[ ! -z $component && $component != "$toDelete" ]];
                        then
                                NC="${NC}${NC:+$_list_sep}$component"
                        else
                                let changed=1
                                if (( $verbose == 1 ))
                                then
                                        printf "Removed %s from list '%s'\n" "$component" "$envVar"
                                fi
                        fi
                done
                if [[ $SHELL_USED == "bash" ]];
                then
                        unset IFS
                fi
                _ListContent="${NC}"
        done
        if (( $changed == 1 ))
        then
                eval "export $envVar='$_ListContent'"
                if (( $verbose == 1 ))
                then
                        _ListMgrShow $envVar
                fi
        else
                if (( $verbose == 1 ))
                then
                        printf "Nothing to delete from the '%s' list\n" "$envVar"
                fi
        fi
        }

#
# Remove the functions associated with the environment variable,
# leaving the variable intact.
#
# usage: _ListMgrRemove CommandSuffix [-e][-n][-q][-v][-sX] ...
#
# Note this is different from other generated functions because
# its argument is the command suffix rather than the environment
# variable.  Refer to 'newlist' below.
#
function _ListMgrRemove
        {
        local component
        local suff
        let verbose=0

        #
        # get the list's suffix
        #
        suff=$1
        shift

        #
        # should be options only
        #
        for component in "$@";
        do
                case $component in
                        -e | -n | -q | -s)
                                continue
                                ;;
                        -v)
                                let verbose=1
                                continue
                                ;;
                esac
        done

        if (( $verbose == 1 ))
        then
                printf "Removing the functions created to manage the list named '$suff':\n"
                printf "    removing function   set%s\n" "$suff"
                printf "    removing function  show%s\n" "$suff"
                printf "    removing function   ins%s\n" "$suff"
                printf "    removing function   add%s\n" "$suff"
                printf "    removing function   del%s\n" "$suff"
                printf "    removing function   rem%s\n" "$suff"
        fi

        eval "unset -f 'set$suff'"
        eval "unset -f 'ins$suff'"
        eval "unset -f 'add$suff'"
        eval "unset -f 'del$suff'"
        eval "unset -f 'rem$suff'"
        eval "unset -f 'show$suff'"

        #
        # don't try removing the list's name from
        # 'lists' if we've just removed 'lists'.
        #
        if [[ "$suff" != "lists" ]];
        then
                dellists "$suff"
        fi
        }

#
# Create functions to manage an environment variable
# meant to contain a list of delimited names.
# This includes PATH, LD_LIBRARY_PATH, MANPATH, CDPATH, etc.
#
# usage: newlist CommandSuffix VarName [-e][-n][-q][-v][-sX]
#
#            The 'CommandSuffix' is used to create the
#            function name, and the VarName is the
#            environment variable containing the list.

#       -e : the constructed functions will not require
#            the list element to exist in the file system
#       -n : the constructed functions will not require
#            the list element to exist as a directory
#       -q : the constructed functions will work quietly
#       -v : the constructed functions will be verbose
#       -sX: the constructed functions will use X as
#            the delimiter, which is ${_LIST_MANAGE_SEP} by default,
#            typically a colon (:)
#
# Functions are created to insert, append, delete, reset,
# create and show all elements in the list.  The list
# is created if it doesn't already exist.
#
# Example:
#     newlist path PATH
# will create an environment variable named PATH if
# it doesn't already exist.  If will also create a
# command 'addpath' which will add an element to
# that environment variable.  For instance,
#     addpath /bin
# will add /bin to the PATH.  If it's already in the
# PATH, it will be moved to the end.  Similarly,
# inspath is created to insert the directory at the
# beginning of the list. The delpath function will remove
# the directory from PATH, rempath removes the functions
# leaving the environment variable as is, setpath will remove
# the contents of the environment variable then add
# new content, and showpath lists all of the
# variable's elements.  
#
# A list of all lists is also maintained to indicate
# active list names.
#
function newlist
        {
        let verbose=0
        local suff
        local envVar

        if [[ $# -lt 2 ]];
        then
                printf "usage: newlist <NAME> <ENVIRONMENT-VARIABLE> -v -q -s'X' -e -n\n"
                printf "       -n          - items are not required to exist as directories \n"
                printf "       -e          - items are not required to exist in the file\n"
                printf "                     system (implies -n)\n"
                printf "       -q          - list management functions will work quietly\n"
                printf "       -v          - list management functions will be verbose\n"
                printf "       -s'X'       - use X as a separator in the list, uses ':'\n"
                printf "                     default (a space ' ' is a valid separator)\n"
                printf "             NOTE: - ALL OPTIONS MUST APPEAR LAST on command line.\n\n"

		printf "The 'newlist' command will create functions used to manage\n"
                printf "              environment variables.\n"
		printf "Example: to manage the \$PATH variable,\n"
                printf "  'newlist path PATH' will create the following six functions:\n"
		printf "      showpath     - show the contents of \$PATH as a list\n"
		printf "      addpath X... - add new given names, or move them if\n"
		printf "                     they already exist to the end of \$PATH\n"
		printf "      inspath X... - insert new given names, or move them if\n"
		printf "                     they already exist to the start of \$PATH\n"
		printf "      delpath X... - remove the given names from \$PATH\n"
		printf "      setpath X... - replace \$PATH with the given names\n"
		printf "      rempath      - remove all six generated functions\n"

                return
        fi

        suff=$1
        shift

        if [[ -z $suff || $suff =~ ^- ]];
        then
                printf "   Invalid suffix\n"
                printf "usage: newlist <SUFFIX> <ENVIRONMENT-VARIABLE> -v -q -s'X' -e -n\n"
                return
        fi

        if [[ ${1:0:1} = '-' ]];
        then
                printf "  Invalid Environment variable\n"
                printf "usage: newlist <SUFFIX> <ENVIRONMENT-VARIABLE> -v -q -s'X' -e -n\n"
                return
        fi

        #
        # get for printing with -v,
        # don't shift, keep with $@
        #
        envVar="$1"

        #
        # check only for verbose flag here
        # commands will check options
        #
        for component in "$@";
        do
                if [[ $component == "-v" ]];
                then
                        let verbose=1
                        break;
                fi
        done

        #
        # The $@ parameter adds the initial newlist arguments indicating delimiters,
        # verbose flags and so forth.  The \$@ parameter isn't processed but adds a
        # $@ to the function body, which then expands when the defined function is
        # called.  The semicolon is required because the closing brace needs a
        # delimiter to appear before it.
        #
        eval "function set$suff  { _ListMgrCreate      $@ \"\$@\" ; }"
        eval "function ins$suff  { _ListMgrInsert      $@ \"\$@\" ; }"
        eval "function add$suff  { _ListMgrAppend      $@ \"\$@\" ; }"
        eval "function del$suff  { _ListMgrDelete      $@ \"\$@\" ; }"
        eval "function show$suff { _ListMgrShow        $@ \"\$@\" ; }"
        eval "function rem$suff  { _ListMgrRemove $suff \"\$@\" ; }"

        if (( $verbose == 1 ))
        then
                printf "Creating functions to manage the '%s' list, referred to as '%s':\n" "$envVar" "$suff"
                printf "    set%s <- creates and sets the '%s' list to the named elements\n" "$suff" "$envVar"
                printf "   show%s <- shows all elements within the '%s' list\n" "$suff" "$envVar"
                printf "    ins%s <- inserts the named elements to the head of the '%s' list\n" "$suff" "$envVar"
                printf "    add%s <- appends the named elements to the tail of the '%s' list\n" "$suff" "$envVar"
                printf "    del%s <- deletes the named elements from the '%s' list\n" "$suff" "$envVar"
                printf "    rem%s <- removes these functions, leaving the '%s' list as is\n" "$suff" "$envVar"
        fi

        #
        # add to the list of lists
        #
        addlists "$suff"
        }

#
# Set up the first list,
# a list of internal lists
#
newlist lists _INTERNAL_LIST_NAMES_ -e -n -q

