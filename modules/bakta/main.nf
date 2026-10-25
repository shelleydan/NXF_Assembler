#!/usr/bin/env nextflow

process bakta {

        cpus 8
        memory '8 GB'
        container 'community.wave.seqera.io/library/bakta:1.12.2--afcf24a27b8ab22a'

        input:
	val(bakta_db)
	val(tmpdir)
	path(assembly)
	
        output:
	path "bakta/*"	

        script:
        
	def base = assembly.baseName

	"""
	mkdir -p bakta/${base}
	
	bakta --db ${bakta_db} \
              --genus Burkholderia \
              --species multivorans \
              --prefix ${base} \
              --output bakta/${base} \
              --threads ${task.cpus} \
              --tmp-dir ${tmpdir} \
              --gram - \
              --complete \
              ${assembly}

        """
}


