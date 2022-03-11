.PHONY: build
build:
	./mktags

.PHONY: help
help:
	@echo "The following recipes are available:"
	@grep '^[^\.#[:space:]].*:' Makefile | cut -d: -f1 | sort -u | grep -ve '^help$$'

.PHONY: post
post: POST_FILE=_posts/$(shell date +"%Y-%m-%d")-post.md
post:
	( \
		echo "---"; \
		echo "layout: post"; \
		echo "title:  \"\""; \
		echo "date:   $(shell date --rfc-3339=seconds)"; \
		echo "tags: "; \
		echo "---"; \
	) > $(POST_FILE)
	$(EDITOR) $(POST_FILE)

.PHONY: serve
serve:
	bundle exec jekyll serve --drafts --livereload

.PHONY: setup
setup:
	sudo apt install -y ruby-full build-essential zlib1g-dev
	@if [ "${GEM_HOME}" != "${HOME}/.ruby" ]; then \
	  echo "GEM_HOME should be set to ${HOME}/.ruby" >&2; \
	  exit 1; \
	fi
	gem install jekyll bundler
	bundle install
