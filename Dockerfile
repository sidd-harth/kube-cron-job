FROM google/cloud-sdk:alpine
MAINTAINER sid
RUN apk add --update mysql-client bash openssh-client && rm -rf /var/cache/apk/*
ENV GOOGLE_PROJECT istio-kubernetes-263915
ENV GOOGLE_CLIENT_EMAIL sid.live.demos@gmail.com
ENV DB_USER \
    DB_PASS \   
    DB_NAME  \
    DB_HOST  \
    ALL_DATABASES  \
    IGNORE_DATABASES  \
    GS_STORAGE_BUCKET kube-mysql-dump-bucket

COPY service-account.json /root/service_key.json
COPY backup.sh /

RUN gcloud config set project $GOOGLE_PROJECT && \
    gcloud auth activate-service-account --key-file /root/service_key.json && \
    gsutil ls gs://$GS_STORAGE_BUCKET/

ENTRYPOINT ["/backup.sh"]
VOLUME ["/root/.config"]