CFLAGS=-std=c11 -g -fno-common -Wall -Wno-switch -lcurl

SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

TEST_SRCS=$(wildcard test/*.ç)
TESTS=$(TEST_SRCS:.ç=.exe)

# Stage 1

cç: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	$(CC) $(CFLAGS) -fPIC -c ./std/libest.c -o ./lib/libest.a

$(OBJS): c_trencada.h

test/%.exe: cç test/%.ç
	./cç -Iinclude -Itest -c -o test/$*.o test/$*.ç
	$(CC) -pthread -o $@ -L./lib/ -lest test/$*.o -xc test/common

test: $(TESTS)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./cç

# Misc.

clean:
	rm -rf cç tmp* $(TESTS) test/*.s test/*.exe
	find * -type f '(' -name '*~' -o -name '*.o' ')' -exec rm {} ';'

.PHONY: test clean test-stage2
