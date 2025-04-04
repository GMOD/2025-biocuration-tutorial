# Adding data to JBrowse

We'll use the JBrowse CLI to add evidence tracks to the JBrowse config served by
Apollo.

## Export the JBrowse config

Apollo stores its JBrowse config internally, so to modify it we need to export
the config, make the changes we want, and then re-import the config to Apollo.
We first export the config by running:

```sh
cd ~
apollo jbrowse get-config >config.json
```

## Add data with the JBrowse CLI

We need the ID assigned by Apollo to each assembly to use when adding JBrowse
tracks. We could find these manually by inspecting the output of
`apollo assembly get`, but to make them easier to use, we'll use `jq` to get the
ids and store them in variables.

```sh
ELEGANS_ID=$(
  apollo assembly get |
    jq --raw-output '.[] | select(.name=="C. elegans")._id'
)
BRIGGSAE_ID=$(
  apollo assembly get |
    jq --raw-output '.[] | select(.name=="C. briggsae")._id'
)
BRENNERI_ID=$(
  apollo assembly get |
    jq --raw-output '.[] | select(.name=="C. brenneri")._id'
)
REMANEI_ID=$(
  apollo assembly get |
    jq --raw-output '.[] | select(.name=="C. remanei")._id'
)
TROPICALIS_ID=$(
  apollo assembly get |
    jq --raw-output '.[] | select(.name=="C. tropicalis")._id'
)
```

### Adding synteny tracks

WormBase has synteny files for some of their assemblies that we'll add to
JBrowse. When adding your own synteny tracks, be aware that the order in
`--assemblyNames` matters. The genome specified as the "query" when the track
was generated should be first, and the "target" genome should be second.

```sh
jbrowse add-track \
  https://s3.amazonaws.com/agrjbrowse/MOD-jbrowses/WormBase/synteny_data/c_elegans.c_briggsae.paf \
  --assemblyNames $BRIGGSAE_ID,$ELEGANS_ID \
  --name 'C. elegans/C. briggsae Synteny'

jbrowse add-track \
  https://s3.amazonaws.com/agrjbrowse/MOD-jbrowses/WormBase/synteny_data/c_briggsae.c_brenneri.paf \
  --assemblyNames $BRENNERI_ID,$BRIGGSAE_ID \
  --name 'C. briggsae/C. brenneri Synteny'

jbrowse add-track \
  https://s3.amazonaws.com/agrjbrowse/MOD-jbrowses/WormBase/synteny_data/c_brenneri.c_remanei.paf \
  --assemblyNames $REMANEI_ID,$BRENNERI_ID \
  --name 'C. brenneri/C. remanei Synteny'
```

WormBase does not have any synteny files for the *C. tropicalis* genome

```sh
cp /workspaces/2025-biocuration-tutorial/data/elegans_vs_tropicalis.paf /var/www/html/
jbrowse add-track \
  elegans_vs_tropicalis.paf \
  --protocol uri \
  --load inPlace \
  --assemblyNames $TROPICALIS_ID,$ELEGANS_ID \
  --name 'C. elegans/C. tropicalis Synteny'
```

### Adding other tracks

## Re-import the JBrowse config

```sh
apollo jbrowse set-config config.json
rm config.json
```
