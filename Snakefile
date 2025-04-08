import subprocess
import glob
import os
import pathlib

querydir = Path(config["querydir"])
outdir = Path(config["outdir"])
cthreads = config["threads_per_job"]
LOCBASE = [x.split('.fna')[0] for x in os.listdir(querydir) if x.endswith('.fna')]

rule all:
    input:
        str(outdir) + "/merged/blastcoi.merged.fna",
        expand(str(outdir) + "/annot/bc_slice_{slice_num}.btout", slice_num=range(1, 11)),
        str(outdir) + "/annot/blastcoi.btout",
        str(outdir) + "/blastcoi_tax.tsv"

rule merge_fna_files:
    # merge FNA files in case there are many
    input:
        expand(str(querydir) + "/{lbase}.fna", lbase=LOCBASE)
    output:
        str(outdir) + "/merged/blastcoi.merged.fna"
    params:
        str(querydir) +"/*.fna"
    shell:
        """
        cat {params} > {output}
        """

rule get_annot_db:
   # download coi reference database
    output:
        str(outdir) + "/annot/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta.zip"
    params:
        str(outdir) +'/annot'
    shell:
        """
        wget --directory-prefix={params} https://www.reference-midori.info/download/Databases/GenBank263_2024-10-13/BLAST_sp/longest/fasta/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta.zip
        """

rule unzip_annot_db:
   # download coi reference database
    input:
        str(outdir) + "/annot/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta.zip"
    output:
        str(outdir) + "/annot/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta"
    params:
        str(outdir) +'/annot'
    shell:
        """
        unzip {params}/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta.zip -d {params}
        """

rule build_bl_db:
   # build bast db
    conda:
        "snakes/blast.yaml"
    input:
        str(outdir) + "/annot/MIDORI2_LONGEST_NUC_SP_GB263_CO1_BLAST.fasta"
    output:
        str(outdir) + "/annot/midori.ndb"
    params:
        str(outdir) +'/annot'
    shell:
        """
        makeblastdb -in {input} -dbtype 'nucl' -out {params}/midori
        """

rule split_fasta:
    # split query fasta to speed up the blast search
    input:
        str(outdir) + "/merged/blastcoi.merged.fna"
    output:
        expand(str(outdir) + "/annot/bc_slice_{slice_num}.fasta", slice_num=range(1, 11))
    params:
        str(outdir) + "/annot"
    shell:
        """
        python3 snakes/slice_fasta.py {input} {params}/bc
        """

rule blast:
    # run blast searches
    conda:
        "snakes/blast.yaml"
    input:
        str(outdir) + "/annot/bc_slice_{slice_num}.fasta",
        str(outdir) + "/annot/midori.ndb"
    output:
        str(outdir) + "/annot/bc_slice_{slice_num}.btout"
    params:
        db=str(outdir) + "/annot/midori"
    threads: cthreads
    shell:
        """
        blastn -db {params.db} -query {input[0]} -outfmt 6 -max_target_seqs 5 -evalue 1e-5 -num_threads {threads} -out {output}
        """

rule merge_blast:
    # merge blast output into single table
    input:
        expand(str(outdir) + "/annot/bc_slice_{slice_num}.btout", slice_num=range(1, 11))
    output:
        str(outdir) + "/annot/blastcoi.btout"
    params:
       str(outdir) + "/annot"
    shell:
        """
        cat {params}/bc_slice_*.btout > {output}
        """


rule build_tax_table:
    # build tax table based on blast output, seed lengths and cutoffs
    conda:
        "snakes/blastcoi_pylibs.yaml"
    input:
        str(outdir) + "/annot/blastcoi.btout",
        str(outdir) + "/merged/blastcoi.merged.fna"
    output:
        str(outdir) + "/blastcoi_tax.tsv"
    params:
       str(outdir) + "/blastcoi"
    shell:
        """
        python snakes/build_tax_table.py {input[0]} {input[1]} {params}
        """

# END
