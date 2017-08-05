################################################################################
# Exploring R package for Google Compute Engine's API
################################################################################


# Install R package
install.packages("googleComputeEngineR")

# Set up gcloud SDK
# Get JSON file w/ auth info 
# Add .Renviron file w/ package options and path to JSON auth file

# Load R package
library(googleComputeEngineR)

# Some initial functions to explore
gce_get_project()
# ?gce_vm
# ?gce_vm_template


########################################
# Executing script on gce with ssh/bash/docker/gcloud(?)
########################################
# ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/RtmpM7bHYu/hosts -i /home/matt/.ssh/google_compute_engine matt@35.188.148.225
# ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/RtmpM7bHYu/hosts -i /home/matt/.ssh/google_compute_engine matt@35.188.148.225 'mulvahim && docker run --name="harbor_hf1gvc" rocker/r-base Rscript -e 1+1'
# ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/RtmpM7bHYu/hosts -i /home/matt/.ssh/google_compute_engine matt@35.188.148.225 'docker run --name="harbor_hf1gvc" rocker/r-base Rscript -e 1+1'

########################################
# Dockerfiles w/ gceR
########################################

# -------------
# Push container with gcloud 
#   **don't think there's a way in R pkg yet
#     ** Turns out there is: https://cloudyr.github.io/googleComputeEngineR/articles/opencpu-api-server.html
#           docker_build
#           gce_push_registry
# -------------

# Install most recent docker via website:
#   https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository 
# Build and push container:
#   https://cloud.google.com/container-registry/docs/pushing-and-pulling
#```
#  sudo docker build -t pulsatile-container .
#  sudo docker images # list images to get <IMAGE_ID> 
#  sudo docker tag <IMAGE_ID> gcr.io/thesis-run/pulsatile-container
#                     # second arg could be constructed w/ gce_tag_container
#  sudo gcloud docker -- push gcr.io/thesis-run/pulsatile-container
#```
# Container now available for creating VM

# Helper function for creating pathname to gcloud docker registry
my_container <- gce_tag_container("pulsatile-container", project = "thesis-run")


########################################
# Explore creating and exploring a single VM based on custom Dockerfile 
########################################
preemptible <- list(preemptible = TRUE)


#-----------------------------------
# Test creation via gce_vm()
# THIS DOES IT -- JUST TAKES A BIT FOR CONTAINTER TO LOAD #############
#-----------------------------------
my_container <- gce_tag_container("pulsatile-container", project = "thesis-run")
preemptible  <- list(preemptible = TRUE)
vm7 <- gce_vm(name = "vm7",
              predefined_type = "n1-standard-1",
              template        = "r-base",
              dynamic_image   = my_container,
              scheduling      = preemptible)
gce_ssh_setup(vm7)
docker_cmd(vm7, "images", capture_text = TRUE)
# BUT, future's plan(cluster, ...) defaults to rocker/r-base for some reason....



#-----------------------------------
my_container <- gce_tag_container("pulsatile-container", project = "thesis-run")
preemptible  <- list(preemptible = TRUE)
vm6 <- gce_vm(name = "vm6",
              predefined_type = "n1-standard-1",
              template        = "rstudio-hadleyverse",
              dynamic_image   = my_container,
              scheduling      = preemptible,
              username = "matt",
              password = "matt")
gce_ssh_setup(vm6)
docker_cmd(vm3, "images")
docker_cmd(vm4, "images")
docker_cmd(vm5, "images")
docker_cmd(vm6, "images")



##### Issue is in this function in gceR
#### ---- update package by passing 'dynamic_image' info to this function? exists in text of vm$metadata$items$value, anywhere else?
makeDockerClusterPSOCK <- function(workers, 
                                   docker_image = "rocker/r-base", 
                                   rscript = c("docker", "run", "--net=host", docker_image, "Rscript"), 
                                   rscript_args = NULL, install_future = TRUE, ..., verbose = FALSE) {
  ## Should 'future' package be installed, if not already done?
  if (install_future) {
    rscript_args <- c("-e", 
                      shQuote(sprintf("if (!requireNamespace('future', quietly = TRUE)) install.packages('future', quiet = %s)", 
                                      !verbose)), 
                      rscript_args)
  }
  
  future::makeClusterPSOCK(workers, rscript = rscript, rscript_args = rscript_args, ..., verbose = verbose)
}



library(future)
vm7 <- gce_ssh_setup(vm7)
plan(cluster, workers = list(vm7)) # NOTE: Why does this load rocker/r-base???
a %<-% Sys.getpid()
test_mean %<-% mean(rnorm(n = 10000000, mean = 50, sd = 10))
test_mean %<-% require(pulsatile)
test_mean %<-% require(devtools)


library(pulsatile)
simdata <- simulate_pulse()
simspec <- pulse_spec()
my_big_function <- future({
	test <-	fit_pulse(.data = simdata, spec = simspec, iters = 50000)
})
fit <- value(my_big_function)



vm4 <- gce_vm_template(name = "vm4",
                       predefined_type = "n1-standard-1",
                       template        = "r-base",
                       dynamic_image   = my_container,
                       scheduling      = preemptible)
# View available/installed docker containers
docker_run(vm4, "images")


# Doesn't work -- need cloud_init file for this fn
# vm4 <- gce_vm_container(name = "vm4",
#                         predefined_type = "n1-standard-1",
#                         template        = "r-base",
#                         dynamic_image   = my_container,
#                         scheduling      = preemptible)

# How to get already running or existing instances
rm(vm1, vm2)
gce_list_instances()
vm1 <- gce_vm("vm1")
vm2 <- gce_vm("vm2")



# How to build cloud.init file for directly calling gce_vm_container (this fn
# should not wait until boot success, so that many calls can occur at once)
template      <- "r-base"
dynamic_image <- my_container

cloud_init      <- get_template_file(template)
cloud_init_file <- readChar(cloud_init, nchars = 32768)
upload_meta     <- list(template = template)
image           <- googleComputeEngineR:::get_image("rocker/r-base", dynamic_image = dynamic_image)
cloud_init_file <- sprintf(cloud_init_file, image)
vm7 <- gce_vm_container(name = "vm7", 
                        predefined_type = "n1-standard-1",
                        scheduling      = list(preemptible = TRUE),
                        cloud_init = cloud_init_file,
                        metadata   = upload_meta)
vm7 <- gce_vm("vm7")
# vm8 <- gce_vm("vm8")
library(future)
vm7 <- gce_ssh_setup(vm7)
plan(cluster, workers = list(vm7))
a %<-% Sys.getpid()
test_mean %<-% mean(rnorm(n = 10000000, mean = 50, sd = 10))
test_mean %<-% require(pulsatile)
test_mean %<-% require(devtools)
test_mean %<-% sessionInfo()
test_mean %<-% library()




gce_list_instances()
gce_vm_delete(vm1)
gce_vm_delete(vm3)
gce_vm_delete(vm4)
gce_vm_delete(vm7)
rm(vm1, vm2, vm7)





########################################
# Explore massively parallel processing
########################################

# https://cloudyr.github.io/googleComputeEngineR/articles/massive-parallel.html
library(future)
library(purrr)

vm_names <- paste0("cpu", 1:10)
preemptible <- list(preemptible = TRUE)
fiftyvms <- map(vm_names, 
                ~ gce_vm_container(name = .x,
                                   predefined_type = "n1-standard-1",
                                   dynamic_image   = my_container,
                                   scheduling      = preemptible))

gce_vm_template(name = "test4",
                predefined_type = "n1-standard-1",
                template        = "dynamic",
                image_family    = "ubuntu-1604-lts",
                scheduling      = preemptible)



setup_vms <- function(vm, container) {
  doc
  docker_run(vm, container, 



}
