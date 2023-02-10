#!/bin/bash

# Folders with the components to test
test_folders=(
    'xnor'
    'xnor_array'
    'adder'
    'register_dff'
    'regfile'
    'popcount'
    'accumulator'
    'comparator'
    'accumulator_multiregs'
    'computing_column_vm'
    'computing_column_sm'
)

# If there are no command line parameters, then test all cases
if [ $# -eq 0 ]; then
for test_folder in "${test_folders[@]}"; do
  printf "\n------ Test for ${test_folder} ------\n"
  cd $test_folder
  make
  cd ..
done
exit 0
fi

# If there are command line parameters, execute the following options
while test $# -gt 0; do
  case "$1" in
    -r| --remove)
      for test_folder in "${test_folders[@]}"; do
        cd $test_folder
        if [ -d "__pycache__" ]; then
          rm -r "__pycache__"
        fi
        if [ -d "sim_build" ]; then
          rm -r "sim_build"
        fi
        if [ -f "anyname.vcd" ]; then
          rm "anyname.vcd"
        fi
        if [ -f "results.xml" ]; then
          rm "results.xml"
        fi
        cd ..
      done
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done
