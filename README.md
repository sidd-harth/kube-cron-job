# Kubernetes Cron Job

- This repo is used to take backup of Mysql DB from Kubernetes.
- The dump will be uploaded to Google Cloud Storage.
- You need to have a account in Google Cloud with a Storage bucket created.
- Create a Service Account and add all the permissions for bucket.
- All values are hardcoded in this sample like the details in `backup.sh` file

# Run these commands
```
kubectl create secret generic mysql-secrets \
--from-literal=password=hcl \
--from-literal=username=hcl \
--from-literal=root-password=hcl 
```

```
kubectl create configmap mysql-config \
--from-literal=database=hcldemo \
--from-literal=port=3306 \
--from-literal=host=mysql-service 
```

```
kubectl create -f mysql.yaml
kubectl create -f cronJob.yaml
```


# Testing the same on DOCKER
## Running MySQL with HOST/Service - mysqlservice
`docker run --name mysqlservice -e MYSQL_HOST=myss -e MYSQL_ROOT_PASSWORD=hcl -e MYSQL_USER=hcl -e MYSQL_PASSWORD=hcl -e MYSQL_DATABASE=hcldemo -d mysql:5.7`

## Docker Build the DUMP IMAGE
`docker build -t siddharth67/dump-sql-gs .`

## Run and test
`docker run --link mysqlservice:mysql -it siddharth67/dump-sql-gs`

# Google Storage 
![image](https://user-images.githubusercontent.com/28925814/77953001-2f516a80-72ea-11ea-807e-c1b6c7069064.png)

