#!/usr/bin/env bash

# place to store files to follow absolute paths
LIST_CONFIGS=/home/dimitar/projects/Gentoo/FollowFiles/ConfigsToFollow

# current working directory
CWD=$(pwd)

# program description
DESCRIPTION="\
$(basename $0) is a script to help maintain list of files/directories. \
Each of those are to be backup on regular intervals, but this is \
not to be covered by the present script. \
\n\n Flag usage: "

# list of valid flags and their description (long version as a key)
declare -A FLAGS
FLAGS+=(["--help"]="show this message")
FLAGS+=(["--add"]="add file/directory to follow list")
FLAGS+=(["--remove"]="remove file/directory to follow list")
FLAGS+=(["--update"]="update current record in follow list with new one")
FLAGS+=(["--get"]="get file/directory if present")
FLAGS+=(["--list"]="list all currently followed files/configs")
FLAGS+=(["--edit"]="edit $LIST_CONFIGS in place with your preferred editor: $EDITOR")

# list of flags which also have short version
declare -A FLAGS_PAIRS
FLAGS_PAIRS+=(["--help"]="-h")
FLAGS_PAIRS+=(["--add"]="-a")
FLAGS_PAIRS+=(["--remove"]="-r")
FLAGS_PAIRS+=(["--update"]="-u")

usage(){

    # setting max line length
    local -i maxLineLen=81

    # hard code local delimiter to some amount of spaces
    local delimiter="  "

    # generate the flag usage
    _createFlagsDescription(){

        # go over all keys to check which is the longest
        local -i maxFlagLen=0
        for flag in "${!FLAGS[@]}"; do
            if [[ ${#flag} -gt $maxFlagLen ]]; then
                maxFlagLen=${#flag}
            fi
        done

        # go over all keys with their short version to update the longest length
        # e.g. -h/--help is longer then --remove
        for flag in "${!FLAGS[@]}"; do
            _pair=${flag}/${FLAGS_PAIRS[$flag]}
            if [[ ${#_pair} -gt $maxFlagLen ]]; then
                maxFlagLen=${#_pair}
            fi
        done

        # the rest of the space will be used for the description
        local DescriptionSpace=$(expr $maxLineLen - $maxFlagLen - ${#delimiter})

        # create line formatter, which is indented with delimiter amount of
        # space, reserves the longest possible amount of flag space and uses the
        # rest for description
        local line_formater="${delimiter} %-${maxFlagLen}s${delimiter}%-${DescriptionSpace}s\n"

        # iterate over all long version key flags
        for flag in "${!FLAGS[@]}"; do

            # lines start with flag pair
            local line_start=""

            # if the flag does not have short version, use only the long one
            # e.g. --help if no -h available, otherwise --help/-h
            if [[ -z ${FLAGS_PAIRS[$flag]} ]]; then
                line_start=$flag
            else
                line_start=$flag/${FLAGS_PAIRS[$flag]}
            fi

            # fill the description here
            local _description=""

            # make sure that we have printed the first line
            local _is_firstline_printed=false

            # make sure we do not have any pending description to print
            local _is_any_description_pending=false

            # iterate over the flag description word by word
            # if we exceed the space left for the description, we print and null
            # the description local variable
            for word in ${FLAGS[$flag]}; do
                _description+=" $word"
                if [[ ${#_description} -lt ${DescriptionSpace} ]]; then
                    # rise mark for pending description
                    _is_any_description_pending=true
                    :
                else
                    # check that we have printed inside the loop
                    _is_firstline_printed=true
                    _is_any_description_pending=false

                    # remove last word, as it over exceeds the amount of space
                    _description="${_description% *}"

                    printf "$line_formater" "$line_start" "${_description}"

                    # null the description make the last over exceeding word first
                    _description=""
                    _description+=" $word"

                    # null the line start; flags are printed only on the first line
                    line_start=""
                fi
            done

            # if it turns out that the description length did not exceed the
            # space reserved for it
            if [[ $_is_firstline_printed = false || $_is_any_description_pending = true ]]; then
                printf "$line_formater" "$line_start" "${_description}"
            fi
        done

        return 0
    }

    # generate general description
    _createGeneralDescription(){
        # function to generate the description of the program

        # description buffer to fill
        _description=""

        # mark pending description
        _is_any_description_pending=false

        for word in $DESCRIPTION; do
            _description+=" $word"

            if [[ ${#_description} -lt $maxLineLen ]]; then
                # rise mark for pending
                _is_any_description_pending=true
            else
                _is_any_description_pending=false

                # remove last word as it over exceeds the line length
                _description="${_description% *}"

                printf "$_description \n"

                # null description and re append the last over exceeding word
                _description=""
                _description+=" $word"
            fi
        done

        if [[ $_is_any_description_pending = true ]]; then
            printf "$_description \n"
        fi

        return 0
    }

cat << HELP_USAGE

$(_createGeneralDescription)

$(_createFlagsDescription)

HELP_USAGE
}

editFile(){
    $EDITOR $LIST_FILES
}

cleanEmptyLines(){
# remove empty lines from the storage file
    sed -i '/^$/d' $LIST_FILES
}

normalizePath(){
# all paths in LIST_FILES are absolute, thus here we normalize the input path
#   input -- $1, string, file path to normalize
#   output -- string, normalize path with exit code 0 if successful
#               normalized path and exit code 2 if file does not exists

    # if file path is local dir, expand it to current working directory
    [[ $(dirname "$1") == "." ]] && NORM_FILEPATH="${PWD}/$(basename $1)" \
        || NORM_FILEPATH=$1

    # check if file exists
    [[ -f $NORM_FILEPATH ]] && echo $NORM_FILEPATH && return 0 \
        || echo "$NORM_FILEPATH does not exist" && return 2
}

addConfig(){

    NEW_FILE=$(normalize_FilePath $NEW_FILE)

    # file does not exist, exit the script
    [[ $? -eq 2 ]] && echo "$NEW_FILE" && exit 0

    # check how many occurrences there are in LIST_FILES
    GREP_R="$(grep -cs $NEW_FILE $LIST_FILES)"

    # if grep exits with unsuccessful exit code infrom
    [[ $? -eq 2 ]] && echo "Unexpected grep result: $GREP_R" && exit 2
    case $GREP_R in
        1)      echo "File already followed"
                ;;
        0)      echo $NEW_FILE >> $LIST_FILES
                ;;
        *)      echo "Unexpected case, $GREP_R"
                ;;
    esac
}

del_file(){
# after normalizing the DEL_FILE check if already present
# if not -- complain, if yes -- remove

    DEL_FILE=$(normalize_FilePath $DEL_FILE)

    # file does not exist, exit the script
    [[ $? -eq 2 ]] && echo "$DEL_FILE" && exit 0

    # check how many occurrences there are in LIST_FILES
    GREP_R="$(grep -cs $DEL_FILE $LIST_FILES)"

    # if grep exits with unsuccessful exit code infrom
    [[ $? -eq 2 ]] && echo "Unexpected grep result: $GREP_R" && exit 2
    case $GREP_R in
        1)      sed -i "\|$DEL_FILE|d" $LIST_FILES
                ;;
        0)      echo "File not followed yet"
                ;;
        *)      echo "Unexpected case, $GREP_R"
                ;;
    esac
}

Delete_file(){
# delete file without taking into account path

    DEL_FILE=$(basename $DEL_FILE)

    # check how many occurrences there are in LIST_FILES
    GREP_R="$(grep -cs $DEL_FILE $LIST_FILES)"

    # if grep exits with unsuccessful exit code infrom
    [[ $? -eq 2 ]] && echo "Unexpected grep result: $GREP_R" && exit 2
    case $GREP_R in
        1)      sed -i "\|$DEL_FILE|d" $LIST_FILES
                ;;
        0)      echo "File not followed yet"
                ;;
        *)      echo "Unexpected case, $GREP_R"
                ;;
    esac
}

#updt_file(){
## if FILE present, replace it with REPLACEMENT
## if not present or no update provided -- add it
## if any ambiguity detected -- inform
#    FILE=`basename $FILE`
#    REPLACEMENT=`basename $REPLACEMENT`
#    # if no replacement given, add_file
#    [[ ! -z $REPLACEMENT ]]
#    case `grep -c "${PWD}/${FILE}$" $LIST_FILES` in
#        0)      # File to update missing, will add it"
#                echo "File to update missing, adding it"
#                FILE=$_FILE
#                add_file
#                ;;
#        1)      # One occurrence of file, replace
#                sed -i "|${_FILE}|${PWD}/${REPLACEMENT}|g" $LIST_FILES
#
#    if grep -Fxq $FILE $LIST_FILES; then
#        sed -i "s|${FILE}|${FILE1}|g" $LIST_FILES
#    else
#        echo "File to update missing, adding it"
#        add_file
#    fi
#}

get_file(){
# check if file is present, and if so return the path
    echo `grep $FILE $LIST_FILES`
}

list_files(){
# clean list of files file from empty lines and print
    cat $LIST_FILES
}

# print help if no arguments
if [[ $# -eq 0 ]]; then
    usage
# go through all flags
else
    # make sure we do not have empty lines in the file
    clean_EmptyLines
    while [[ $1 != "" ]]; do
        case $1 in
            -a | --add)     # check if there is file to add
                            [[ ! -z $2 ]] && NEW_FILE=$2 && add_file \
                                || echo "No file to add" && exit $RES
                            ;;
            -d | --delete)  # check if there is file to delete
                            [[ ! -z $2 ]] && DEL_FILE=$2 && del_file \
                                || echo "No file to delete" && exit $RES
                            ;;
            -u | --update)  # check if there is file to update with
                            [[ ! -z $3 ]] && REPLACEMENT=$3 || echo "No file to update with"

                            # check if there is file to update
                            [[ ! -z $2 ]] && FILE=$2 && updt_file \
                                || echo "No file to update"
                            exit $RES
                            ;;
            -g | --get)     # if file is followed get its full record
                            [[ ! -z $2 ]] && FILE=$2 && get_file \
                                || echo "No file to get"
                            exit $RES
                            ;;
            -l | --list)    list_files
                            exit $RES
                            ;;
            -e | --edit)    edit_file
                            exit $RES
                            ;;
            -h | --help)    usage
                            exit $RES
                            ;;
            -D | \
            --Delete_file)  # check if there is file to delete
                            [[ ! -z $2 ]] && DEL_FILE=$2 && Delete_file \
                                || echo "No file to delete" && exit $RES
                            ;;
            *)              echo "$1 not recognized"
                            echo "see help for available options"
                            usage
                            exit $RES
                            ;;
        esac
        # should not reach this point
        exit 2
    done
fi

exit $RES
