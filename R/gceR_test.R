
install.packages("googleComputeEngineR")

library(googleComputeEngineR)
gce_get_project()
?gce_vm
?gce_vm_template


# Dockerfiles w/ gceR
my_container <- gce_tag_container("bp-strauss-study-v0.1", 
                                  project = "thesis-run",
                                  container_url = "us.gcr.io")

# Massively parallel processing
# https://cloudyr.github.io/googleComputeEngineR/articles/massive-parallel.html
library(googleComputeEngineR)
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
# NOTE: NOT LOADING MY docker container --- 
vm2 <- gce_vm(name = "test6",
              predefined_type = "n1-standard-1",
              template        = "r-base",
              dynamic_image   = "us.gcr.io/thesis-run/bp-strauss-study-v0.1",
              scheduling      = preemptible)


gce_vm_stop(vm2)


