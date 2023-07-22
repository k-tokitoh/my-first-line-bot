# prerequisites

create `envs/terraform.tfvars` based on `envs/terraform.tfvars.template`

# development

```
$ cd modules/lambda
$ npm run build
```

```
$ cd envs
$ terraform apply
```

```
$ terraform destroy
```

# test

```
$ terraform show | grep invoke_url
    invoke_url    = "https://{id}.execute-api.us-east-1.amazonaws.com/{stage}"
$ curl https://{id}.execute-api.us-east-1.amazonaws.com/{stage}
```

# todo

- make
