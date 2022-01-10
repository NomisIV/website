.PHONY: build fonts assets

ERROR = $(OUT)/errors
ERROR_PAGES = \
	$(ERROR)/404.html

BLOG = $(OUT)/blog
BLOG_PAGES = \
	$(BLOG)/android-sucks.html \
	$(BLOG)/how-i-built-this-website.html \
	$(BLOG)/my-battlestation-part-1.html \
	$(BLOG)/my-battlestation-part-2.html \

PAGES = \
	$(OUT)/index.html \
	$(OUT)/contact.html \
	$(OUT)/about.html \
	$(OUT)/lists.html \
	$(OUT)/projects.html \
	$(OUT)/cv-se.html \
	$(BLOG_PAGES) \
	$(ERROR_PAGES)

build: $(OUT)/robots.txt \
	$(OUT)/style.css \
	$(OUT)/favicon.ico \
	$(PAGES) \
	assets \
	$(OUT)/cv-se.pdf

$(OUT)/%.css: $(DATA)/%.scss
	mkdir -p $$(dirname $@)
	sassc --style compressed $< $@

$(OUT)/robots.txt: $(DATA)/robots.txt
	mkdir -p $$(dirname $@)
	cp $< $@

assets:
	mkdir -p $(OUT)/assets
	cp -r $(DATA)/assets/* $(OUT)/assets

$(OUT)/favicon.ico: $(DATA)/favicon.svg
	mkdir -p $$(dirname $@)
	convert -resize 16x16 -background transparent $< $@

$(OUT)/%.html: $(DATA)/%.md
	mkdir -p $$(dirname $@)
	python generate_page.py $< > $@

$(ERROR)/%.html: $(DATA)/errors/%.md
	mkdir -p $$(dirname $@)
	cmark-gfm -e table -e autolink $< \
		| $(DATA)/scripts/substitute $(DATA)/scripts \
		| $(DATA)/scripts/template $(DATA)/template.html $@ \
		| minify --type html \
		> $@

	mkdir -p $$(dirname $@)
	python generate_page.py $< > $@

$(OUT)/%.pdf: $(DATA)/%.md $(OUT)/pdf.css
	pandoc \
		<<< $$(cat $< | $(DATA)/scripts/substitute $(DATA)/scripts) \
		-o $@ \
		--pdf-engine wkhtmltopdf \
		--css=$(OUT)/pdf.css
