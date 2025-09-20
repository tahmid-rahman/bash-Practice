
submissions=$1
targets=$2
tests=$3
answers=$4
noexecute=$5

# echo "${submissions}"
# echo "${targets}"
# echo "${tests}"
# echo "${answers}"
# echo "${noexecute}"

if [ "$noexecute" = "-noexecute" ]; then


mkdir -p $targets/C $targets/Python $targets/Java

for file in "$submissions"/*.zip
    do
        filename="${file%.*}"
    
        # studentid=${filename: -9}
        # echo "${studentid}"

        studentid="${filename##*_}"
        # echo "${temp}"

        tmpdir=$(mktemp -d)
        unzip -q "$file" -d "$tmpdir"

        code=$(find "$tmpdir" -type f \( -name "*.c" -or -name "*.py" -or -name "*.java" \))

        if [[ $code == *.c ]]; then

            mkdir -p "$targets/C/$studentid"
            cp "$code" "$targets/C/$studentid/main.c"


        elif [[ $code == *.py ]]; then

            mkdir -p "$targets/Python/$studentid"
            cp "$code" "$targets/Python/$studentid/main.py"


        elif [[ $code == *.java ]]; then

            mkdir -p "$targets/Java/$studentid"
            cp "$code" "$targets/Java/$studentid/Main.java"

        fi
        rm -rf "$tmpdir"

    done


elif [ "$noexecute" = "" ]; then

tests=$(realpath "$tests")
answers=$(realpath "$answers")

# echo -e "Student ID\tLanguage\tMatched\tUnmatched" > "result.csv"
printf "Student ID\tLanguage\tMatched\tUnmatched\n" > "result.csv"

for lang in C Python Java; do
    for dir in "$targets/$lang"/*; do
        studentid=$(basename "$dir")
        matched=0
        unmatched=0

        # Go into student directory
        cd "$dir" || exit

        # Compile if needed
        if [ "$lang" = "C" ]; then
            gcc -o main main.c
        elif [ "$lang" = "Java" ]; then
            javac Main.java
        fi

        for i in {1..3}; do
            testfile="$tests/test$i.txt"
            ansfile="$answers/ans$i.txt"
            outfile="out$i.txt"

            if [ "$lang" = "C" ]; then
                ./main < "$testfile" > "$outfile"
            elif [ "$lang" = "Python" ]; then
                python3 main.py < "$testfile" > "$outfile"
            elif [ "$lang" = "Java" ]; then
                java Main < "$testfile" > "$outfile"
            fi

            if diff -q "$outfile" "$ansfile" >/dev/null; then
                matched=$((matched+1))
            else
                unmatched=$((unmatched+1))
            fi
        done

        cd - >/dev/null

        # echo -e "$studentid\t$lang\t$matched\t$unmatched" >> "result.csv"
        printf "$studentid\t$lang\t$matched\t$unmatched\n" >> "result.csv"
    done
done



else
    echo '-noexecute expectng'
fi