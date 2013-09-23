REV := $(shell git rev-parse --short HEAD)

all: docs
	$(MAKE) -C src
	./src/bin/libxively_unit_test_suite
docs:
	doxygen
clean:
	-rm -rf doc/html
	$(MAKE) -C src $@

ci_msp430:
	$(MAKE) -C src clean
	$(MAKE) -C src libxively \
		CC=msp430-elf-gcc AR=msp430-elf-ar \
		XI_EXTRA_CFLAGS="-mmcu=msp430 -fdata-sections" \
		XI_OPTLEVEL=-Os \
		XI_OPTIMISE="NO_ERROR_STRINGS" \
		XI_DEBUG_ASSERT=0 XI_DEBUG_OUTPUT=0 \
		XI_COMM_LAYER=dummy

ci_msp430x:
	$(MAKE) -C src clean
	$(MAKE) -C src libxively \
		CC=msp430-elf-gcc AR=msp430-elf-ar \
		XI_EXTRA_CFLAGS="-mmcu=msp430x" \
		XI_OPTLEVEL=-Os \
		XI_OPTIMISE="NO_ERROR_STRINGS" \
		XI_DEBUG_ASSERT=0 XI_DEBUG_OUTPUT=0 \
		XI_COMM_LAYER=dummy

ci_avr:
	$(MAKE) -C src clean
	$(MAKE) -C src libxively \
		CC=avr-gcc AR=avr-ar \
		XI_DEBUG_ASSERT=0 XI_DEBUG_OUTPUT=0 \
		XI_COMM_LAYER=dummy

# This provides a very easy way of importing the code base into mbed.org IDE.
# We create a zip archive with shortened revision hash in the filename
# To import the library into a project, click Import button and then select
# upload tab and navigate to the location of this zip archive.
# When the IDE unpacks the library, it magically names it by basename of the
# zip archive, so revision hash appears in the lib's name.
mbed_zipfile: mbed-libxively-$(REV)
# We simply append `XI_USER_AGENT` for mbed to `xi_consts.h`, as there is no
# global constant which we can rely on, e.g. `__MBED__`. One can use the
# constant `MBED_LIBRARY_VERSION`, but that requires `mbed.h` to be included
# from where we need it. Only a global preprocessor constant would work.
mbed-libxively-$(REV):
	echo "#define XI_USER_AGENT \"libxively-mbed/0.1.x-$(REV)\"" >> src/libxively/xi_consts.h
	zip "$@" \
	   src/libxively/*.[ch] \
	   src/libxively/comm_layers/mbed/*
	git checkout src/libxively/xi_consts.h

update_docs_branch:
	-rm -rf doc/html
	doxygen && cd doc/html \
		&& git init \
		&& git remote add github git@github.com:xively/libxively \
		&& git add . \
		&& git commit -m "[docs] Regerated documentation for $(REV)" \
		&& git push github master:gh-pages -f

wip_msp430_cc3000:
	$(MAKE) -C src clean
	$(MAKE) -C src/ext/drivers msp430_cc3000 CFLAGS="-mmcu=msp430fr5739"
	$(MAKE) -C src libxively \
		CC=msp430-elf-gcc \
		AR=msp430-elf-ar \
		XI_OPTLEVEL=-Os \
		XI_OPTIMISE="NO_ERROR_STRINGS" \
		XI_EXTRA_CFLAGS="-mmcu=msp430fr5739" \
		XI_DEBUG_OUTPUT=0 \
		XI_DEBUG_ASSERT=0 \
		XI_COMM_LAYER=msp430_cc3000
