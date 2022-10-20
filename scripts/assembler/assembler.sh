#! env bash

script_base_dir=$(cd "$(dirname $0)"; pwd -P ) # Directory path of this script

usage(){
	echo "Usage: $(basename $0) <dlx_assembly_file>.asm [imem_init_symbolic_link.txt path]"
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
output_dir=$(readlink -f "$(dirname $1)")
asmfile="${basename_asmfile%.*}" # remove extension

ASSEMBLER_PATH="$script_base_dir/dlxasm.pl"

perl $ASSEMBLER_PATH -o "$output_dir/$asmfile.bin" -list "$output_dir/$asmfile.list" "$1"
rm "$output_dir/$asmfile.bin.hdr"
cat "$output_dir/$asmfile.bin"| hexdump -v -e '/1 "%02X" /1 "%02X" /1 "%02X" /1 "%02X\n"' > "$output_dir/${asmfile}_dump.txt"

if [ ! -L "$2" ]; then
    ##echo "$2 not a symbolic link"
    exit 0;
fi

## Link file to the asmfile_dump.txt
echo "Linking '$output_dir/${asmfile}_dump.txt' to '$(realpath -s $2)' "
## found here https://unix.stackexchange.com/a/513357
ln -fs $(realpath --relative-to="$(dirname "$2")" "$output_dir/${asmfile}_dump.txt") "$2"
## sanity check 
ls -l --color=always "$2"
