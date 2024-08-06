# cilium-manifests

`cilium-manifests` is a module that tracks upstream Cilium Kubernetes resources and adapts them for OpenAI.

## Features

* Plain Kubernetes resources (no Helm)
* Cilium v1.13
* IPAM `cluster-pool` or `azure`
* Prometheus metrics

This module does NOT manage Azure resources or other components. See the parent module [`cilium`](https://github.com/openai/openai/tree/master/api/terraform/modules/cilium)

## Overview

We prefer our Terraform modules represent Kubernetes resources directly, using the [`kubernetes`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) provder. This improves plan diffs, let's us directly managed resources, eliminates layers of templating, and avoids Helm's "all-or-nothing" behaviors.

## Usage

WARN: Not yet ready for use! We do not have any OpenAI customizations yet.

Use this module from a top-level Terraform workspace.

```tf
module "cilium" {
  source = "../../modules/cilium-manifests"
  # TODO: Support Module versioning
  # source = "git@github.com:openai/terraform-modules.git//k8s/cilium?ref=SHA_TAG_OR_BRANCH
}
```

## Upgrading

Some upstream projects like Cilium use Helm charts to template Kubernetes manifests. These should be rendered locally and converted to Terraform resources. Generating and visually inspecting diffs isn't great, but it's worth it to keep our modules manageable.

Generate upstream's "suggested" Kubernetes manifests from a Helm chart and `helm.yaml` values with `helm` and convert those to Terraform resources with [`k2tf`](https://github.com/sl1pm4t/k2tf). Only maintainers of this module need to do this.

```
make
make convert
```

Inspect the "suggested" / generated files `helm/manifests.yaml` and `helm/manifests.tf` to what changes between releases or with different features enabled (`git diff`). Use these suggestions to help make decisions about which part(s) are relevant to OpenAI and ought to be brough into our Terraform modules.

* It's easy to compare Cilium official Kubernetes resources vs our modified Kubernetes resources
* PR diff's show what we're choosing to incorporate and what we're not
* PR reviewers can inspect upstream suggested manifests vs our manifests

Alternately, you can ignore helm and skip generating suggested manifests. They're just a tool to help guide us in writing our Terraform resources.
