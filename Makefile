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
	$(OUT)/about-me.html \
	$(OUT)/my-lists.html \
	$(OUT)/my-projects.html \
	$(BLOG_PAGES) \
	$(ERROR_PAGES)

build: $(OUT)/style.css fonts $(OUT)/favicon.ico $(PAGES) assets

$(OUT)/%.css: $(DATA)/pages/%.scss
	mkdir -p $$(dirname $@)
	sassc --style compressed $< $@

fonts: $(DIOSEVKA)/*
	mkdir -p $(OUT)/assets/fonts
	cp $(DIOSEVKA)/* $(OUT)/assets/fonts

assets:
	mkdir -p $$(dirname $@)
	cp $(DATA)/assets/* $(OUT)/assets

$(OUT)/favicon.ico: $(DATA)/favicon.svg
	mkdir -p $$(dirname $@)
	convert -resize 16x16 -background transparent $< $@

$(OUT)/%.html: $(DATA)/pages/%.md
	mkdir -p $$(dirname $@)
	cmark-gfm $< \
		| $(DATA)/scripts/substitute $(DATA)/scripts \
		| $(DATA)/scripts/template $(DATA)/template.html $@ \
		| minify --type html \
		> $@

$(ERROR)/%.html: $(DATA)/errors/%.md
	mkdir -p $$(dirname $@)
	cmark-gfm $< \
		| $(DATA)/scripts/substitute $(DATA)/scripts \
		| $(DATA)/scripts/template $(DATA)/template.html $@ \
		| minify --type html \
		> $@


