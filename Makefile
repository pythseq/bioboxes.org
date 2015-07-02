publish: build
	bundle exec middleman s3_sync

test: build
	bundle exec htmlproof --check-html --check-favicon --href-ignore '#' $<
	bundle exec ./plumbing/check-forbidden-words forbidden.txt $(shell find $< -name "*index.html")

build: $(shell find source) $(fetch) Gemfile.lock
	bundle exec middleman build --verbose

dev: $(shell find source) $(fetch) Gemfile.lock
	bundle exec middleman server

clean:
	rm -rf build $(fetch)

###################################
#
# Bootstrap website resources
#
###################################

fetch =  source/validate-biobox-file.mkd source/validator/short-read-assembler.mkd

bootstrap: Gemfile.lock \
	   vendor/bootstrap \
	   vendor/javascripts/strftime.js \
	   vendor/javascripts/lodash.js \
	   $(fetch)

vendor/javascripts/strftime.js:
	mkdir -p $(dir $@)
	wget \
	  --quiet \
	  --output-document $@ \
          https://raw.githubusercontent.com/samsonjs/strftime/v0.9.2/strftime.js

vendor/javascripts/lodash.js:
	mkdir -p $(dir $@)
	wget \
	  --quiet \
	  --output-document $@ \
	  https://raw.githubusercontent.com/lodash/lodash/3.10.0/lodash.js

vendor/bootstrap:
	mkdir -p vendor
	wget \
	  --quiet \
	  --output-document bootstrap.zip \
	  https://github.com/twbs/bootstrap/archive/v3.3.4.zip
	unzip bootstrap.zip
	mv bootstrap-3.3.4 $@
	rm bootstrap.zip
	touch $@

Gemfile.lock: Gemfile
	bundle install --path vendor/bundle

###################################
#
# Fetched pages from external tools
#
###################################

source/validate-biobox-file.mkd:
	wget \
		--quiet \
		--output-document $@ \
		https://raw.githubusercontent.com/bioboxes/file-validator/master/doc/validate-biobox-file.mkd

source/validator/short-read-assembler.mkd:
	mkdir -p $(dir $@)
	wget \
		--quiet \
		--output-document $@ \
		https://raw.githubusercontent.com/bioboxes/validator-short-read-assembler/master/doc/short-read-assembler-validator.md
