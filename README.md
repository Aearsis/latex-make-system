# What's this?

This is an ultimate framework for making LaTeX documents. It uses a bit of
make hackery to wire almost everything automatically.

The minimal use case looks like this:

```make
# Makefile

include latex/Makerules

$(call latex, example.tex)
```

And that's it. The file `example.pdf` can be built with `make`. This
automatically tracks dependencies on other `.tex` files and images (`.pdf`, `.png`
and `.jpg`) -- not all of them, specifically those the document uses.

Also, it automatically repeats the build as needed - such as when TOC or
cross-references change. You can be sure that the document is final after it is
made.

## Bibliography

And there's more! It also aids with using BibTeX to manage bibliography. Say
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

If you prefer BibLaTeX with `biber` backend, the framework (almost) got your
back:

```make
$(call biblatex, example.tex)
```

Multiple bibliography files are not a concern with biblatex:

```tex
\addbibresource{citations.bib}
```

However, in this workflow the `citations.bib` file is not read by LaTeX, and we
cannot infer dependencies automatically. Until the issue is fixed or worked
around, you can add them manually:

```
$(call latex-include, *.bib)
```

## Index

Another useful feature helps with index. This one is even simpler:

```make
$(call makeindex, example.tex)
```

And that's it. `makeindex` is called automatically after the `.aux` files
change, and the document is rebuilt whenever the `.nls` output changes.

## Images

Latex documents often include images, but pdflatex is pretty limited in
formats. I often create figures in asymptote or SVG, and need them converted to
PDF. This is also done automatically. Just tell the framework where to look for
images:

```make
$(call images, img/)
```

And all of them will be converted (or just hardlinked) into the build directory.

Note that for any document to be built, all images need to be converted,
otherwise, the build could fail hard on missing image. However, the converted
images are not added as a dependency unless the document actually uses them, so
they won't be updated and the document will not be rebuilt when an unused image
changes.

## Different LaTeX engine

Not a rocket science:

```make
LATEX=xelatex
$(call latex, example.tex)
```

However, you need to set the variable *prior* to calling latex. On the other
hand, this means you can build documents with different LaTeX engines with the
same Makefile!

The engine does not even have to be LaTeX. Simple tests show that the system
works with plain TeX as well, but I have not used it on real projects yet
(mainly because no complicated system is needed for plain TeX documents...).

## Extending simply

Whenever you have something to build together with the file, and you don't want
to extend the framework, there are several options.

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
you can add those as an automatically added dependency.

Say that the documents include files with an extension `.foo`:

```make
LATEX_AUTO_DEPS += .foo
```

After the first build, the framework will detect which files are being read and
include them into dependencies for the document that needs them. This has the
advantage of not rebuilding documents that do not use the file being changed.

But what if the `.foo` files are dynamically created, and they might be needed
for the first build (such as images converted to pdf)? If you added them as
dependency, they would destroy the advantage of automatic dependencies. The
solution is to use order-only dependencies:


```make
example.foo:
	touch $@

build/.deps: | example.foo
```

The pipe character introduces an order-only dependency: `build/.deps` cannot be
satisfied without `example.foo` existing, but it won't be rebuilt when the file
changes. The actual dependency is still added automatically based on the
extension. Thus, the file will be built for any document to be built for the
first time (to avoid file not found errors), but if the document does not use
them, they won't trigger a rebuild when changed.

## Transparency

Unfortunately, it's not possible to make the framework entirely invisible for
the document. There are few places when you have to modify the document to work
with the build system.

1) If you use a package that creates temporary files (such as `minted`), you
need to set its output directory to build directory (`build/` by default).
Beware, changing the build directory in the build system to `.` is NOT a good
idea, as the build directory is removed when cleaning :)

2) When using images, you shall set the image search path to the build
directory (or the images subdir in build):

```tex
\graphicspath{{build/img/}}
```

Unfortunately, latex does not look for images in the output directory, even
though it should according to documentation.

## Testing

I use it regularly to build my master thesis (which initiated this framework
development). I also have (very) few test cases out of tree.  Therefore, it was
not extensively tested. It would be great if you told me it worked for you, or
provide me a scenario in which it breaks!

## Compatibility

The framework does use some features from GNU Make, so it won't probably work elsewhere.

## Contributions

Totally welcome! As you can see, the framework is extensible. Let me know how
to make it work with your favorite package!

## License

The source is licensed by the new BSD license:

```
Copyright (c) 2018, Ondřej Hlavatý <aearsis@eideo.cz>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
