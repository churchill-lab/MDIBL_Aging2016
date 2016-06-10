library(analogsea)
library(parallel)
library(doParallel)
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

participants <- read.csv("participant_list_mdibl_aging2016.csv", as.is=TRUE)
N = nrow(participants)

# Single machine.
img = images(private = TRUE)[["churchill/mdibl2016"]]
d = droplet_create(name = "droplet1", size = "8gb", image = img[["id"]],
                   region = "nyc2")

# Trying new command to make multiple machines at once.
img = images(private = TRUE)[["churchill/mdibl2016"]]
droplet.list = droplets_create(names = paste0("Machine", 1:20), size = "8gb", image = img[["id"]],
                               region = "nyc2")

# create a droplet for each participant
droplet_list <- list()

# parallelization would cause API error
for(i in 1:N) {
  print(i)
  # start i-th machine
#  droplet_list[[i]] <- docklet_create(size = getOption("do_size", "8gb"), 
#                                      region = getOption("do_region", "nyc2"))
  droplet_list[[i]] <- droplet_create(size = getOption("do_size", "8gb"), 
                                      region = getOption("do_region", "nyc2"),
                                      image = getOption("do_image", "churchill/mdibl2016"))
}

cl <- makeCluster(N)
registerDoParallel(cl)


# pulling docker images
foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
  d = droplet_list[[i]]
  
  # pull docker images
#  d %>% docklet_pull("rocker/hadleyverse")
#  d %>% docklet_pull("churchill/ibangs2016")
  d %>% docklet_pull("churchill/mdibl2016")
  d %>% docklet_images()
}

# download files to /data folder, takes ~1 hour
#foreach(i = 1:N, .packages="analogsea") %dopar% {
  
  # select droplet
#  d = droplet_list[[i]]
  
#  lines <- "wget https://raw.githubusercontent.com/churchill-lab/IBANGS2016/master/scripts/download_data_from_ftp.sh
#            /bin/bash download_data_from_ftp.sh
#            rm download_data_from_ftp.sh"
#  cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
#  analogsea:::do_system(d, cmd, verbose = TRUE)
#}

#stopCluster(cl)

# start docker containers
for(i in 1:N) {
  print(i)
  # select droplet
  d = droplet_list[[i]]
  
  d %>% docklet_run("-d", " -v /data:/data", " -v /tutorial:/tutorial", " -p 8787:8787", 
                    " -e USER=rstudio", " -e PASSWORD=mdibl ", "--name myrstudio ", "churchill/mdibl2016")

  # add symbolic links
  lines2 <- "docker exec myrstudio ln -s /data /home/rstudio/data
             docker exec myrstudio ln -s /tutorial /home/rstudio/tutorial"
  cmd2 <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines2))
  analogsea:::do_system(d, cmd2, verbose = TRUE)  
}

### Create participant table with links
participants$DO_machine <- sapply(droplet_list, function(x) x$name)
participants$link_RStudio <- sapply(droplet_list, function(x) paste0("http://",analogsea:::droplet_ip(x),":8787"))

library(xtable)
sanitize.text.function <- function(x) {
  idx <- substr(x, 1, 7) == "http://"
  x[idx] <- paste0('<a href="',x[idx],'">',sub("^http://","",x[idx]),'</a>')
  x
}
cols <- c("Name", "DO_machine", "link_RStudio")
print(xtable(participants[,cols], caption="Digital Ocean Machines"),
      type = "html", sanitize.text.function = sanitize.text.function,
      file = "dolist.html", include.rownames=FALSE)

### Send emails to course participants
library(mailR)


for (i in 1:N) {
  email_body <- paste0("Dear ",participants$Name[i],",\n\n",
                       "During the workshop, you will need an access to RStudio Server ",
                       "running on your personal Digital Ocean virtual machine. You can access the machine ",
                       "in your web browser:\n\n",
                       participants$link_RStudio[i]," (user:rstudio, password:ibangs)\n\n",
                       "After the workshop you can run this docker image either on your personal machine or host it ",
                       "on Digital Ocean (as we did). Further instructions can be found on https://github.com/churchill-lab/IBANGS2016 or https://github.com/churchill-lab/sysgen2015.\n\n",
                       "Best regards,\n\n","Petr Simecek")
  
  send.mail(from = "REPLACE THIS BY YOUR_GMAIL@gmail.com",
            to = participants$Email[i],
            replyTo = "REPLACE THIS BY YOUR_EMAIL",
            subject = "IBANGS - DO Machine Access",
            body = email_body,
            smtp = list(host.name = "smtp.gmail.com", port = 465, 
                        user.name = "REPLACE THIS BY YOUR_GMAIL@gmail.com", 
                        passwd = "***YOUR PASSWORD***", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
}
