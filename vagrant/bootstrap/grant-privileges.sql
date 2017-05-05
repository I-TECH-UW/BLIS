CREATE USER 'root'@'%';
grant all on *.* to 'root'@'%' with grant option;
flush privileges;
