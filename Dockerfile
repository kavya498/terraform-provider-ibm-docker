From alpine:3.7

ENV GOPATH /go

ENV GOLANG_VERSION 1.13.12
ENV GOLANG_SRC_URL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
ENV GOLANG_SRC_SHA256 17ba2c4de4d78793a21cc659d9907f4356cd9c8de8b7d0899cdedcef712eba34

ENV TERRAFORM_VERSION 0.13.5
ENV TERRAFORM_IBMCLOUD_VERSION 1.14.0

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN set -ex \
	&& apk update \
	&& apk add --no-cache ca-certificates  \
	&& apk add --no-cache --virtual .build-deps \
	&& apk add bash gcc musl-dev openssl zip make bash git go curl \
	&& curl -s https://raw.githubusercontent.com/docker-library/golang/221ee92559f2963c1fe55646d3516f5b8f4c91a4/1.9/alpine3.7/no-pic.patch -o /no-pic.patch \
	&& cat /no-pic.patch \
	&& export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
	&& wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
	&& echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz \
	&& cd /usr/local/go/src \
	&& patch -p2 -i /no-pic.patch \
	&& ./make.bash \
    && rm -rf /*.patch \
	&& apk del .build-deps

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

WORKDIR $GOPATH/bin

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN chmod +x terraform

RUN rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN echo "Terraform 13 installation done"

WORKDIR "/root"

# RUN echo $' providers { \n \
# ibm = "/go/bin/terraform-provider-ibm_v${TERRAFORM_IBMCLOUD_VERSION}" \n \
# }' > /root/.terraformrc

# WORKDIR $GOPATH/bin

# RUN wget https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64.zip

# RUN unzip linux_amd64.zip

# RUN chmod +x terraform-provider-ibm_*

# RUN rm -rf linux_amd64.zip

RUN mkdir -p "/root/.terraform.d/plugins/registry.terraform.io/ibm-cloud/ibm/${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64"  && chmod -R 777 "$HOME/.terraform.d/plugins/registry.terraform.io/ibm-cloud/ibm/${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64"

WORKDIR "/root/.terraform.d/plugins/registry.terraform.io/ibm-cloud/ibm/${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64"

RUN wget https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64.zip

RUN unzip linux_amd64.zip

RUN chmod +x terraform-provider-ibm_*

RUN rm -rf linux_amd64.zip

RUN echo "Terraform Provider IBM Binary installation done"

WORKDIR "/root"
