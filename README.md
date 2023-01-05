# Terraform DynDNS

This repo contains a terraform module to automatically update DNS entries with a dynamic IP (IPv4 and IPv6). Terraform is executed as a cron-job periodically.

In my case, I use AWS for my DNS records. Therefore the credentials have to be provided. As cron does not read environment variables, I have to pass them directly inside the cron-job definition. Not an elegant solution, but it works. Happy to implement improvements, if you have any!

## Two possible setup paths

### non-docker

Allows __IPv4 and IPv6__ updates. Just copy the content of the _code_ folder somewhere and adopt the cron job accoringly.
Of course you can also place your aws credentials in the _~/.aws/config_ and _~/.aws/credentials_ files.

#### Example cron job for non-docker

The example below would execute terraform at the top of every hour.

```sh
0 * * * * AWS_ACCESS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=XXXX AWS_DEFAULT_REGION="eu-central-1" /usr/local/bin/terraform -chdir=/code apply -auto-approve || /terraform -chdir=/code init
```

If you want to debug your cron-job use something like this:

```sh
0 * * * * AWS_ACCESS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=XXXX AWS_DEFAULT_REGION="eu-central-1" /usr/local/bin/terraform -chdir=/code apply -auto-approve >> /code/terraform_crontab.log 2>&1 || /terraform -chdir=/code init >> /code/terraform_crontab.log 2>&1
```

### docker

The docker version has the nice benefit, that nothing has to be installed on your system if you are already using docker.
The turnside of this method is, that you __can only update IPv4 entries__, as docker only natively uses only IPv4 (and NAT accordingly).
As shown in the _docker-compose.yml_ file, two directories need to be mounted:

_code_ contains your terraform code. Feel free to adopt this to your needs.

_jobs_ contains a single file `dyndns` which unfortunately has to be named exactly like that.
If this does not work, it'll trigger a `terraform init`. The default cronjob is set to run every minute. Due to the
circle-dependency inside the _Dockerfile_ this will result in the following steps:

1. The container is spawned
2. The first cronjob execution at the top of the minute is running `crontab /etc/cron.d/dyndns` to "self-bootstrap" the new mounted file from the jobs directory
3. The second cronjob execution at the top of the minute is trying to run `terraform apply -auto-approve` which fails and instead runs `terraform init` therefore
4. The third cronjob execution at the top of the minute finally succeeds in executing `terraform apply -auto-approve`.

As you might notice, it might happen that you have to wait approxiametly __three minutes__ until the first apply is triggered.
Feel free to improve this for your purposes!

#### Example cron job for docker

The example below would execute terraform at the top of every hour.

```sh
0 * * * * /terraform -chdir=/code apply -auto-approve || /terraform -chdir=/code init
```

If you want to debug your cron-job use something like this:

```sh
0 * * * * /terraform -chdir=/code apply -auto-approve >> /code/terraform_crontab.log 2>&1 || /terraform -chdir=/code init >> /code/terraform_crontab.log 2>&1
```
