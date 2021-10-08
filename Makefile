LIBS=
SRC=main.c
DEBUG:=y
NAME:=out
IDIR=include
LDIR=lib
64BIT:=y
OPTIMIZELEVEL:=2
CFLAGS:=
LFLAGS:=
SHARED=n
CC=gcc
TESTFILENAME=test

ifeq ($(DEBUG),y)
	CFLAGS+=-g
	LFLAGS+=-g
else
	CFLAGS+=-O$(OPTIMIZELEVEL)
	LFLAGS+=-O$(OPTIMIZELEVEL)
endif

ifeq ($(64BIT),n) 
	32BITFLAG=-m32
	NAME:=$(NAME)32
endif

ifeq ($(SHARED),y) 
	LFLAGS+=-shared
	OUTFILE=$(NAME).so
else
	OUTFILE=$(NAME)
endif

LDIR?=.
IDIR?=.
ODIR=build
SRCDIR=src

.PHONY: clean fresh fresh-test test all status

$(OUTFILE): $(patsubst %.c,$(ODIR)/%.o,$(SRC))
	@echo linking $(OUTFILE)...
	@$(CC) -o $(OUTFILE) $^ $(32BITFLAG) $(LFLAGS) -L$(LDIR) $(patsubst %,-l%,$(LIBS))

 $(ODIR):
	@mkdir $@

$(TESTFILENAME): $(patsubst %.c,$(ODIR)/%.o,test.c)
	@echo building $(TESTFILENAME)
	@$(CC) -o $(TESTFILENAME) $(32BITFLAG) $^ -L. -l$(NAME)

-include $(ODIR)/.depend

$(ODIR)/.depend: $(patsubst %.c,$(SRCDIR)/%.c,$(SRC)) | $(ODIR)
	@echo building dependencies
	@-rm -rf "$@"
	@$(foreach X,$^,$(CC) $(CFLAGS) -I$(IDIR) -I$(LDIR) -MT $(patsubst $(SRCDIR)/%.c,$(ODIR)/%.o,$(X)) -MM $(X) >> "$@" && ) echo done

$(ODIR)/%.o: $(SRCDIR)/%.c | $(ODIR)
	@echo $(patsubst $(ODIR)/%,%,$@):
	@$(CC) -c -o $@ $< $(32BITFLAG) $(CFLAGS) -I$(IDIR) -I$(LDIR)

status:
	@echo -------------------------------------------------
	@echo Sources: $(SRC)
	@echo Debug: $(if $(subst y,,$(DEBUG)),no,yes)
	@echo 64-Bit: $(if $(subst y,,$(64BIT)),no,yes)
ifneq ($(DEBUG),y) 
	@echo Optimization: O$(OPTIMIZELEVEL)
endif
	@echo Shared Library: $(if $(subst y,,$(SHARED)),no,yes)
	@echo Output File: $(OUTFILE)
	@echo Libraries: $(LIBS)
	@echo CFLAGS: $(CFLAGS)
	@echo -------------------------------------------------

all: status $(OUTFILE)
test: all $(TESTFILENAME)
fresh: clrscr clean all
fresh-test: clrscr clean test

clrscr:
	@clear

clean:
	@echo cleaning up...
	@-rm -rf $(ODIR)
	@-rm -rf $(OUTFILE)