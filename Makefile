define usage
\e[1;35m|\e[0m Usage:
\e[1;35m|\e[0m    make .................... : why would you use make won't somebody please help me!
\e[1;35m|\e[0m    make infra/* <tf-command> : manage my infra
\e[1;35m|\e[0m    make resume ............. : build my resume
\e[1;35m|\e[0m    make resume watch ....... : build my resume interactively
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

## website

.PHONY: website

website:
	@case "$(website_args)" in \
	    "")    ./scripts/website.serve.sh ;; \
	    *)     exit 1 ;; \
	esac

ifeq (website,$(firstword $(MAKECMDGOALS)))
    website_args := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(website_args):;@:)
endif
