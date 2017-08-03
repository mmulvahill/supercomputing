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

vm2 <- gce_vm(name = "test6",
              predefined_type = "n1-standard-1",
              template        = "r-base",
              dynamic_image   = my_container,
              scheduling      = preemptible)
vm8 <- gce_vm_template(name = "vm8",
                       predefined_type = "n1-standard-1",
                       template        = "r-base",
                       dynamic_image   = my_container,
                       scheduling      = preemptible)
vm4 <- gce_vm_container(name = "vm4",
                        predefined_type = "n1-standard-1",
                        template        = "r-base",
                        dynamic_image   = my_container,
                        scheduling      = preemptible)

# How to get already running or existing instances
rm(vm4, vm2, vm3)
gce_list_instances()
vm3 <- gce_vm("vm3")
vm2 <- gce_vm("test6")



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
vm8 <- gce_vm("vm8")
library(future)
vm8 <- gce_ssh_setup(vm8)
plan(cluster, workers = list(vm8))
a %<-% Sys.getpid()
test_mean %<-% mean(rnorm(n = 10000000, mean = 50, sd = 10))
test_mean %<-% require(pulsatile)
test_mean %<-% require(devtools)
test_mean %<-% sessionInfo()
test_mean %<-% library()




gce_list_instances()
gce_vm_stop(vm3)
gce_vm_stop(vm2)
gce_vm_stop(vm6)
gce_vm_stop(vm8)





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


