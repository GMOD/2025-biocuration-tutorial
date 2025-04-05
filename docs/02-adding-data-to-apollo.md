# Adding data to Apollo

Now that Apollo is up and running, we need to add some data to it. To do this,
we'll use the Apollo CLI, which has already been installed for you.

To use the CLi, we need to configure it with the address and credentials of our
server. We'll use the `apollo config` command to do this. The "rootPassword"
below should be the same value you put for the "ROOT_USER_PASSWORD" in the
`.env` file in the last section. In a new terminal (leave the previous one where
you started Apollo running), run:

```sh
apollo config address http://localhost/apollo/
apollo config accessType root
apollo config rootPassword some-secret-password
apollo login
```

## Adding assemblies

We're going to add some assemblies hosted by WormBase using the
`apollo assembly add-from-fasta` command. If you have a local FASTA file, you
can also use this command to upload it to the Apollo server, but for simplicity
we'll use remotely hosted files for this tutorial. The `-a` flag in the below
commands is the name we give the assembly.

```sh
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_elegans.PRJNA13758.WS278.genomic.fa.gz -a 'C. elegans'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_briggsae.PRJNA10731.WS284.genomic.fa.gz -a 'C. briggsae'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_brenneri.PRJNA20035.WS284.genomic.fa.gz -a 'C. brenneri'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_remanei.PRJNA53967.WS284.genomic.fa.gz -a 'C. remanei'
apollo assembly add-from-fasta https://s3.amazonaws.com/wormbase-modencode/fasta/current/c_tropicalis.PRJNA53597.WS284.genomic.fa.gz -a 'C. tropicalis'
```

## Adding features

Now we'll add the features for which we want to be able to edit the annotations.
Depending on your use case, for your data this may be a set of predicted genes,
a set of already-curated genes, or if you only want to edit a couple of genes,
you may choose to omit this step entirely and manually copy in genes from a
JBrowse evidence track (more on that later).

For this demo, we'll add the official gene sets for these assemblies from
WormBase. To preserve space in the Codespaces instance, these files contain only
a small subset of the total annotations in a region of interest.

```sh
apollo feature import /workspaces/2025-biocuration-tutorial/data/C_elegans.gff3 -a 'C. elegans'
apollo feature import /workspaces/2025-biocuration-tutorial/data/C_briggsae.gff3 -a 'C. briggsae'
apollo feature import /workspaces/2025-biocuration-tutorial/data/C_brenneri.gff3 -a 'C. brenneri'
apollo feature import /workspaces/2025-biocuration-tutorial/data/C_remanei.gff3 -a 'C. remanei'
apollo feature import /workspaces/2025-biocuration-tutorial/data/C_tropicalis.gff3 -a 'C. tropicalis'
```

Now that we have some features loaded, the next section will cover the Apollo
user interface.

Next: [Exploring the Apollo UI](03-exploring-the-apollo-ui.md)
