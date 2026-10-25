#!/usr/bin/bash nextflow

process FastANIFormat {

    publishDir 'results/FastANI', mode: 'copy'

    input:
    path fastani_tsv

    output:
    path 'identity_matrix.tsv'

    script:
    """
    awk -F '\\t' '
    {
      gsub(".*/", "", \$1); gsub(".*/", "", \$2);
      gsub(".fasta", "", \$1); gsub(".fasta", "", \$2);

      key = (\$1 < \$2) ? \$1 FS \$2 : \$2 FS \$1

      sum[key] += \$3
      count[key] += 1

      samples[\$1]
      samples[\$2]
    }
    END {
      n = asorti(samples, s)

      # Print header with leading tab
      printf "\\t"
      for (i = 1; i <= n; i++) printf "%s\\t", s[i]
      printf "\\n"

      # Build symmetric matrix with leading tab
      for (i = 1; i <= n; i++) {
        printf "\\t%s\\t", s[i]

        for (j = 1; j <= n; j++) {
          if (s[i] == s[j]) {
            printf "100.00\\t"
          } else {
            key = (s[i] < s[j]) ? s[i] FS s[j] : s[j] FS s[i]
            if (count[key]) {
              printf "%.2f\\t", sum[key] / count[key]
            } else {
              printf "NA\\t"
            }
          }
        }
        printf "\\n"
      }
    }
    ' ${fastani_tsv} > identity_matrix.tsv
    """
}
