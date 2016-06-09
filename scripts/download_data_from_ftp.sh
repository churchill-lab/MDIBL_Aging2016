# make /data folder and subfolders
mkdir -p /data
mkdir -p /tutorial

# Copy the data directory.
wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/IBANGS2016/data/DO_Sanger_SDPs.txt.bgz
wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/IBANGS2016/data/DO_Sanger_SDPs.txt.bgz.tbi
wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/IBANGS2016/data/assoc_perms.rds
wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/DOQTL_demo.Rdata

# Copy the tutorial directory.
wget --directory-prefix=/tutorial ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/DO.impute.founders.sm.png
wget --directory-prefix=/tutorial ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/DOQTL_demo.Rmd
wget --directory-prefix=/tutorial ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/DOQTL_demo.html
wget --directory-prefix=/tutorial ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/DOQTL_demo.R

# set privilages - everybody can do everything
chmod --recursive 777 /data
chmod --recursive 777 /tutorial
