# blastcoi

Assign taxonomy to cox1 sequences using blast searches and empirically defined thresholds. Used in `https://github.com/miferg/coiner`

After passing e-value and query coverage filters, for each rank, the identity percentage of blast alignment will define up to which rank annotation will be inherited from the subject sequence.

Percent identity threshold values were recovered after analyzing the full Midori2 database. Values calibrated with https://doi.org/10.1673/031.012.1601 (table 3). These represent the quantile 0.1 of all minimal pidents per taxa.
 
| Taxonomic Level | Value    |
|-----------------|----------|
| division        | 70.38    |
| class           | 71.98    |
| order           | 74.28    |
| family          | 77.73    |
| genus           | 83.12    |
| species         | 95.00    |

# installation

Pull the repository:

`git clone https://github.com/miferg/blastcoi.git`

Set up and activate a conda environment with snakemake:

`conda create -c conda-forge -c bioconda -n snakemake snakemake`

All dependencies will be installed with conda when the pipeline runs for the first time.

# usage

Store all your fasta files in a same directory. Files must end with the ".fna" suffix.

Example:

`snakemake --cores 4 --use-conda --config querydir="my_coi" outdir="blastcoi_out" threads_per_job=2`

