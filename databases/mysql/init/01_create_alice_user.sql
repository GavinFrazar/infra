CREATE USER 'alice'@'%' REQUIRE SUBJECT '/CN=alice';
GRANT ALL ON `%`.* TO 'alice'@'%';
