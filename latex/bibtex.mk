################################################################################
#                     Bibtex extension                                         #
################################################################################

# The name of the file generated (you have to use it in the latex file)
BIB        ?= bibliography.bib

# Program to build
BIBTEX     ?= bibtex

# Generation of the concatenated library
${BUILDDIR}/${BIB}:
	${Q}mkdir -p "${BUILDDIR}"
	${Q}cat /dev/null $^ >$@

# Syntax-sugar
define bib-include
$(eval ${BUILDDIR}/${BIB}: $(1))
endef

# The bibtex rule
${BUILDDIR}/%.bbl: ${BUILDDIR}/%.aux
	${Q}$(call inform,bibtex)
	${Q}cd "${BUILDDIR}" && ${chronic} ${BIBTEX} "$*"

# Dependency wiring
define bibtex-rule
${BUILDDIR}/$(2).aux: ${BUILDDIR}/${BIB}
${BUILDDIR}/$(2).pdf: ${BUILDDIR}/$(2).bbl
endef

LATEX_SELF_DEPS += bbl bib

define bibtex
$(foreach N,$(strip $(1)),$(eval $(call bibtex-rule,${N},$(notdir $(basename ${N})))))
endef

# Automatic downloader from TUG:
#
# $(call bib-tug, path/<name on TUG>.bib)
#
# Does not download to builddir, because those files rarely change. In case of such event, just delete it manually :)
#
define bib-tug-download
$(1):
	${Q}$$(call informp,wget,$(basename $(notdir $(1))),$$@)
	${Q}mkdir -p "$(dir $(1))"
	${Q}wget --quiet --output-document=$$@ http://ftp.math.utah.edu/pub/tex/bib/$(basename $(notdir $(1))).bib

${BUILDDIR}/${BIB}: $(1)
endef

define bib-tug
$(foreach N,$(strip $(1)),$(eval $(call bib-tug-download,$N)))
endef

# vim: ft=make
