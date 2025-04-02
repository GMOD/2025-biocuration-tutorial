# Adding data to JBrowse

```sh
yarn global add @apollo-annotation/cli
sudo apt install jq
```

## Export the JBrowse config

```sh
apollo jbrowse get-config >config.json
```

## Add data with the JBrowse CLI

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

## Re-import the JBrowse config

```sh
apollo jbrowse set-config config.json
rm config.json
```
