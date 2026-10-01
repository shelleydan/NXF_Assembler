#!/usr/bin/env nextflow

// Call modules from module directory
include { fastqc as fastqc_raw } from './modules/fastqc/main.nf'
include { fastp } from './modules/fastp/main.nf'
include { fastqc as fastqc_trim } from './modules/fastqc/main.nf'
include { unicycler } from './modules/unicycler/main.nf'
include { checkM2 } from './modules/checkM2/main.nf'
//include { quast } from './modules/quast/main.nf'

/*
 * Pipeline Parameters
 */

params {
	fofn_input: Path = 'rawreads.csv'
	checkm2_db: Path = '/mnt/scratch15/nodelete/c2006576/DATABASE'
	tmpdir: Path = '/tmp'
}

/*
 * QC, Trimming & Assembly Workflow
 */ 

workflow {

	main:

	// Channel to intake the FOFN,
	
	samples_ch = Channel
		.fromPath(params.fofn_input)
		.splitCsv(header:true)
		.map { row ->
			tuple(
				row.sample_id,
				file(row.r1),
				file(row.r2)
			)
	}

	// QC on the raw reads
	fastqc_raw(samples_ch)

	// Trimming raw reads
	fastp(samples_ch)

	// QC on the trimmed reads
	fastqc_trim(fastp.out.trimmed_reads)

	// Genome Assembly
	unicycler(fastp.out.trimmed_reads)

	checkM2_db_ch = Channel.fromPath(params.checkm2_db)
	tmpdir_ch = Channel.fromPath(params.tmpdir)	


	// QC of the Genome Assemblies
	checkM2(unicycler.out.assembly.collect(), checkM2_db_ch, tmpdir_ch)
	//quast(unicycler.out.assembly.map {ids, fasta -> fasta}.collect())

	publish:
	fastqc_raw_reports=fastqc_raw.out
	fastp_trimmed=fastp.out.trimmed_reads
	fastp_trim_html=fastp.out.html
	fastp_trim_json=fastp.out.json
	fastqc_trim_reports=fastqc_trim.out
	unicycler_assemblies=unicycler.out.assembly
	unicycler_reports=unicycler.out.reports
	checkm2_reports=checkM2.out.reports
}

output {

	fastqc_raw_reports {
                path 'rawqc'
                mode 'copy'
        }
	
	fastp_trimmed {
                path 'trim_data'
                mode 'copy'
        }

	fastp_trim_html {
                path 'trim_data'
                mode 'copy'
        }

	fastp_trim_json {
                path 'trim_data'
                mode 'copy'
        }


	fastqc_trim_reports {
                path 'trimqc'
                mode 'copy'
        }

	unicycler_assemblies {
                path 'assemblies'
                mode 'copy'
        }

	unicycler_reports {
                path 'assemblies'
                mode 'copy'
        }

	checkm2_reports {
                path '.'
                mode 'copy'
        }

}	
