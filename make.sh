#!/bin/sh
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

RESET="\e[0m"
ERROR="\e[31m"

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

print()
{
	echo
	echo "=====[$@]====="
	echo
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
	CMD="$CC $CCSARGS -c "$1" -o "$path/$filename" -Iinclude/"
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
	
	$DEBUG || strip --strip-unneeded lib/*
}

build_test()
{
	path="obj/`echo "$1" | sed -E "s|\/[^\/]+$||g"`"
	filename="`echo "$1" | grep -Eo "[^\/]+$" | sed -E "s|\.[^.]$||g"`.o"
	objfile="$path/$filename"
	CMD="$CC $CCSARGS -c "$1" -o "$objfile" -Iinclude/"
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
	
	$DEBUG || strip --strip-all bin/*
}

gen_test()
{
	fileName="`echo "$1" | grep -Eo "\/[^\/]+$"`"
	[ "$fileName" = "test_main" ] || echo "`"$1" 2>&1`" > "$TESTDIR/$fileName"
}

gen_tests()
{
	print "Generating test outcomes..."
	for exec in "bin/"*; do
		gen_test "$exec" &
	done
	wait
}

run_test()
{
	echo "$file"
}

run_tests()
{
	echo -n "Testing test_main..."
	./bin/test_main
	[ $? -eq "84" ] && echo || echo "${ERROR}test_main did not return 84.${RESET}"
	for file in "$TESTDIR/"*; do
		run_test "$file" &
	done
	wait
}



build_libs

build_tests

gen_tests

run_tests
