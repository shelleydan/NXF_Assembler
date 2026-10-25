#!/usr/bin/env nextflow

process Bandage {

        cpus 4
        memory '1 GB'
        container 'community.wave.seqera.io/library/bandage:0.9.0--d08c11d75be5a14a'

        input:
        path(assembly_gfa)
	
        output:
	path "*_bandage.svg"	

        script:
        
	def base = assembly_gfa.baseName

	"""
	Bandage image ${assembly_gfa} ${base}_bandage.svg --height 500 --width 500
        """
}


