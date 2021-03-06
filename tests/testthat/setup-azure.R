# login
# the equivalent of (interactive) az_login is run outside of R

# subscription
# the azure login action automatically retrieves the enabled subscriptions GitHub Actions

# resource group
az_configure(resource_group = "hoad")
# you can also pass this argument to shiny_deploy_az for the one-call deployment
# you can also set this once and commit the resulting .azure/config
# but this is not easily available during testing, so it's set from R here
# because several apps are deployed below, `name` is set for each of them

# plan
plan <- "hoad"
# there's no way to set a plan default

# deploy shiny app using rocker image
az_configure(name = "hello-shiny")
az_webapp(
  # this image actually includes *more* than necessary
  # for example, it includes shinyserver, but just shiny would suffice
  deployment_container_image_name = "rocker/shiny:4.0.2",
  # above image has no `ENTRYPOINT` and/or `CMD` to start shiny by default.
  # so this `[COMMAND]` must be appended to `docker run`
  startup_file = paste(
    "Rscript",
    # setting shiny options for azure manually
    # equivalent to running shinycaas::shiny_opts_az()
    "-e options(shiny.host='0.0.0.0',shiny.port=as.integer(Sys.getenv('PORT')))",
    # remove getOption call https://github.com/subugoe/shinycaas/issues/37
    "-e shiny::runExample('01_hello',port=getOption('shiny.port'))"
  ),
  plan = plan
)

# deploy shiny app to slot
az_webapp(
  deployment_container_image_name = "rocker/shiny:4.0.2",
  startup_file = paste(
    "Rscript",
    "-e options(shiny.host='0.0.0.0',shiny.port=as.integer(Sys.getenv('PORT')))",
    "-e shiny::runExample('05_sliders',port=getOption('shiny.port'))"
  ),
  plan = plan,
  slot = "sliders" # a more suitable slot name might be "dev" or "staging"
)

# deploy shiny app using private image, here from muggle package
# below env vars and secrets are only available on github actions
if (is_github_actions()) {
  # for an easier way to set these arguments, see the {muggle} package
  az_configure(name = "old-faithful")
  az_webapp(
    deployment_container_image_name = paste0(
      "docker.pkg.github.com/subugoe/shinycaas/oldfaithful", ":",
      ifelse(is_github_actions(), Sys.getenv("GITHUB_SHA"), "latest")
    ),
    plan = plan,
    docker_registry_server_url = "https://docker.pkg.github.com",
    docker_registry_server_user = Sys.getenv("GITHUB_ACTOR"),
    docker_registry_server_password = Sys.getenv("GH_PAT_PKG")
  )
}

# cleanup (necessary for testing)
unlink(".azure", recursive = TRUE)
