#! env bash

script_base_dir=$(cd $(dirname $0); pwd -P ) # Directory path of this script

usage(){
	echo "Usage: $(basename $0) <dlx_assembly_file>.asm"
}

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
	exit 1
fi

if [ ! -r $1 ]; then
    echo "ERROR: File $1 doesn't exists"
    usage
	exit 1
fi
basename_asmfile=$(basename $1)  # get only file name without path
asmfile="${basename_asmfile%.*}" # remove extension

ASSEMBLER_PATH="$script_base_dir/dlxasm.pl"

perl $ASSEMBLER_PATH -o "$asmfile.bin" -list "$asmfile.list" "$1"
rm $asmfile.bin.hdr
cat $asmfile.bin | hexdump -v -e '/1 "%02X" /1 "%02X" /1 "%02X" /1 "%02X\n"' > "$asmfile_dump.txt"
