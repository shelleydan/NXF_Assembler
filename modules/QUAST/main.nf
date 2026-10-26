#!/usr/bin/env nextflow

process QUAST {

        cpus 8
        memory '4 GB'
	//memory { assemblies.size() * 1.GB }
        container 'community.wave.seqera.io/library/quast:5.3.0--77e72857b4af9b37'

        input:
        path(assemblies)

        output:
	path("quast/*"), emit: reports	

        script:
        """

	echo "ASSEMBLIES=${assemblies}"

	## Preparing directory for CheckM2
	mkdir genomes

	for file_genome in ${assemblies}; do
		echo "LINKING: \$file_genome"
		ln -s "\$(realpath "\$file_genome")" genomes/
		done

	quast.py -t ${task.cpus} \
	 	 -o  quast \
	 	 genomes/*
        """
}

