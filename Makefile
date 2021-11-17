define usage
\e[1;35m|\e[0m Usage:
\e[1;35m|\e[0m    make .................... : won't somebody please help him!
\e[1;35m|\e[0m    make infra/* <tf-command> : manage his infra
\e[1;35m|\e[0m    make resume ............. : build his resume
\e[1;35m|\e[0m    make resume watch ....... : build his resume interactively
\e[1;35m|\e[0m    make site ............... : serve Hugo site locally
endef
export usage
usage:
	@printf "$$usage\n"

## infra

infra_modules := $(shell find infra/ -mindepth 1 -maxdepth 1 -type d ! -name '.*')

.PHONY: $(infra_modules)

$(infra_modules):
export TERRAGRUNT_DEBUG := 1
export TERRAGRUNT_WORKING_DIR = $@

$(infra_modules):
	@terragrunt $(terragrunt_args)

## resume

.PHONY: resume

resume:
	@case "$(resume_args)" in \
	    "")    ./scripts/resume.build.sh ;; \
	    watch) ./scripts/resume.dev.sh ;; \
	    *)     exit 1 ;; \
	esac

## website

.PHONY: website

website:
	@case "$(website_args)" in \
	    "")    ./scripts/website.serve.sh ;; \
	    *)     exit 1 ;; \
	esac

#
# The following snippets allow us to pass arguments to `make <task>`, as if we
# were actually using a fully-fledged CLI with subcommands. This could probably
# be more maintainable as a shell script, but to be able to use `make` is just
# too neat!
#
# Adapated from https://stackoverflow.com/a/14061796/4085283.
#

ifeq (infra/,$(findstring infra/,$(firstword $(MAKECMDGOALS))))
    terragrunt_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(terragrunt_args):;@:)
endif

ifeq (resume,$(firstword $(MAKECMDGOALS)))
    resume_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(resume_args):;@:)
endif

ifeq (website,$(firstword $(MAKECMDGOALS)))
    website_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(website_args):;@:)
endif
