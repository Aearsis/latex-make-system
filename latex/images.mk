################################################################################
#                     Images extension                                         #
################################################################################

# Autoconvert these extensions
# More conversion options are given at the end if convertors are available
IMAGES_FORMATS_pdf = pdf
IMAGES_FORMATS_png = png
IMAGES_FORMATS_jpg = jpg
IMAGES_FORMATS = pdf png jpg

# Add images as dependencies
LATEX_AUTO_DEPS += ${IMAGES_FORMATS}

# Add one-time dependency to build all images
${BUILDDIR}/.deps: ${BUILDDIR}/.images.exist

${BUILDDIR}/.images.exist:
	${Q}touch $@

# Syntax sugar
define images
$(eval ${BUILDDIR}/.images.dep: $(1))
endef

# Dynamically built dependencies
include ${BUILDDIR}/.images.dep

${BUILDDIR}/.images.dep:
	${Q}#$(call informp,find,$^,$@)
	${Q}mkdir -p "${BUILDDIR}"
	${Q}rm -f ${BUILDDIR}/.images.exist
	${Q}( echo; $(foreach fmt,${IMAGES_FORMATS},$(foreach dir,$^,$(call find-images,${fmt},${dir}))) ) >$@

# For every directory, target suffix and source suffix, find files and output matches
define find-images
$(foreach suff,$(IMAGES_FORMATS_$(1)), \
	find $(2) -iname '*.$(suff)' | sed -r 's#^(.*)\.$(suff)$$#${BUILDDIR}/.images.exist: | ${BUILDDIR}/\1.$(1)#'; \
)
endef

# The conversion targets

${BUILDDIR}/%.pdf: %.pdf
	${Q}$(call inform,ln)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} ln -f $< $@

${BUILDDIR}/%.png: %.png
	${Q}$(call inform,ln)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} ln -f $< $@

${BUILDDIR}/%.jpg: %.jpg
	${Q}$(call inform,ln)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} ln -f $< $@

ifneq ($(call installed,epstopdf),)
${BUILDDIR}/%.pdf: %.eps
	${Q}$(call inform,epstopdf)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} epstopdf --outfile=$@ $<
IMAGES_FORMATS_pdf += eps
endif

ifneq ($(call installed,asy),)
${BUILDDIR}/%.pdf: %.asy
	${Q}$(call inform,asy)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} asy -f pdf $< -o $@
IMAGES_FORMATS_pdf += asy
endif

ifneq ($(call installed,uniconvertor),)
${BUILDDIR}/%.pdf: %.svg
	${Q}$(call inform,uniconvertor)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} uniconvertor $< $@
IMAGES_FORMATS_pdf += svg
endif

ifneq ($(call installed,inkscape),)
${BUILDDIR}/%.pdf: %.svg
	${Q}$(call inform,inkscape)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} inkscape --export-pdf=$@ $<
IMAGES_FORMATS_pdf += svg
endif

ifneq ($(call installed,convert),)
${BUILDDIR}/%.png: %.gif
	${Q}$(call inform,convert)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} convert $< $@
IMAGES_FORMATS_png += gif

${BUILDDIR}/%.jpg: %.bmp
	${Q}$(call inform,convert)
	${Q}mkdir -p $(dir $@)
	${Q}${chronic} convert $< $@
IMAGES_FORMATS_jpg += bmp
endif

# vim: ft=make
