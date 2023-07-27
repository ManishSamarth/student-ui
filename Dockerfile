FROM ubuntu as builder
RUN apt update -y && apt install openjdk-8-jdk -y
RUN apt install maven -y 
COPY ./* /mnt/
WORKDIR /mnt
RUN mvn clean package

FROM amazon/aws-cli as sender
COPY .aws /root/.aws
RUN aws s3 ls
COPY --from=builder /mnt/target/studentapp-2.2-SNAPSHOT.war .
RUN aws s3 cp studentapp-2.2-SNAPSHOT.war s3://artifactory-manish/studentapp-${BUILD_NUMBER}.war

FROM tomcat 
COPY --from=builder /mnt/target/studentapp-2.2-SNAPSHOT.war webapps/studentapp.war
