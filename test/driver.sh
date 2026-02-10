#!/bin/bash
tmp=`mktemp -d /tmp/cç-test-XXXXXX`
trap 'rm -rf $tmp' INT TERM HUP EXIT
echo > $tmp/empty.ç

check() {
    if [ $? -eq 0 ]; then
        echo "testing $1 ... passed"
    else
        echo "testing $1 ... failed"
        exit 1
    fi
}

# -o
rm -f $tmp/out
./cç -c -o $tmp/out $tmp/empty.ç
[ -f $tmp/out ]
check -o

# --help
./cç --help 2>&1 | grep -q cç
check --help

# -S
echo 'ent principal() {}' | ./cç -S -o- -xc - | grep -q 'main:'
check -S

# Default output file
rm -f $tmp/out.o $tmp/out.s
echo 'ent principal() {}' > $tmp/out.ç
(cd $tmp; $OLDPWD/cç -c out.ç)
[ -f $tmp/out.o ]
check 'default output file'

(cd $tmp; $OLDPWD/cç -c -S out.ç)
[ -f $tmp/out.s ]
check 'default output file'

# Multiple input files
rm -f $tmp/fou.o $tmp/bar.o
echo 'ent x;' > $tmp/fou.ç
echo 'ent y;' > $tmp/bar.ç
(cd $tmp; $OLDPWD/cç -c $tmp/fou.ç $tmp/bar.ç)
[ -f $tmp/fou.o ] && [ -f $tmp/bar.o ]
check 'multiple input files'

rm -f $tmp/fou.s $tmp/bar.s
echo 'ent x;' > $tmp/fou.ç
echo 'ent y;' > $tmp/bar.ç
(cd $tmp; $OLDPWD/cç -c -S $tmp/fou.ç $tmp/bar.ç)
[ -f $tmp/fou.s ] && [ -f $tmp/bar.s ]
check 'multiple input files'

# Run linker
rm -f $tmp/fou
echo 'ent principal() { retorna 0; }' | ./cç -o $tmp/fou -xc -xc -
$tmp/fou
check linker

rm -f $tmp/fou
echo 'ent bar(); ent principal() { retorna bar(); }' > $tmp/fou.ç
echo 'ent bar() { retorna 42; }' > $tmp/bar.ç
./cç -o $tmp/fou $tmp/fou.ç $tmp/bar.ç
$tmp/fou
[ "$?" = 42 ]
check linker

# a.out
rm -f $tmp/a.out
echo 'ent principal() {}' > $tmp/fou.ç
(cd $tmp; $OLDPWD/cç fou.ç)
[ -f $tmp/a.out ]
check a.out

# -E
echo fou > $tmp/out
echo "#inclou \"$tmp/out\"" | ./cç -E -xc - | grep -q fou
check -E

echo fou > $tmp/out1
echo "#inclou \"$tmp/out1\"" | ./cç -E -o $tmp/out2 -xc -
cat $tmp/out2 | grep -q fou
check '-E and -o'

# -I
mkdir $tmp/dir
echo fou > $tmp/dir/i-option-test
echo "#inclou \"i-option-test\"" | ./cç -I$tmp/dir -E -xc - | grep -q fou
check -I

# -D
echo fou | ./cç -Dfou -E -xc - | grep -q 1
check -D

# -D
echo fou | ./cç -Dfou=bar -E -xc - | grep -q bar
check -D

# -U
echo fou | ./cç -Dfou=bar -Ufou -E -xc - | grep -q fou
check -U

# ignored options
./cç -c -O -Wall -g -std=c11 -ffreestanding -fno-builtin \
         -fno-omit-frame-pointer -fno-stack-protector -fno-strict-aliasing \
         -m64 -mno-red-zone -w -o /dev/null $tmp/empty.ç
check 'ignored options'

# BOM marker
printf '\xef\xbb\xbfxyz\n' | ./cç -E -o- -xc - | grep -q '^xyz'
check 'BOM marker'

# en_línia functions
echo 'en_línia buit fou() {}' > $tmp/en_línia1.ç
echo 'en_línia buit fou() {}' > $tmp/en_línia2.ç
echo 'ent principal() { retorna 0; }' > $tmp/en_línia3.ç
./cç -o /dev/null $tmp/en_línia1.ç $tmp/en_línia2.ç $tmp/en_línia3.ç
check en_línia

echo 'extern en_línia buit fou() {}' > $tmp/en_línia1.ç
echo 'ent fou(); ent principal() { fou(); }' > $tmp/en_línia2.ç
./cç -o /dev/null $tmp/en_línia1.ç $tmp/en_línia2.ç
check en_línia

echo 'estàtic en_línia buit f1() {}' | ./cç -o- -S -xc - | grep -v -q f1:
check en_línia

echo 'estàtic en_línia buit f1() {} buit fou() { f1(); }' | ./cç -o- -S -xc - | grep -q f1:
check en_línia

echo 'estàtic en_línia buit f1() {} estàtic en_línia buit f2() { f1(); } buit fou() { f1(); }' | ./cç -o- -S -xc - | grep -q f1:
check en_línia

echo 'estàtic en_línia buit f1() {} estàtic en_línia buit f2() { f1(); } buit fou() { f1(); }' | ./cç -o- -S -xc - | grep -v -q f2:
check en_línia

echo 'estàtic en_línia buit f1() {} estàtic en_línia buit f2() { f1(); } buit fou() { f2(); }' | ./cç -o- -S -xc - | grep -q f1:
check en_línia

echo 'estàtic en_línia buit f1() {} estàtic en_línia buit f2() { f1(); } buit fou() { f2(); }' | ./cç -o- -S -xc - | grep -q f2:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() {}' | ./cç -o- -S -xc - | grep -v -q f1:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() {}' | ./cç -o- -S -xc - | grep -v -q f2:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() { f1(); }' | ./cç -o- -S -xc - | grep -q f1:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() { f1(); }' | ./cç -o- -S -xc - | grep -q f2:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() { f2(); }' | ./cç -o- -S -xc - | grep -q f1:
check en_línia

echo 'estàtic en_línia buit f2(); estàtic en_línia buit f1() { f2(); } estàtic en_línia buit f2() { f1(); } buit fou() { f2(); }' | ./cç -o- -S -xc - | grep -q f2:
check en_línia

# -idirafter
mkdir -p $tmp/dir1 $tmp/dir2
echo fou > $tmp/dir1/idirafter
echo bar > $tmp/dir2/idirafter
echo "#inclou \"idirafter\"" | ./cç -I$tmp/dir1 -I$tmp/dir2 -E -xc - | grep -q fou
check -idirafter
echo "#inclou \"idirafter\"" | ./cç -idirafter $tmp/dir1 -I$tmp/dir2 -E -xc - | grep -q bar
check -idirafter

# -fcommon
echo 'ent fou;' | ./cç -S -o- -xc - | grep -q '\.comm fou'
check '-fcommon (default)'

echo 'ent fou;' | ./cç -fcommon -S -o- -xc - | grep -q '\.comm fou'
check '-fcommon'

# -fno-common
echo 'ent fou;' | ./cç -fno-common -S -o- -xc - | grep -q '^fou:'
check '-fno-common'

# -include
# echo fou > $tmp/out.cç
# echo bar | ./cç -include $tmp/out.cç -E -o- -xc - | grep -q -z 'fou.*bar'
# check -include
# echo NULL | ./cç -Iinclude -include stdio.cç -E -o- -xc - | grep -q 0
# check -include

# -x
echo 'ent x;' | ./cç -c -xc -o $tmp/fou.o -
check -xc
echo 'x:' | ./cç -c -x assembler -o $tmp/fou.o -
check '-x assembler'

echo 'ent x;' > $tmp/fou.ç
./cç -c -x assembler -x none -o $tmp/fou.o $tmp/fou.ç
check '-x none'

# -E
echo fou | ./cç -E - | grep -q fou
check -E

# .a file
echo 'buit fou() {}' | ./cç -c -xc -o $tmp/fou.o -
echo 'buit bar() {}' | ./cç -c -xc -o $tmp/bar.o -
ar rcs $tmp/fou.a $tmp/fou.o $tmp/bar.o
echo 'buit fou(); buit bar(); ent principal() { fou(); bar(); }' > $tmp/principal.ç
./cç -o $tmp/fou $tmp/principal.ç $tmp/fou.a
check '.a'

# .so file
# echo 'buit fou() {}' | cc -fPIC -c -xc -o $tmp/fou.o -
# echo 'buit bar() {}' | cc -fPIC -c -xc -o $tmp/bar.o -
# cc -shared -o $tmp/fou.so $tmp/fou.o $tmp/bar.o
# echo 'buit fou(); buit bar(); ent principal() { fou(); bar(); }' > $tmp/principal.ç
# ./cç -o $tmp/fou $tmp/principal.ç $tmp/fou.so
# check '.so'

./cç -hashmap-test
check 'hashmap'

# -M
echo '#inclou "out2.cç"' > $tmp/out.ç
echo '#inclou "out3.cç"' >> $tmp/out.ç
touch $tmp/out2.cç $tmp/out3.cç
./cç -M -I$tmp $tmp/out.ç | grep -q -z '^out.o: .*/out\.ç .*/out2\.cç .*/out3\.cç'
check -M

# -MF
./cç -MF $tmp/mf -M -I$tmp $tmp/out.ç
grep -q -z '^out.o: .*/out\.ç .*/out2\.cç .*/out3\.cç' $tmp/mf
check -MF

# -MP
./cç -MF $tmp/mp -MP -M -I$tmp $tmp/out.ç
grep -q '^.*/out2.cç:' $tmp/mp
check -MP
grep -q '^.*/out3.cç:' $tmp/mp
check -MP

# -MT
./cç -MT fou -M -I$tmp $tmp/out.ç | grep -q '^fou:'
check -MT
./cç -MT fou -MT bar -M -I$tmp $tmp/out.ç | grep -q '^fou bar:'
check -MT

# -MD
echo '#inclou "out2.cç"' > $tmp/md2.ç
echo '#inclou "out3.cç"' > $tmp/md3.ç
(cd $tmp; $OLDPWD/cç -c -MD -I. md2.ç md3.ç)
grep -q -z '^md2.o:.* md2\.ç .* ./out2\.cç' $tmp/md2.d
check -MD
grep -q -z '^md3.o:.* md3\.ç .* ./out3\.cç' $tmp/md3.d
check -MD

./cç -c -MD -MF $tmp/md-mf.d -I. $tmp/md2.ç
grep -q -z '^md2.o:.*md2\.ç .*/out2\.cç' $tmp/md-mf.d
check -MD

echo 'extern ent bar; ent fou() { retorna bar; }' | ./cç -fPIC -xc -c -o $tmp/fou.o -
cc -shared -o $tmp/fou.so $tmp/fou.o
echo 'ent fou(); ent bar=3; ent principal() { fou(); }' > $tmp/principal.ç
./cç -o $tmp/fou $tmp/principal.ç $tmp/fou.so
check -fPIC

# #inclou_següent
mkdir -p $tmp/next1 $tmp/next2 $tmp/next3
echo '#inclou "file1.cç"' > $tmp/file.ç
echo '#inclou_següent "file1.cç"' > $tmp/next1/file1.cç
echo '#inclou_següent "file2.cç"' > $tmp/next2/file1.cç
echo 'fou' > $tmp/next3/file2.cç
./cç -I$tmp/next1 -I$tmp/next2 -I$tmp/next3 -E $tmp/file.ç | grep -q fou
check '#inclou_següent'

# -static
echo 'extern ent bar; ent fou() { retorna bar; }' > $tmp/fou.ç
echo 'ent fou(); ent bar=3; ent principal() { fou(); }' > $tmp/bar.ç
./cç -static -o $tmp/fou $tmp/fou.ç $tmp/bar.ç
check -static
file $tmp/fou | grep -q 'statically linked'
check -static

# -shared
echo 'extern ent bar; ent fou() { retorna bar; }' > $tmp/fou.ç
echo 'ent fou(); ent bar=3; ent principal() { fou(); }' > $tmp/bar.ç
./cç -fPIC -shared -o $tmp/fou.so $tmp/fou.ç $tmp/bar.ç
check -shared

# -L
echo 'extern ent bar; ent fou() { retorna bar; }' > $tmp/fou.ç
./cç -fPIC -shared -o $tmp/libfoubar.so $tmp/fou.ç
echo 'ent fou(); ent bar=3; ent principal() { fou(); }' > $tmp/bar.ç
./cç -o $tmp/fou $tmp/bar.ç -L$tmp -lfoubar
check -L

# -Wl,
echo 'ent fou() {}' | ./cç -c -o $tmp/fou.o -xc -
echo 'ent fou() {}' | ./cç -c -o $tmp/bar.o -xc -
echo 'ent principal() {}' | ./cç -c -o $tmp/baz.o -xc -
cc -Wl,-z,muldefs,--gc-sections -o $tmp/fou $tmp/fou.o $tmp/bar.o $tmp/baz.o
check -Wl,

# -Xlinker
echo 'ent fou() {}' | ./cç -c -o $tmp/fou.o -xc -
echo 'ent fou() {}' | ./cç -c -o $tmp/bar.o -xc -
echo 'ent principal() {}' | ./cç -c -o $tmp/baz.o -xc -
cc -Xlinker -z -Xlinker muldefs -Xlinker --gc-sections -o $tmp/fou $tmp/fou.o $tmp/bar.o $tmp/baz.o
check -Xlinker

echo OK
