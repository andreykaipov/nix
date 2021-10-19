locals {
  git_dir = run_cmd("git", "rev-parse", "--show-toplevel")

  resume_tex = "${local.git_dir}/resume/resume.tex"

  resume = {
    projects = split("\n", run_cmd("--terragrunt-quiet", "sh", "-c", <<EOF
      awk -F'[{}]' '/cventryproject/ {print $4}' ${local.resume_tex}
    EOF
    ))
    links = split("\n", run_cmd("--terragrunt-quiet", "sh", "-c", <<EOF
      awk -F'%' '/cventryproject/ {print $2}' ${local.resume_tex} |
        grep -Eo 'repo:[^ ]+?' |
        cut -c6- |
        awk '{printf "https://github.com/"; print}'
    EOF
    ))
  }
}

inputs = {
  resume_project_routes = zipmap(
    local.resume.projects,
    local.resume.links,
  )
}
