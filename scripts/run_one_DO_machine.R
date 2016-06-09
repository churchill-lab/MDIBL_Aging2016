library("analogsea")
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

d <- docklet_create(size = getOption("do_size", "8gb"),
                    region = getOption("do_region", "nyc2"))

# pull images
d %>% docklet_pull("rocker/hadleyverse")
d %>% docklet_pull("churchill/ibangs2016")
d %>% docklet_images()

# download files to /data folder, takes ~30mins
lines <- "wget https://raw.githubusercontent.com/churchill-lab/IBANGS2016/master/scripts/download_data_from_ftp.sh
          /bin/bash download_data_from_ftp.sh
          rm download_data_from_ftp.sh"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# start the containers
d %>% docklet_run("-d", " -v /ibangs/data:/ibangs/data", " -v /ibangs/tutorial:/ibangs/tutorial", " -p 8787:8787", 
                  " -e USER=rstudio", " -e PASSWORD=ibangs ", "--name myrstudio ", "churchill/ibangs2016")

# add symbolic links
lines2 <- "docker exec myrstudio ln -s /ibangs/data /home/rstudio/data
           docker exec myrstudio ln -s /ibangs/tutorial /home/rstudio/tutorial"
cmd2 <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines2))
analogsea:::do_system(d, cmd2, verbose = TRUE)

# kill droplet
# droplet_delete(d)
