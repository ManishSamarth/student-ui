FROM tomcat:8
ADD ./target/studentapp-2.2-SNAPSHOT.war student.war
ADD ./student.war /webapps
