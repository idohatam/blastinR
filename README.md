# **blastinR**
A collection of functions aimed at interfacing R and blast+ suite.
The tidyverse package should be loaded first as the functions use some tidyverse packages 
as dependencies 

```{r libs, eval=FALSE}
library("tidyverse")
```


## **The make_blast_db function**

The `make_blast_d1b` function is a wrapper for the `makeblastdb` function from BLAST+.
It will generate all the files required for a BLAST database. 
The `infile` argument should specify the path to a fasta file containing all the sequences 
to be included in the database. The `outfile` argument should specify the names of all the
database files to be generated. All database files will carry the same name but will differ
in extension. 

```{r mdb, eval=FALSE}
make_blast_db(infile = "PATH/TO/FILE.FASTA",outfile="my_out_file")
```


## **The blstinr function**

The `btype` argument specifies which blast type would be used, the default is `blastn`.
The `numt` arguments specifies the number of threads to be used, only work with UNIX based OS, default value is 1. 


```{r mdb, eval=FALSE}
blastinr(btype = "blastn", dbase = "PATH/TO/DATABASE/FILES", 
qry = "PATH/TO/FASTA/FILE")
```


## **The retrive_hit_seqs function**

## **Plotting taxonomy or annotations**

