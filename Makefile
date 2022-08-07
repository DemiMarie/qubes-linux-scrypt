VERSION := $(shell cat version)
URL := https://www.tarsnap.com/scrypt/scrypt-$(VERSION).tgz
SIG_URL := https://www.tarsnap.com/scrypt/scrypt-sigs-$(VERSION).asc
ifndef SRC_FILE
ifdef URL
	SRC_FILE := $(notdir $(URL))
endif
endif
ifndef SIG_FILE
ifdef SIG_URL
	SIG_FILE := $(notdir $(SIG_URL))
endif
endif

FETCH_CMD ?= curl --proto '=https' --proto-redir '=https' --tlsv1.2 --http1.1 -sSfL -o

get-sources: $(SRC_FILE)

keyring := scrypt-trustedkeys.gpg
keyring-file := $(if $(GNUPGHOME), $(GNUPGHOME)/, $(HOME)/.gnupg/)$(keyring)
keyring-import := gpg -q --no-auto-check-trustdb --no-default-keyring --import

$(keyring-file): $(wildcard *-key-*.asc)
	@rm -f $(keyring-file) && $(keyring-import) --keyring $(keyring) $^

# get-sources already handle verification and remove the file(s) when it fails.
# Keep verify-sources target present for compatibility with qubes-builder API.
.PHONY: verify-sources
verify-sources:
	@true

UNTRUSTED_SUFF := .untrusted

$(SIG_FILE): $(keyring-file)
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) -- $(SIG_URL)
	@gpgv --keyring $(keyring) $@$(UNTRUSTED_SUFF) 2>/dev/null || \
        { echo "Wrong signature on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv -f $@$(UNTRUSTED_SUFF) $@

# just drop signature, don't rely on gpg for its verification - use gpgv above for it
$(basename $(SIG_FILE)): $(SIG_FILE)
	@rm -f "$@"
	@gpg --batch --keyring $(keyring) -o $@ $< 2>/dev/null

$(SRC_FILE): $(basename $(SIG_FILE)) $(keyring-file)
	@mkdir downloads.UNTRUSTED && \
	trap 'rm -rf -- downloads.UNTRUSTED' EXIT && \
	$(FETCH_CMD) downloads.UNTRUSTED/$@ -- $(URL) && \
	cp $< downloads.UNTRUSTED/$< && \
	(cd downloads.UNTRUSTED && exec sha256sum --quiet --strict -c $<) && \
	mv downloads.UNTRUSTED/$@ .


.PHONY: clean-sources
clean-sources:
ifneq ($(SRC_FILE), None)
	-rm $(SRC_FILE) $(SIG_FILE)
endif
