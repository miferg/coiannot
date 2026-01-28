# coiannot

Assign taxonomy to cox1 sequences using blast searches with empirically defined thresholds and sintax. Recommended use after [coiner](https://github.com/miferg/coiner) and [Darn](https://github.com/hariszaf/darn).

After passing e-value and query coverage filters, for each rank, the identity percentage of blast alignment will define up to which rank annotation will be inherited from the subject sequence. Current thresholds are defined at the species and genus level.

Percent identity threshold values at the genus level for each eukaryotic class were recovered after analyzing a dereplicated database built using the Midori2 and Ekoi databases. Sequences that present alignments with identity values below its corresponging threshold are then annotated using the sintax algorithm with a bootstrap cutoff of 0.8.

# Installation

Pull the repository:

`git clone https://github.com/miferg/blastcoi.git`

Set up and activate a conda environment with snakemake:

`conda create -c conda-forge -c bioconda -n snakemake snakemake`

All dependencies will be installed with conda when the pipeline runs for the first time.

# Usage

Store all your fasta files in a same directory. Files must end with the ".fna" suffix.

Example:

`snakemake --cores 4 --use-conda --config querydir="my_coi" outdir="blastcoi_out" threads_per_job=2`

