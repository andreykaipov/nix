# self

## what is this?

It's an overengineered and bundled monorepo for my personal website, resume, the
infrastructure behind that, and the CI for all of it. If we want to get all
metaphoric about it, it's a representation of self.

## contents

At a glance, the repo is organized as follows:

| directory              | description                       |
|------------------------|-----------------------------------|
| [`infra`](./infra)     | Terragrunt and Terraform modules  |
| [`resume`](./resume)   | Resume markup                     |
| [`website`](./website) | Hugo static site config           |

Please note the [`shell.nix`](./shell.nix) at the root of this repo. If any
necessary tools are unavailable on our system, the tool will be invoked via
a Nix shell.

### `infra`

Terraform state is stored in a Cloudflare Workers KV store. The backend had to
be bootstrapped by the Terraform configuration in
[`infra/tfstate`](./infra/tfstate). Yes, the state for the backend is stored in
the very same infrastructure it spun up. If you ain't living dangerously, are
you even living?

The `infra/kaipov.com` module manages all the Cloudflare configuration for
`kaipov.com` -- DNS records, routes, security, whatever.

We can use `./script/run.sh` to manage our infrastructure too, e.g.:

```console
$ ./scripts/run.sh infra/kaipov.com plan
$ ./scripts/run.sh infra/kaipov.com state show cloudflare_zone.kaipov
```

### resume

The resume is written in TeX using the [`moderncv`](./resume/moderncv) class,
with some of my own custom patches.

Thanks to [Tectonic](https://github.com/tectonic-typesetting/tectonic), building
the TeX document is astonglishly **not** a giant pain in the ass!
Unbelievable--I know!
Typically I'll run `./scripts/resume.dev.sh` and have _Sumatra
PDF_ open on the side to get a live preview. When I'm done, the resume should
already be moved into the appropriate place under `website` so that our Hugo
site can serve it accordingly.

### website

The Hugo website is hosted on Cloudflare Pages (can you tell he's a fan of
Cloudflare?). Despite not being the most feature-full and sophisticated static
site host, Pages integrates well with the rest of the Cloudflare suite, so it's
hard justifying the use of another provider!
