library("analogsea")
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

d <- docklet_create(size = getOption("do_size", "8gb"),
                    region = getOption("do_region", "nyc2"))

# pull images
d %>% docklet_pull("rocker/hadleyverse")
d %>% docklet_pull("churchill/ibangs2016")
d %>% docklet_images()

# Needed to add this to update the IP address. OTherwise, I got a "network not up yet" error.
d = droplet(d$id)

# download files to /data folder, takes ~30mins
lines <- "wget https://raw.githubusercontent.com/churchill-lab/MDIBL_Aging2016/master/scripts/download_data_from_ftp.sh
          /bin/bash download_data_from_ftp.sh
          rm download_data_from_ftp.sh"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# Make a snapshot of this machine.
d %>%
  droplet_power_off() %>%
  droplet_wait() %>%
  droplet_snapshot(name = "churchill/mdibl2016")

# Destroy the source droplet to see if we can re-make it using the image.
droplet_delete(d)
rm(d)

# Run the one machine.
img = images(private = TRUE)[["churchill/mdibl2016"]]
d = droplet_create(name = "droplet1", size = "8gb", image = img[["id"]],
                   region = "nyc2")

# Needed to add this to update the IP address. OTherwise, I got a "network not up yet" error.
d = droplet(d$id)

# start the container.
d %>% docklet_run("-d", " -v /data:/data", " -v /tutorial:/tutorial", " -p 8787:8787", 
                  " -e USER=rstudio", " -e PASSWORD=mdibl ", "--name myrstudio ", "churchill/ibangs2016")

# add symbolic links
lines2 <- "docker exec myrstudio ln -s /data /home/rstudio/data
           docker exec myrstudio ln -s /tutorial /home/rstudio/tutorial"
cmd2 <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines2))
analogsea:::do_system(d, cmd2, verbose = TRUE)

# kill droplet
# droplet_delete(d)
