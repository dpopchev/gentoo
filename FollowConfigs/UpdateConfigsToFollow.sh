#!/usr/bin/env bash

# place to store files to follow absolute paths
LIST_CONFIGS=/home/dimitar/projects/Gentoo/FollowConfigs/ConfigsToFollow

# current working directory
CWD=$(pwd)

# program description
DESCRIPTION="\
$(basename $0) is a script to help maintain list of files/directories. \
Each of those are to be backup on regular intervals, action not to be covered \
by the present script. \
\n\n Flag usage: "

# list of valid flags and their description (long version as a key)
declare -A FLAGS
FLAGS+=(["--help"]="show this message")
FLAGS+=(["--add"]="add file/directory to follow list")
FLAGS+=(["--delete"]="delete file/directory to follow list")
FLAGS+=(["--update"]="update current record in follow list with new one")
FLAGS+=(["--get"]="get file/directory if present")
FLAGS+=(["--list"]="list all currently followed files/configs")
FLAGS+=(["--edit"]="edit $LIST_CONFIGS in place with your preferred editor: $EDITOR")

# list of flags which also have short version
declare -A FLAGS_PAIRS
FLAGS_PAIRS+=(["--help"]="-h")
FLAGS_PAIRS+=(["--add"]="-a")
FLAGS_PAIRS+=(["--delete"]="-d")
FLAGS_PAIRS+=(["--update"]="-u")

usage(){
    # function to generate usage of the script

    # setting max line length
    local -i maxLineLen=81

    # hard code indentation
    local indent="  "

    # generate the flag usage
    _createFlagsDescription(){
        # function to generate flag description

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
        local DescriptionSpace=$(expr $maxLineLen - $maxFlagLen - ${#indent})

        # create line formatter, which is indented with indent amount of
        # space, reserves the longest possible amount of flag space and uses the
        # rest for description
        local line_formater="${indent} %-${maxFlagLen}s${indent}%-${DescriptionSpace}s\n"

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
            # if we exceed the space left for the description, we print it
            # and null the description local variable
            for word in ${FLAGS[$flag]}; do
                _description+=" $word"
                if [[ ${#_description} -lt ${DescriptionSpace} ]]; then
                    # rise mark for pending description
                    _is_any_description_pending=true
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

cleanEmptyLines(){
    # clean empty lines from the storage file, if any present
    sed -i '/^$/d' $LIST_CONFIGS
}

addConfigs(){
    # check if item is valid file/path and if it is add it to the follow file

    local -r item=$1

    grep -q $item $LIST_CONFIGS
    local -r item_present=$?

    # if the config item is already present, inform and skip adding
    if [[ $item_present -eq 0 ]]; then
        echo "$item... already present, skipping"
    else
        echo $item >> $LIST_CONFIGS
    fi

    return 0
}

checkIsFlag(){
    # check if present argument is a valid flag
    # return 0 argument is either a long or short flag
    # return 1 if it is neither

    grep -wq -- "${1}" <(echo "${!FLAGS[*]}")
    local check_short=$?

    grep -wq -- "${1}" <(echo "${FLAGS_PAIRS[*]}")
    local check_long=$?

    # result variable, presume argument is not a valid flag
    local r=1

    if [ $cehck_short -eq 0 ] || [ $check_long -eq 0 ]; then
        r=0
    else
        r=1
    fi

    return r
}

# print usage if no arguments
if [[ $# -eq 0 ]]; then
    usage

# go through all flags
else
    # make sure we do not have empty lines in the file

    while [[ $# -gt 0 ]]; do
        case "$1" in

            # print usage infomration
            --help|${FLAGS_PAIRS["--help"]})
                usage
                exit 0
                ;;

            # add file/directory to follow list
            --add|${FLAGS_PAIRS["--add"]})
                shift 1

                # iterate until reaching a valid flag or arguments end
                local isNextArgFlag=1
                while [ "$#" -gt 0 ] && [
                    && ! grep -wq -- "${1}" <(echo "${!FLAGS[*]}") \
                    && ! grep -wq -- "${1}" <(echo "${FLAGS_PAIRS[*]}"); do

                    item=$(readlink -f $1)

                    echo $item

                    # check if item exists, if so added it
                    #if [[ -e $item ]]; then
                    #    addConfigs $item
                    #else
                    #    echo "$item does not exists, skipping..."
                    #fi

                    shift 1
                done
                ;;
            *)
                echo "$1 unknown argument, please consult with help..."
                exit 1
                ;;
        esac
    done
fi
