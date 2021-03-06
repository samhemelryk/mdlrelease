#!/bin/bash

# This scripts propagates changes from official integration Moodle git repository
# to main repostiory and mirrors
#
# Please note you need to have public ssh keys in all remotes except the origin!
#
# This script base dir

# Reset to normal.
N="$(tput setaf 9)"
# Red.
R="$(tput setaf 1)"
# Green.
G="$(tput setaf 2)"
# Yellow.
Y="$(tput setaf 3)"
# Cyan.
C="$(tput setaf 6)"
bold=`tput bold`
normal=`tput sgr0`
_verbose=true # Make lots of noise.
_showhelp=false
_confirmed=false
_dryrun=false
_tags=true

show_help() {
    echo ""
    echo "${bold}Moodle release - release.sh script${normal}"
    echo ""
    echo "This tool spreads the already prepared release from integration.git"
    echo "to moodle.git and then onto the other public repositories we maintain."
    echo ""
    echo "${Y}Warning:${normal} Only run this script after you have prepared the release!"
    echo ""
    echo "${bold}Usage:${normal}"
    echo "  ./release.sh [-c|--confirm] [-n|--dry-run] [-q|--quiet] [-h|--help]"
    echo "               [--no-tags]"
    echo ""
    echo "${bold}Arguments:${normal}"
    echo "  ${bold}-c${normal}, ${bold}--confirm${normal}"
    echo "      This script requires that you confirm the action you are about to take."
    echo "      By giving this argument you acknowledge you understand what is going to"
    echo "      be done and are happy for this script to just get on with it, without"
    echo "      prompting you to check."
    echo "  ${bold}-n${normal}, ${bold}--dry-run${normal}"
    echo "      Do everything except actually send the updates."
    echo "  ${bold}-q${normal}, ${bold}--quiet${normal}"
    echo "      If set this script produces no progress output. It'll let you know when "
    echo "      its finished however."
    echo "      You must confirm [-c|--confirm] if using this option."
    echo "  ${bold}-h${normal}, ${bold}--help${normal}"
    echo "      Prints this help and exits."
    echo "  ${bold}--no-tags${normal}"
    echo "      By default tags are pushed as well, this prevents that from happening."
    echo "      I hope you know what you're doing!"
    echo ""
    echo "May the --force be with you"
    exit 0;
}

output() {
    if $_verbose ; then
        if [ ! -z $2 ]  ; then
            echo -n "$1"
        else
            echo "$1"
        fi
    fi
}

while test $# -gt 0;
do
    case "$1" in
        -c | --confirm)
            _confirmed=true
            shift
            ;;
        -h | --help)
            _showhelp=true
            shift
            ;;
        -n | --dry-run)
            _dryrun=true
            shift
            ;;
        -q | --quiet)
            _verbose=false
            shift # Get rid of the flag.
            ;;
        --no-tags)
            _tags=false
            shift # Get rid of the flag.
            ;;
        *)
            echo "${R}* Invalid option $1 given.${N}"
            _showhelp=true
            shift
    esac
done

if $_showhelp ; then
    show_help
fi

mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ ! -d ${mydir}/gitmirror ]] ; then
    output "Directory ${mydir}/gitmirror not found. You may need to create it with install.sh"
    exit 1
fi

output "${G}Moodle release propogator${N}"

cd ${mydir}/gitmirror
git fetch --quiet origin

if ! $_confirmed ; then
    if ! $_verbose ; then
        echo "${R}Error${N}: you must auto-confirm [-c|--confirm] when running silent [-q|--quiet]"
        exit 1
    fi
    output "${bold}Confirm:${normal} please confirm you intention to update the public repositories with the"
    output "         prepared release: [y|n] " true
    read -n 1 confirminput
    if [ "$confirminput" != "y" ] && [ "$confirminput" != "Y" ] ; then
        output " ... release script ${bold}cancelled${normal}. Have a nice day!"
        exit 0
    else
        output " ... proceeding"
    fi
fi

output ""
output "${bold}Propogating${normal} ... " true

pushargs=""
if $_tags ; then
    pushargs="${pushargs} --tags"
fi
if $_dryrun ; then
    pushargs="${pushargs} --dry-run"
fi

# Update public repositories
#  * moodle         - git://git.moodle.org/moodle.git
#  * github         - git@github.com:moodle/moodle.git
#  * gitorious      - git@gitorious.org:moodle/moodle.git
#  * bitbucket      - git@bitbucket.org:moodle/moodle.git
git push ${pushargs} public refs/remotes/origin/master:refs/heads/master \
                            refs/remotes/origin/MOODLE_26_STABLE:refs/heads/MOODLE_26_STABLE \
                            refs/remotes/origin/MOODLE_25_STABLE:refs/heads/MOODLE_25_STABLE \
                            refs/remotes/origin/MOODLE_24_STABLE:refs/heads/MOODLE_24_STABLE
# Discontinued 20140113 -   refs/remotes/origin/MOODLE_23_STABLE:refs/heads/MOODLE_23_STABLE
# Discontinued 20140113 -   refs/remotes/origin/MOODLE_19_STABLE:refs/heads/MOODLE_19_STABLE
# Discontinued 20130708 -   refs/remotes/origin/MOODLE_22_STABLE:refs/heads/MOODLE_22_STABLE
# Discontinued 20130114 -   refs/remotes/origin/MOODLE_21_STABLE:refs/heads/MOODLE_21_STABLE
# Discontinued 20120706 -   refs/remotes/origin/MOODLE_20_STABLE:refs/heads/MOODLE_20_STABLE

output "${G}Done!${N}"
exit 0
