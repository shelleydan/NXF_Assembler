#!/usr/bin/env nextflow

process unicycler {

        cpus 8
        memory '8 GB'
        container 'community.wave.seqera.io/library/unicycler:0.5.1--65ba988046680154'

        input:
        tuple val(sample_id), path(r1), path(r2)

        output:
	path("${sample_id}/${sample_id}.fasta"), emit: assembly
	path("${sample_id}/*"), emit: reports

        script:
        """
        mkdir -p ${sample_id}

        unicycler -1 ${r1} \
		  -2 ${r2} \
		  -t ${task.cpus} \
		  -o ${sample_id}

	mv "${sample_id}/assembly.fasta" "${sample_id}/${sample_id}.fasta"
        """

}

