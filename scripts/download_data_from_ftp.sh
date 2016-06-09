# make /data folder and subfolders
mkdir -p /data
mkdir -p /tutorial
mkdir -p /tutorial/figure

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

# Copy figures.
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/benzene_hypothesis.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/benzene_study_design.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/DO.impute.founders.sm.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/EnsEMBL.Sult3a1.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/EnsEMBL_Sult3a1_Gm4794_paralog.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/French.et.al.Figure3.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/French.et.al.Sup.Figure2.png
wget --directory-prefix=/tutorial/figure ftp://ftp.jax.org/dgatti/MDIBL_Aging2016/figure/French.et.al.Sup.Figure3.png

# set privilages - everybody can do everything
chmod --recursive 777 /data
chmod --recursive 777 /tutorial
