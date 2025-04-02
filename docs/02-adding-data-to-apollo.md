# Adding data to Apollo

```sh
echo 'export PATH="$(yarn global bin):$PATH"' >> ~/.bashrc
yarn global add @apollo-annotation/cli
```

```sh
apollo config address http://localhost/apollo
apollo config accessType root
apollo config rootPassword some-secret-password
apollo login
```

## Adding genomes

```sh
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_elegans.PRJNA13758.WS278.genomic.fa.gz -a 'C. elegans'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_briggsae.PRJNA10731.WS284.genomic.fa.gz -a 'C. briggsae'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_brenneri.PRJNA20035.WS284.genomic.fa.gz -a 'C. brenneri'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_remanei.PRJNA53967.WS284.genomic.fa.gz -a 'C. remanei'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_tropicalis.PRJNA53597.WS284.genomic.fa.gz -a 'C. tropicalis'
```

## Adding features

```sh
apollo feature import C_elegans.gff3 -a 'C. elegans'
apollo feature import C_briggsae.gff3 -a 'C. briggsae'
apollo feature import C_brenneri.gff3 -a 'C. brenneri'
apollo feature import C_remanei.gff3 -a 'C. remanei'
apollo feature import C_tropicalis.gff3 -a 'C. tropicalis'
```
