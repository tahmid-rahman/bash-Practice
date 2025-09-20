#!/bin/bash

submissions=$1
targets=$2
tests=$3
answers=$4
noexecute=$5

mkdir -p "$targets"/{C,Python,Java}

for file in "$submissions"/*.zip; do
    filename="${file%.*}"
    studentid="${filename##*_}"

    tmpdir=$(mktemp -d)
    unzip -q "$file" -d "$tmpdir"

    code=$(find "$tmpdir" -type f \( -name "*.c" -o -name "*.py" -o -name "*.java" \))

    case "$code" in
        *.c)
            mkdir -p "$targets/C/$studentid"
            cp "$code" "$targets/C/$studentid/main.c"
            ;;
        *.py)
            mkdir -p "$targets/Python/$studentid"
            cp "$code" "$targets/Python/$studentid/main.py"
            ;;
        *.java)
            mkdir -p "$targets/Java/$studentid"
            cp "$code" "$targets/Java/$studentid/Main.java"
            ;;
    esac

    rm -rf "$tmpdir"
done

if [ "$noexecute" = "-noexecute" ]; then
    tests=$(realpath "$tests")
    answers=$(realpath "$answers")

    echo -e "Student ID\tLanguage\tMatched\tUnmatched" > result.csv

    for lang in C Python Java; do
        for dir in "$targets/$lang"/*; do
            [ -d "$dir" ] || continue

            studentid=$(basename "$dir")
            matched=0
            unmatched=0

            cd "$dir" || exit

            case "$lang" in
                C) gcc -o main main.c ;;
                Java) javac Main.java ;;
            esac

            for i in {1..3}; do
                testfile="$tests/test$i.txt"
                ansfile="$answers/ans$i.txt"
                outfile="out$i.txt"

                case "$lang" in
                    C) ./main < "$testfile" > "$outfile" ;;
                    Python) python3 main.py < "$testfile" > "$outfile" ;;
                    Java) java Main < "$testfile" > "$outfile" ;;
                esac

                if diff -q "$outfile" "$ansfile" >/dev/null; then
                    matched=$((matched+1))
                else
                    unmatched=$((unmatched+1))
                fi
            done

            cd - >/dev/null
            echo -e "$studentid\t$lang\t$matched\t$unmatched" >> result.csv
        done
    done
fi
