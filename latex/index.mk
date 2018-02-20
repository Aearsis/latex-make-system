################################################################################
#                     Makeindex extension                                      #
################################################################################

# Dependency wiring
LATEX_SELF_DEPS += nls nlo

# Syntax sugar
define makeindex-rule
${BUILDDIR}/$(2).pdf: ${BUILDDIR}/$(2).nls
endef

define makeindex
$(foreach N,$(strip $(1)),$(eval $(call makeindex-rule,${N},$(notdir $(basename ${N})))))
endef

# The makeindex rule
${BUILDDIR}/%.nls: ${BUILDDIR}/%.aux
	${Q}$(call inform,makeindex)
	${Q}cd "${BUILDDIR}" && ${chronic} makeindex "$*.nlo" -s nomencl.ist -o "$*.nls"

# vim: ft=make
