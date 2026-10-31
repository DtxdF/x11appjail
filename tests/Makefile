
.SUFFIXES:

.PHONY: all
all: create-env prepare-env tests

.PHONY: create-env
create-env: vm.yml clean
	overlord apply -f vm.yml

.PHONY: prepare-env
prepare-env: prepare-env.sh
	./prepare-env.sh

.PHONY: tests
tests: run-tests.sh
	./run-tests.sh

.PHONY: clean
clean: destroy-env.sh vm.yml
	./destroy-env.sh
