#!/usr/bin/env nextflow

process fastp {

        cpus 4
        memory '4 GB'
        container 'community.wave.seqera.io/library/fastp:1.3.7--075357a9d5c82494'

        input:
        tuple val(sample_id), path(r1), path(r2)

        output:
        tuple val(sample_id), 
	      path("${sample_id}/*_trim_R1.fastq.gz"), 
	      path("${sample_id}/*_trim_R2.fastq.gz"), emit: trimmed_reads

	path("${sample_id}/*.html"), emit: html
	path("${sample_id}/*.json"), emit: json	


        script:
        """
        mkdir -p ${sample_id}

        fastp \
		-q 20 \
		-u 10 \
		--cut_right \
		-i "${r1}" \
		-I "${r2}" \
		-o "${sample_id}/${sample_id}_trim_R1.fastq.gz" \
		-O "${sample_id}/${sample_id}_trim_R2.fastq.gz" \
		-h "${sample_id}/${sample_id}_report.html" \
		-j "${sample_id}/${sample_id}_report.json"
        """

}

