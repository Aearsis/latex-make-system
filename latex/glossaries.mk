################################################################################
#                     Glossaries extension                                     #
################################################################################

# Dependency wiring
LATEX_SELF_DEPS += gls glo acn acr

# Syntax sugar
define glossaries-rule
${BUILDDIR}/$(2).pdf: ${BUILDDIR}/$(2).gls
endef

${BUILDDIR}/%.gls: ${BUILDDIR}/%.aux
	${Q}$(call inform,makeglossaries)
	${Q}${chronic} makeglossaries  -d ${BUILDDIR} "$*"

define glossaries
$(foreach N,$(strip $(1)),$(eval $(call glossaries-rule,${N},$(notdir $(basename ${N})))))
endef


# vim: ft=make
