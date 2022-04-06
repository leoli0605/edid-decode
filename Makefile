ifeq ($(OS),Windows_NT)
	bindir ?= /usr/bin
	mandir ?= /usr/share/man
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		bindir ?= /usr/local/sbin
		mandir ?= /usr/local/share/man
	else
		bindir ?= /usr/bin
		mandir ?= /usr/share/man
	endif
endif

EMXX ?= em++

SOURCES = edid-decode.cpp parse-base-block.cpp parse-cta-block.cpp \
	  parse-displayid-block.cpp parse-ls-ext-block.cpp \
	  parse-di-ext-block.cpp parse-vtb-ext-block.cpp \
	  calc-gtf-cvt.cpp calc-ovt.cpp
WARN_FLAGS = -Wall -Wextra -Wno-missing-field-initializers -Wno-unused-parameter -Wimplicit-fallthrough

all: edid-decode

sha = -DSHA=$(shell if test -d .git ; then git rev-parse --short=12 HEAD ; fi)
date = -DDATE=$(shell if test -d .git ; then TZ=UTC git show --quiet --date='format-local:"%F %T"' --format='%cd'; fi)

edid-decode: $(SOURCES) edid-decode.h oui.h Makefile
	$(CXX) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(WARN_FLAGS) -g $(sha) $(date) -o $@ $(SOURCES) -lm

edid-decode.js: $(SOURCES) edid-decode.h oui.h Makefile
	$(EMXX) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(WARN_FLAGS) $(sha) $(date) -s EXPORTED_FUNCTIONS='["_parse_edid"]' -s EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' -o $@ $(SOURCES) -lm

clean:
	rm -f edid-decode edid-decode.js edid-decode.wasm

install:
	mkdir -p $(DESTDIR)$(bindir)
	install -m 0755 edid-decode $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(mandir)/man1
	install -m 0644 edid-decode.1 $(DESTDIR)$(mandir)/man1
