# The base - framework for repeated builds.
#
# By calling latex, targets in builddir get registered.
# Every final pdf is build in the BUILDDIR first, then is hardlinked out.

# This file also defines some macros for other extensions to use.

ifndef LATEX_COMMON
LATEX_COMMON=guard

LATEX      ?= pdflatex
LATEXFLAGS ?= -halt-on-error -interaction=nonstopmode -shell-escape -recorder

BUILDDIR   ?= build

# Suffixes of files that are managed as dependencies by content
LATEX_SELF_DEPS = aux

# Suffixes of files that are automatically added as dependencies
LATEX_AUTO_DEPS = tex

# Added as additional texinputs
LATEX_INPUTS ?=

### Some common things

# If you want to debug (or see what all this is doing), comment this line
Q=@

all: pdfs
pdfs: ;

clean::
	${Q}rm -rf ${BUILDDIR}

.PHONY: all pdfs clean distclean

define inform
	printf '%16s : %s  -->  %s\n' '$(1)' '$<' '$@'
endef
define informp
	printf '%16s : %s  -->  %s\n' '$(1)' '$(strip $(2))' '$(strip $(3))'
endef
define informx
	printf '%s * %s\n' '----------------' "$(1)"
endef

# Command or empty string
define installed
$(shell which $(1) >/dev/null 2>/dev/null && echo $(1))
endef

# Suppresses output of verbose command if they complete successfully - optional but cool
chronic = $(call installed,chronic)

# Do not remove intermediately built files
.SECONDARY:

# Regex selector of lists
LATEX_SELF_DEPS_REGEX = .*\.($(subst $(eval) ,|,${LATEX_SELF_DEPS}))
LATEX_AUTO_DEPS_REGEX = .*\.($(subst $(eval) ,|,${LATEX_AUTO_DEPS}))

################################################################################
#                     The repeated build framework                             #
################################################################################

# The dependency adder syntax sugar
define latex-include
$(eval ${BUILDDIR}/.deps: $(1))
endef

# Aggregate dependencies
${BUILDDIR}/.deps: ;

define calc-md5
	(grep -E '^OUTPUT ${LATEX_SELF_DEPS_REGEX}$$' <${BUILDDIR}/$(1).fls | sort -u | cut -c8- | xargs md5sum)
endef

# Fake the dependency file for the first run
${BUILDDIR}/%.fls:
	${Q}mkdir -p "${BUILDDIR}"
	${Q}touch $@

# Compute md5 sum for all intermediate files written by pdflatex
${BUILDDIR}/%.md5: ${BUILDDIR}/%.fls
	${Q}#$(call informp,md5sum,,$@)
	${Q}$(call calc-md5,$*) >$@

# Find all files read by pdflatex (sans the build dir) and add them as dependencies
${BUILDDIR}/%.dep: ${BUILDDIR}/%.md5
	${Q}#$(call informp,sed,${BUILDDIR}/$*.fls,$@)
	${Q}sort -u ${BUILDDIR}/$*.fls | sed -nE '/^INPUT ${LATEX_AUTO_DEPS_REGEX}$$/ { s#^INPUT #${BUILDDIR}/$*.aux: #; p}' >$@

# The definition for one-time build
# "Fakes" the mtime of .fls to be the same as .md5 to prevent looping
define latex-rule
${BUILDDIR}/$(2).aux: $(1) ${BUILDDIR}/.deps ${BUILDDIR}/$(2).md5
	${Q}$(call informp,${LATEX},$$<,$$(@:.aux=.pdf))
	${Q}${chronic} ${LATEX} ${LATEXFLAGS} -output-directory "${BUILDDIR}" $(1)
	${Q}touch --reference=${BUILDDIR}/$(2).md5 ${BUILDDIR}/$(2).fls ; \

pdfs: $(2).pdf
clean::
	${Q}rm -f $(2).pdf

-include ${BUILDDIR}/$(2).dep
endef

${BUILDDIR}/%.pdf: ${BUILDDIR}/%.aux ;

%.pdf: ${BUILDDIR}/%.pdf
	+${Q}while :; do \
		$(call calc-md5,$*) >${BUILDDIR}/$*.md5-post; \
		cmp -s ${BUILDDIR}/$*.md5 ${BUILDDIR}/$*.md5-post && break ; \
		changes=$$(diff ${BUILDDIR}/$*.md5 ${BUILDDIR}/$*.md5-post | grep '^>' | cut -c43- | perl -pe 's/\n/, / unless eof'); \
		$(call informx,$$changes changed: repeating build); \
		touch ${BUILDDIR}/$*.fls; \
		${MAKE} --no-print-directory $^; \
	done
	${Q}rm ${BUILDDIR}/$*.md5-post
	${Q}ln -f $< $@

define latex
$(foreach N,$(strip $(1)),$(eval $(call latex-rule,${N},$(notdir $(basename ${N})))))
endef

endif
# vim: ft=make
