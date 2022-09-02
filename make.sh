#!/bin/sh

RESET="\e[0m"
HEADER="\e[34m"
SUCCESS="\e[32m"
ERROR="\e[31m"

print()
{
	echo
	echo -e "${HEADER}$@${RESET}"
	echo
}

print "Setting up"

CC="tcc"
AR="tcc -ar"
LD="ld.lld"
LDARGS="-Llib -nostdlib -O2"
CCARGS="-Llib -Iinclude -ffreestanding -nostdlib -Os -Wall -Wextra -Wpedantic"

DEBUG=true
$DEBUG && {
	CCARGS="$CCARGS -g"
	LDARGS="$LDARGS -g"
}

CCSARGS="$CCARGS -static"

BINDIR=bin/
OBJDIR=obj/
TESTOBJDIR=obj/tests/
LIBDIR=lib/
TESTDIR=/tmp/zlibc_tests/

DIRS="$BINDIR $OBJDIR $LIBDIR $TESTDIR $TESTOBJDIR"

in_directory()
{
	for file in "$1"/*; do
		[ -d "$file" ] && in_directory "$file" || echo "$file" | sed -E "s|\/\/|\/|g"
	done
}

CMD="mkdir -p $DIRS"
echo $CMD
$CMD

build_lib()
{
	path="obj/`echo "$1" | sed -E "s|\/[^\/]+$||g"`"
	filename="`echo "$1" | grep -Eo "[^\/]+$" | sed -E "s|\.[^.]$||g"`.o"
	ext="`echo "$1" | grep -Eo "\.[^\.]+$"`"
	mkdir -p "$path"
	CMD="$CC $CCSARGS -c "$1" -o "$path/$filename""
	echo $CMD
	$CMD
}

build_libs()
{
	print "Building ZLibC objects"
	
	for file in $(in_directory libc/); do
		build_lib "$file" &
	done
	wait
	echo wait
	
	notStart=`find obj/libc/*.o | grep -v _start`
	
	print "Building static ZLibC"
	CMD="$AR rcs lib/zlibc.a $notStart"
	echo $CMD \&
	$CMD &
	CMD="cp obj/libc/_start.o lib/_start.o"
	echo $CMD \&
	$CMD &
	
	print "Building dynamic ZLibC"
	CMD="$CC $CCARGS -shared $notStart -o lib/zlibc.so"
	echo $CMD \&
	$CMD &
	
	wait
	echo wait
	
	$DEBUG || strip --strip-unneeded lib/*
}

build_test()
{
	path="obj/`echo "$1" | sed -E "s|\/[^\/]+$||g"`"
	filename="`echo "$1" | grep -Eo "[^\/]+$" | sed -E "s|\.[^.]$||g"`.o"
	objfile="$path/$filename"
	CMD="$CC $CCSARGS -c "$1" -o "$objfile""
	echo $CMD
	$CMD
	outFile="bin/`echo "$1" | sed -E "s|tests\/||g" | sed -E "s|\.[^\.]+$||g"`"
	CMD="$LD $LDARGS "$objfile"  "lib/_start.o" "lib/zlibc.a" -o "$outFile""
	echo $CMD
	$CMD
}

build_tests()
{
	print "Building tests"
	
	for file in $(in_directory tests/); do
		build_test "$file" &
	done
	wait
	echo wait
	
	$DEBUG || strip --strip-all bin/*
}

gen_test()
{
	fileName="`echo "$1" | grep -Eo "\/[^\/]+$"`"
	if [ ! "$fileName" = "test_main" ]; then
		echo "IFS=\"\\n\" \"$1\" 2>/dev/null 1>\"$TESTDIR/$fileName\""
		IFS="\n" "$1" 2>/dev/null 1>"$TESTDIR/$fileName"
	fi
}

gen_tests()
{
	print "Generating test outcomes..."
	for exec in "bin/"*; do
		gen_test "$exec" &
	done
	wait
	echo wait
}

TESTS_ERRORED=false
run_test()
{
	test="`echo "$1" | grep -Eo "[^\/]+$"`"
	[ "$test" = "test_main" ] && exit
	assertFile="test_assertions/$test"
	diff "$1" "$assertFile" 2>/dev/null 1>/dev/null
	CODE=$?
	if [ "$CODE" -eq "0" ]; then
		echo -e "Testing $test...${SUCCESS}Success!${RESET}"
	elif [ "$CODE" -eq "2" ]; then
		echo -e "Testing $test...${ERROR}Missing assertion file!${RESET}"
		TESTS_ERRORED=true
	elif [ "$CODE" -eq "1"  ]; then
		echo -e "Testing $test...${ERROR}Assertion did not match!${RESET}"
		TESTS_ERRORED=true
	else
		echo -e "Testing $test...${ERROR}Failed due to an unknown error. Diff returned code ${CODE}${RESET}"
		TESTS_ERRORED=true
	fi
}

run_tests()
{
	print "Running tests"
	echo -n "Testing test_main..."
	./bin/test_main
	[ $? -eq "84" ] && echo -e "${SUCCESS}Success!${RESET}" || echo -e "${ERROR}Assertion did not match!${RESET}"
	for file in "$TESTDIR/"*; do
		run_test "$file" &
	done
	wait
	echo wait
}

build_libs

build_tests

gen_tests

run_tests

if $TESTS_ERRORED; then
	print "${ERROR}Some tests have failed, cannot continue :("
	exit 1
fi

print "All tests succeeded!"
