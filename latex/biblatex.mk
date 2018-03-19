################################################################################
#                     Biblatex extension                                       #
################################################################################

BIBER     ?= biber

define biblatex-rule
${BUILDDIR}/$(2).pdf: ${BUILDDIR}/$(2).bbl

${BUILDDIR}/$(2).bbl: ${BUILDDIR}/$(2).aux
	${Q}$(call informp,biber,$(2).bcf,$(2).bbl)
	${Q}${chronic} ${BIBER} --output_directory ${BUILDDIR} $(2)
endef

LATEX_SELF_DEPS += bbl bcf

define biblatex
$(foreach N,$(strip $(1)),$(eval $(call biblatex-rule,${N},$(notdir $(basename ${N})))))
endef

# TODO: .bib files are read by biber, not by pdflatex, and therefore do not
#       work as autowired dependencies. We need to get the filenames read.
#       Extract the filenames from .blg, or is there a better way?
#       For now, just use latex-include for the bib files.

# vim: ft=make
