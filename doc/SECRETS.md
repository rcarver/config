# Secrets

Config provides a system for storing sensitive information in the
project repository. Broadly we call this information "secrets".

In order to store sensitive information within the project, it must be
encrypted. Once encrypted, it can be decrypted at runtime in order to be
used on the node.

## Workflow

Dealing with sensitive information doesn't need to be hard. Config
supports it natively in order to reduce the pain as much as possible.
The workflow:

  1. Generate a master secret.
  2. Decide how you would like to partition your secrets.
  3. Encrypt sensitive information and add it to your configuration.
  4. Decrypt and use secrets at runtime.

## Generate a master secret

First generate a master secret. The master secret is used to generate
other secrets.

    bin/config-generate-master-secret

The result of this command is a file at `.data/secret-master`. Config
can now generate one or more shared secrets using the master. 

## Partition your secrets

Config allows you to partition secrets using multiple keys. By default,
everything is encrypted in the 'default' partition. Your `config.rb`
should contain:

    # config.rb
    configure :secrets,
      partition: "default"

In most cases this is adequate. To reduce the exposure of sensitive data
if one key is compromised you may opt to use multiple partitions. To use
a different secret within a cluster, simply change it.
    
    # clusters/prod.rb
    configure :secrets,
      partition: "prod"

## Encrypt

Use `config-encrypt` to encrypt a value you would like to keep secret.

    bin/config-encrypt $AWS_SECRET_ACCESS_KEY

The result is an encrypted form of your AWS access key written to
STDOUT. Once you have encrypted the value, it's safe to store either
globally in `config.rb` or in a cluster configuration.

If the value you are encrypting is large (an SSL cert for example), pipe
it to `config-encrypt`. 

    cat /tmp/example.com.cert | bin/config-encrypt

This works well with clipboard commands on the Mac.

    pbpaste | bin/config-encrypt | pbcopy

### Partition

If you have opted to use multiple partitions, use the `-p` flag to
specify for which partition the secret should be encrypted.

    bin/config-encrypt -p prod $AWS_SECRET_ACCESS_KEY

### Encrypt with syntax

To simplify adding a secret value to your configuration,
`config-encrypt` can write the code for you.

    bin/config-encrypt -c aws_secret_access_key:$AWS_SECRET_ACCESS_KEY

Use the `-c` flag and separate the key and value with a colon. The
result looks something like this:

    aws_secret_access_key: secret("<encrypted value>")

### Encrypt to a file

If the encrypted value is large (again, an SSL cert for example), you
may wish to store it in a file instead of as a large string.

    bin/config-encrypt -f aws_secret_access_key $AWS_SECRET_ACCESS_KEY

Instead of writing the encrypted string to STDOUT, it will be written to
a file at `secrets/default-aws_secret_access_key`.

## Decrypt

Secret values are decrypted automatically at runtime. Config knows that
a value should be decrypted when you set it using the `secret` helper.

  configure :amazon,
    aws_secret_access_key: secret("<encrypted aws key>")

If the value is stored in a file, pass a Symbol naming the file.

  configure :amazon,
    aws_secret_access_key: secret(:aws_secret_access_key)

