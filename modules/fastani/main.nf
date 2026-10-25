#!/usr/bin/env nextflow

process FastANI {

    cpus 8
    memory '64 GB'

    container 'community.wave.seqera.io/library/fastani:1.34--7e4c3a760052b908'

    input:
    tuple val(sample_id), 
	  path(query_list, stageAs: 'queries.txt'), 
          path(reference_list, stageAs: 'references.txt')

    output:
    path "${sample_id}.tsv", emit: fastani_results

    script:
    """
    fastANI --ql queries.txt \
	    --rl references.txt \
	     -o ${sample_id}.tsv \
	    --threads ${task.cpus}
    """
}
