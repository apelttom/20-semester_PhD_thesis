# Compiler specific defines
#
# File : mc_CodeWarrior.mk

# ------------------------------ Tools --------------------------------
#
# Compiler, assembler, linker, librarian, object tool
# perl interpreter, system tools

CC     = $(COMPILER_ROOT)\bin\C166
AS     = $(COMPILER_ROOT)\bin\A166
LD     = $(COMPILER_ROOT)\bin\L166
LIB    = $(COMPILER_ROOT)\lib
LIBCMD = $(COMPILER_ROOT)\bin\LIB166
OH     = $(COMPILER_ROOT)\bin\OH166

PERL   = $(MATLAB_ROOT)\sys\perl\win32\bin\perl
RM     = del


# ------------------- Memory model dependent options ------------------
#
# Compiler, assembler, linker, librarian, object tool
# perl interpreter, system tools

ifeq ($(MemModel), Flash_flat)

# 'flat' memory model
DEFAULT_OPT_OPTS = \
	LARGE MOD167 NOFIXDPP WARNING disable = 47,91,98,138,180,322 STATIC
	
else

# 'banked' memory model
DEFAULT_OPT_OPTS = \
	HLARGE MOD167 NOFIXDPP WARNING disable = 47,91,98,138,180,322 STATIC
	
endif


# ----------------- Compiler includes, system libraries ----------------
#
# e.g. 'math.h', ..., 'ansis.lib', ...,  etc.

COMPILER_INCLUDES  = $(COMPILER_ROOT)\lib\hc12c\include
COMPILER_LIBRARIES = $(COMPILER_ROOT)\lib\hc12c\lib



# ---------------------------- Compiler flags ---------------------------
#
# compiler options, compiler defines, include files

# Optimization Options
OPT_OPTS = $(DEFAULT_OPT_OPTS)

# General User Options
OPTS =

# Compiler options, etc:
CC_OPTS = $(OPT_OPTS) $(ANSI_OPTS) $(EXT_CC_OPTS) $(RTM_CC_OPTS)


# all compiler flags
CFLAGS = $(CC_OPTS) INCDIR ($(INCLUDES)) DEFINE(RT,NUMST=$(NUMST))


# ---------------------------- Assembler flags ---------------------------
#
# assembler options, assembler defines, include files

ifeq ($(MemModel), Flash_flat)

# 'flat' memory model
AFLAGS = SET (COMPACT)
MEM_EXTENSION =_C
	
else

# 'banked' memory model
AFLAGS = SET (LARGE)
MEM_EXTENSION =_L
	
endif


# ----------------------------- Linker flags ----------------------------
#
# linker options, linker defines, include files

ifeq ($(MemModel), Flash_flat)

# 'flat' memory model
LD_OPTS1 = VECTAB (00000H) \
           DPPUSE (0=NDATA(0x100000-0x10BFFF), 3=NCONST(0x00C000-0x00DFFF)) \
           RESERVE (0x00E000-0x00EFFF) \
           IXREF
LD_OPTS2 = CLASSES (NCODE(0x000000-0x00BFFF), \
                    NCONST(0x00C000-0x00DFFF), FCONST(0x00C000-0x00DFFF), \
                    IDATA(0x00F800-0x00FDFF), IDATA0(0x00F800-0x00FDFF), \
                    NDATA(0x100000-0x10BFFF), NDATA0(0x100000-0x10BFFF), \
                    FDATA(0x100000-0x10FFFF), FDATA0(0x100000-0x10FFFF))
	
else

# 'banked' memory model
LD_OPTS1 = VECTAB (00000H) \
           DPPUSE (0=NDATA(0x100000-0x10BFFF), 3=NCONST(0x00C000-0x00DFFF)) \
           RESERVE (0x00E000-0x00EFFF) \
           IXREF
LD_OPTS2 = CLASSES (FCODE(0x000000-0x00BFFF, 0x010000-0x03FFFF), \
                    NCONST(0x00C000-0x00DFFF), FCONST(0x00C000-0x00DFFF), \
                    IDATA(0x00F800-0x00FDFF), IDATA0(0x00F800-0x00FDFF), \
                    NDATA(0x100000-0x10BFFF), NDATA0(0x100000-0x10BFFF), \
                    FDATA(0x10C000-0x13FFFF), FDATA0(0x10C000-0x13FFFF), \
                    HDATA(0x10C000-0x13FFFF), HDATA0(0x10C000-0x13FFFF))
	
endif


# all linker options
LDFLAGS = $(LD_OPTS1) $(LD_OPTS2)


# --------------------- Export environment variables --------------------
#
# ... if required.

#export C166LIB = $(COMPILER_LIBRARIES)
#export C166INC = $(COMPILER_INCLUDES)

