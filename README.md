# What's this?

This is an ultimate framework for making LaTeX documents. It uses a bit of
make hackery to wire almost everything automatically.

The minimal usecase looks like this:

```make
# Makefile

include latex/Makerules

$(call latex, example.tex)
```

And that's it. The file `example.pdf` can be built with `make`. This
automatically tracks dependencies on other `.tex` files and images (`.pdf`, `.png`
and `.jpg`) -- not all of them, specifically those the document depends on.

Also, it automatically repeats the build as needed - such as when TOC or
cross-references change. You can be sure that the document is final after it is
made.

## Bibliography

And there's more! It also aids with using `bibtex` to manage bibliography. Say
that you have your database in file `citations.bib`. Just use:

```make
$(call bibtex, example.tex)
$(call bibtex-include, citations.bib)
```

This automatically assembles a bibliography database in `bibliography.bib`. You
can then use it in the `.tex` document:

```tex
\bibliography{bibliography}
```

And that's it. `bibtex` is called automatically when the `.aux` files
change, and the document is rebuilt whenever the `.bbl` output changes.

## Index

Another useful feature helps with index. This one is even simpler:

```make
$(call index, example.tex)
```

And that's it. `makeindex` is called automatically after the `.aux` files
change, and the document is rebuilt whenever the `.nls` output changes.

## Images

Latex documents often include images, but pdflatex is pretty limited in
formats. I often create documents in asymptote or SVG, and need them to be
converted to pdf. This is also done automatically. Just tell the framework
where to look for images:

```make
$(call images, img/)
```

And all of them will be converted (or just hardlinked) into the build directory.

Note that for any document to be built, all images need to be converted,
otherwise the build could fail hard on missing image. However, the converted
images are not added as a dependency unless the document actually uses them, so
they won't be updated and the document will not be rebuilt when unused image
changes.

## Extending simply

Whenever you have something to be built together with the file, and you don't
want to extend the framework, there are several options.

1) If the dependency is common for all built documents, you can use the
aggregating target `build/.deps`. For example:

```make
version.foo:
	git describe >version.foo

build/.deps: version.foo
```

2) If the dependency is special for one document, you can just add it as
a dependency. There is a catch though: not for the built `.pdf`, but for the
recipe that actually invokes latex - the corresponding `.aux` file:

```make
build/doc.aux: version.foo
```

2) If the files the document depends on have a common extension (like `.tex`),
you can add those as a automatically added dependency.

Say that the document needs to include a file named `example.foo`. You need to
do three things - provide a recipe for the file, register the extension and
force creation for the first time. Example follows:

```make
example.foo:
	touch $@

LATEX_AUTO_DEPS += .foo

build/.deps: | example.foo
```

The pipe character introduces an order-only dependency: `build/.deps` cannot be
satisfied without `example.foo` existing, but it won't be rebuilt when the file
changes. The actual dependency is added automatically based on the extension.

## Transparency

Unfortunately, it's not possible to make the framework entirely invisible for
the document. There are few places when you have to modify the document to work
with the build system.

1) If you use a package that creates temporary files (such as `minted`), you
need to set its output directory to build directory (`build/` by default).
Beware, changing the build directory to `.` is NOT a good idea, as the
build directory is removed when cleaning :)

2) When using images, you shall set the image search path to the build
directory (or the images subdir in build):

```tex
\graphicspath{{build/img/}}
```

Unfortunately, latex does not look for images in the output directory, even
though it should according to documentation.

## Testing

It is not. Apart from few cases, it was not extensively tested. It would be
great if you told me it worked for you, or to provide a scenario in which it
breaks!

## Compatibility

The framework does use some features from GNU Make, so it won't probably work elsewhere.

## Contributions

Totally welcome! As you can see, the framework is extensible. Let me know how
to make it working with your favorite package!
