#!/bin/sh

cleanup() {
    cd "$home"
    rm -rf "$tmp"
}

absolute() {
    case "$1" in
        /*) echo "$1";;
        *) echo "$PWD/$1";;
    esac
}

extract() {
    dir="$1"
    tape="$2"
    pwd="$PWD"

    mkdir "$dir"
    cd "$dir"
    itstar xf "$tape"
    rm -- */_file_.\(dir\) */m_f_d_.\(file\)
    cd "$pwd"
}

tape1="`absolute $1`"
tape2="`absolute $2`"
home="$PWD"
tmp="$PWD/tmp.$$"
diffs="$tmp/diffs"

trap cleanup EXIT INT TERM QUIT

mkdir "$tmp"
cd "$tmp"

extract tape1 "$tape1"
extract tape2 "$tape2"

rm -f "$diffs"

output() {
    echo "$1: $2"
    echo "$2" >> "$diffs"
}

diff_file() {
    nfile="$1"
    ofile="../tape1/$1"
    if test -L "$nfile"; then
        if test -L "$ofile"; then
            l1=`readlink "$ofile"`
            l2=`readlink "$nfile"`
            if test "$l1" \!= "$l2"; then
                output "UPDATED LINK" "$nfile"
            fi
        else
            output "NEW LINK" "$nfile"
        fi
    elif test -f "$ofile"; then
        if cmp -- "$nfile" "$ofile" > /dev/null; then
            :
        else
            dis10 "$nfile" 2> /dev/null | grep -v -e 'Creation time:' -e 'Symbol ' -e '^[0-7][0-7][0-7]   [0-7]' > "$tmp/TMP1"
            dis10 "$ofile" 2> /dev/null | grep -v -e 'Creation time:' -e 'Symbol ' -e '^[0-7][0-7][0-7]   [0-7]' > "$tmp/TMP2"
            if cmp -- "$tmp/TMP1" "$tmp/TMP2" > /dev/null; then
                :
            else
                output "UPDATED FILE" "$nfile"
            fi
        fi
    else
        output "NEW FILE" "$nfile"
    fi
}

cd tape2
for dir in *; do
    if test -d "../tape1/$dir"; then
        for file in $dir/*; do
            test -r "$file" && diff_file "$file"
        done
    else
        output "NEW DIRECTORY" "$dir"
    fi
done

cd "$tmp/tape2"
head -1 "$diffs" | xargs itstar cvf "$home/diffs.tap"
tail +2 "$diffs" | xargs itstar rvf "$home/diffs.tap"
rm "$diffs"

cd "$home"
