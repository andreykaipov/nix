variable "resume_project_routes" {
  type        = map(string)
  description = <<EOF
A map of projects to repos from our resume that we'll setup 301 redirects for.
For example,

```hcl
{
  "abc" = "github.com/andreykaipov/abc"
}
```

This will create a Cloudflare Worker routes with patterns `abc.kaipov.com` and
`kaipov.com/abc` to 301 redirect to github.com/andreykaipov/abc.
EOF
  default     = {}
}
