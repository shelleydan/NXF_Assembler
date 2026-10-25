#!/usr/bin/env nextflow

process bandage {

        cpus 4
        memory '1 GB'
        container 'community.wave.seqera.io/library/bandage:0.9.0--d08c11d75be5a14a'

        input:
        path(assembly_gfa)
	
        output:
	stdout
	path "bandage.svg"	

        script:
        """
	Bandage image ${assembly_gfa} bandage.svg
        """
}

workflow {
	bandage(file('/mnt/scratch45/c2006576/PhD_SWBio_2026_2030/RP1_SWBIO_OCT26_FEB27/multivoran_assemblies/assembler_nextflow/results/assemblies/BCC0005/assembly.gfa'))
}
