#!/usr/bin/env nextflow

process bakta {

        cpus 8
        memory '16 GB'

	//conda '/mnt/scratch15/nodelete/c2006576/miniforge/miniforge_env/envs/bakta_env'
        //container 'community.wave.seqera.io/library/bakta:1.12.2--afcf24a27b8ab22a'

        input:
	val(bakta_db)
	//path(tmpdir)
	path(assembly)
	
        output:
	path "bakta/*"	

        script:
        
	def base = assembly.baseName

	"""
	source /mnt/scratch15/nodelete/c2006576/miniforge/miniforge_env/bin/activate bakta_env

	bakta --db ${bakta_db} \
              --genus Burkholderia \
              --species multivorans \
              --prefix ${base} \
              --output bakta/${base} \
              --threads ${task.cpus} \
	      --tmp-dir . \
              --gram - \
              --complete \
              ${assembly}

        """
}


