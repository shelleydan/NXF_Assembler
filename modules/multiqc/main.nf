process multiqc {

    cpus 1
    memory '2 GB'

    container 'quay.io/biocontainers/multiqc:1.32--pyhdfd78af_0'

    input:
    path reports

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data"

    script:
    """
    multiqc . -o .
    """
}
