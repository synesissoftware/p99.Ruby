#! /bin/bash

#############################################################################
# File:     generate_rdoc.sh
#
# Purpose:  Generates documentation
#
# Created:  11th June 2016
# Updated:  30th August 2026
#
#############################################################################

ScriptPath="${BASH_SOURCE[0]}"
while [ -h "$ScriptPath" ]; do

  ScriptDir="$(cd -P "$(dirname "$ScriptPath")" && pwd)"
  ScriptPath="$(readlink "$ScriptPath")"
  [[ "$ScriptPath" != /* ]] && ScriptPath="$ScriptDir/$ScriptPath"
done
ScriptDir="$(cd -P "$(dirname "$ScriptPath")" && pwd)"
ProjectNameFile="$ScriptDir/.sis/project_name.txt"
if [ -f "$ProjectNameFile" ]; then

  ProjectName=$(tr -d '[:space:]' < "$ProjectNameFile")
else

  ProjectName=$(basename "$ScriptDir")
fi

ProjectDir="$ScriptDir"
ForwardArgs=()
FoundHelp=

print_help() {

  if [ -f "$ScriptDir/.sis/script_info_lines.txt" ]; then

    cat "$ScriptDir/.sis/script_info_lines.txt"
  fi

  cat << EOF
Generates RDoc documentation for $ProjectName

$ScriptPath [ ... flags/options ... ]

Flags/options:

    --pwd
        operates in the caller's current directory instead of the
        script's directory

    -C
    --coverage-report
        generates an RDoc coverage report and fails if the report is
        less than 100% documented

    --help
        displays this help and terminates

Environment variables:

    SIS_RDOC_DOC_DIR
        sets the generated-document directory (default: doc)

EOF
}

for arg in "$@"
do

  case "$arg" in
    --pwd)

      ProjectDir="$(pwd)"
      ;;
    --help)

      FoundHelp=1
      ;;
    *)

      ForwardArgs+=("$arg")
      ;;
  esac
done

if [ -n "$FoundHelp" ]; then

  print_help
  exit 0
fi

if ! cd "$ProjectDir"; then

  >&2 echo "$0: project directory '$ProjectDir' not found"
  exit 1
fi

DocDir="${SIS_RDOC_DOC_DIR:-doc}"
rm -rfd "$DocDir"

run_rdoc() {

  rdoc \
    --title "$ProjectName API Reference" \
    --op "$DocDir" \
    -x build_gem.cmd \
    -x build_gem.sh \
    -x generate_rdoc.cmd \
    -x generate_rdoc.sh \
    -x run_all_unit_tests.sh \
    -x '.*\.gemspec' \
    -x '.*\.gem' \
    -x '.*\.md' \
    -x Gemfile \
    -x LICENSE \
    -x Rakefile \
    \
    -x "$DocDir/" \
    -x docs/ \
    -x examples/ \
    -x gems/ \
    -x old-gems/ \
    -x test/performance/ \
    -x test/scratch/ \
    \
    -x tc_.*\.rb \
    -x ts_all.rb \
    \
    "${ForwardArgs[@]}"
}

RDocCoverage=
for arg in "${ForwardArgs[@]}"
do

  case "$arg" in
    -C|-C[0-9]*|--dcov|--coverage-report|--coverage-report=*)

      RDocCoverage=1
      ;;
  esac
done

if [ -z "$RDocCoverage" ]; then

  run_rdoc "${ForwardArgs[@]}"
else

  RDocOutput=$(run_rdoc "${ForwardArgs[@]}")
  RDocResult=$?

  printf '%s\n' "$RDocOutput"

  if [ 0 -ne "$RDocResult" ]; then

    exit "$RDocResult"
  fi

  case "$RDocOutput" in
    *'100.00% documented'*)

      ;;
    *)

      >&2 echo "$0: RDoc coverage is incomplete"
      exit 1
      ;;
  esac
fi
