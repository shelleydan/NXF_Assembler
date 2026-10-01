#!/usr/bin/env nextflow

process checkM2 {

        cpus 8
        memory '16 GB'
        container 'community.wave.seqera.io/library/checkm2:1.1.0--2155b1d4034fecdc'

        input:
        path(assemblies)
	path(checkM2_db)
	path(tmpdir)

        output:
	path("checkM2/*"), emit: reports	

        script:
        """

	echo "ASSEMBLIES=${assemblies}"

	## Preparing directory for CheckM2
	mkdir genomes

	for file_genome in ${assemblies}; do
		echo "LINKING: \$file_genome"
		ln -s "\$(realpath "\$file_genome")" genomes/
		done

	## Database Download
	#checkm2 database --download --path ${checkM2_db}

	## Running CheckM2
	checkm2 predict --input genomes \
		--extension fasta \
                --output-directory checkM2 \
		--database_path "${checkM2_db}/CheckM2_database/uniref100.KO.1.dmnd" \
                --tmpdir ${tmpdir} \
                --threads ${task.cpus} \
                --specific \
                --stdout \
                --remove_intermediates \
                --force
        """
}

