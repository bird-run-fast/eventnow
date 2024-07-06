# al2023 に mysql client を入れる
# localinstall する rpm は AMI ごとに変わるので注意
sudo dnf -y localinstall  https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf -y install mysql mysql-community-client

# クラスターに接続
mysql -u root -p -h Xxxx.ap-northeast-1.rds.amazonaws.com
Q7oBjnbB9hEAI6dmmDE1

# app 用の DB を作成
CREATE DATABASE eventnow;

# app 用の User を作成。外部アクセスできないように ip と 見れる DB 権限を絞る
CREATE USER 'Xxx'@'10.0%' IDENTIFIED BY 'Xxx';
GRANT USAGE ON *.* TO 'Xxx'@'10.0%' ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE ON eventnow.* TO 'Xxx'@'10.0%';

# 権限がつけられたか確認
show grants for 'Xxx'@'10.0%' ;

# もし外したくなったら...
REVOKE SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE ON dlsite.* from 'Xxx'@'10.0%';
drop user 'Xxx'@'10.0%';
