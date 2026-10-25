#!/usr/bin/env nextflow

// Call modules from module directory
include { fastqc as fastqc_raw } from './modules/fastqc/main.nf'
include { fastp } from './modules/fastp/main.nf'
include { fastqc as fastqc_trim } from './modules/fastqc/main.nf'
include { unicycler } from './modules/unicycler/main.nf'
include { bakta } from './modules/bakta/main.nf'
include { checkM2 } from './modules/checkM2/main.nf'
include { QUAST } from './modules/QUAST/main.nf'
include { FastANI } from './modules/fastani/main.nf'
include { FastANI as pairwiseFastANI } from './modules/fastani/main.nf'
include { FastANIFormat } from './modules/fastani_format/main.nf'
include { FastANIFormat as pairwiseFastANIFormat } from './modules/fastani_format/main.nf'
include { Bandage } from './modules/bandage/main.nf'
include { multiqc } from './modules/multiqc/main.nf'

/*
 * Pipeline Parameters
 */

params {
	fofn_input: Path = 'test.csv'
	checkm2_db: Path = '/mnt/scratch15/nodelete/c2006576/DATABASE'
	tmpdir: Path = '/tmp'
	fastani_db: Path = '/mnt/scratch15/nodelete/c2006576/DATABASE/FastANI/D1/references.csv'
	bakta_db = '/mnt/scratch15/nodelete/c2006576/DATABASE/bakta_db/db'
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

	// Bacterial Annotations with Bakta

	bakta_db_ch = Channel.value(params.bakta_db)
	tmpdir_ch = Channel.value(params.tmpdir)
	bakta(bakta_db_ch, tmpdir_ch, unicycler.out.assembly)

	checkM2_db_ch = Channel.value(params.checkm2_db)
	
	// QC of the Genome Assemblies
	checkM2(unicycler.out.assembly.collect(), checkM2_db_ch, tmpdir_ch)
	QUAST(unicycler.out.assembly.collect())

	Bandage(unicycler.out.assembly_gfa)

	// FastANI Input CSV
	fastani_input = unicycler.out.assembly
		.map { assembly -> assembly.toString() }
		.collectFile(name: 'assemblies.csv', newLine: true)
		.map { csv ->
			tuple(
				"all_vs_all",
				csv,
				file(params.fastani_db)
				)
			}

	pairwise_fastani_input = unicycler.out.assembly
                .map { assembly -> assembly.toString() }
                .collectFile(name: 'assemblies.csv', newLine: true)
                .map { csv ->
                        tuple(
                                "all_vs_all",
                                csv,
                                csv
                                )
                        }


	// FastANI & Formatting
	FastANI(fastani_input)

	pairwiseFastANI(pairwise_fastani_input)

	FastANIFormat(FastANI.out.fastani_results)
	pairwiseFastANIFormat(pairwiseFastANI.out.fastani_results)

	// MultiQC Report Generation
	multiqc_input = Channel.empty()

	multiqc_input = multiqc_input.mix(fastqc_raw.out)
	multiqc_input = multiqc_input.mix(fastqc_trim.out)
	multiqc_input = multiqc_input.mix(fastp.out.html)
	multiqc_input = multiqc_input.mix(fastp.out.json)
	multiqc_input = multiqc_input.mix(QUAST.out.reports)
	multiqc_input = multiqc_input.mix(checkM2.out.reports)

	multiqc(multiqc_input.collect())

	publish:
	fastqc_raw_reports=fastqc_raw.out
	fastp_trimmed=fastp.out.trimmed_reads
	fastp_trim_html=fastp.out.html
	fastp_trim_json=fastp.out.json
	fastqc_trim_reports=fastqc_trim.out
	unicycler_assemblies=unicycler.out.assembly
	unicycler_reports=unicycler.out.reports
	checkm2_reports=checkM2.out.reports
	quast_reports=QUAST.out.reports
	fastani_output=FastANIFormat.out
	pairwisefastani_output=pairwiseFastANIFormat.out
	bandage_images=Bandage.out
	bakta_annotations=bakta.out
	multiqc_report=multiqc.out.report
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

	quast_reports {
                path '.'
                mode 'copy'
        }


	fastani_output {
               path 'fastani'
                mode 'copy'
        }

	pairwisefastani_output {
               path 'pairwise_fastani'
               mode 'copy'
        }
	
	bandage_images {
               path 'bandage'
               mode 'copy'
        }

	bakta_annotations {
               path '.'
               mode 'copy'
        }

	multiqc_report {
               path './multiqc'
               mode 'copy'
        }

}	
