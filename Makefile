define usage
\e[1;35m|\e[0m Usage:
\e[1;35m|\e[0m    make .................... : why would you use make won't somebody please help me!
\e[1;35m|\e[0m    make infra/* <tf-command> : manage my infra
\e[1;35m|\e[0m    make resume ............. : build my resume
\e[1;35m|\e[0m    make resume watch ....... : build my resume interactively
endef
export usage
usage:
	@echo "$$usage"

## infra

infra_modules := $(shell find infra/ -mindepth 1 -maxdepth 1 -type d ! -name '.*')

.PHONY: $(infra_modules)

$(infra_modules):
export TERRAGRUNT_DEBUG := 1
export TERRAGRUNT_WORKING_DIR = $@

$(infra_modules):
	@terragrunt $(terragrunt_args)

# Adapted from https://stackoverflow.com/a/14061796/4085283.
ifeq (infra/,$(findstring infra/,$(firstword $(MAKECMDGOALS))))
    terragrunt_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(terragrunt_args):;@:)
endif

## resume

.PHONY: resume

resume:
	@case "$(resume_args)" in \
	    "")    ./scripts/resume.build.sh ;; \
	    watch) ./scripts/resume.dev.sh ;; \
	    *)     exit 1 ;; \
	esac

ifeq (resume,$(firstword $(MAKECMDGOALS)))
    resume_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(resume_args):;@:)
endif
