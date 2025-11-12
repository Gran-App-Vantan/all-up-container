-- Create databases
CREATE DATABASE IF NOT EXISTS vanx;
CREATE DATABASE IF NOT EXISTS roulette;
CREATE DATABASE IF NOT EXISTS slot;
CREATE DATABASE IF NOT EXISTS poker;

-- Create users and grant permissions
CREATE USER IF NOT EXISTS 'vanx_user'@'%' IDENTIFIED BY 'your_vanx_password_here';
GRANT ALL PRIVILEGES ON vanx.* TO 'vanx_user'@'%';

CREATE USER IF NOT EXISTS 'poker_user'@'%' IDENTIFIED BY 'your_poker_password_here';
GRANT ALL PRIVILEGES ON poker.* TO 'poker_user'@'%';

CREATE USER IF NOT EXISTS 'roulette_user'@'%' IDENTIFIED BY 'your_roulette_password_here';
GRANT ALL PRIVILEGES ON roulette.* TO 'roulette_user'@'%';

CREATE USER IF NOT EXISTS 'slot_user'@'%' IDENTIFIED BY 'your_slot_password_here';
GRANT ALL PRIVILEGES ON slot.* TO 'slot_user'@'%';

-- Flush privileges to ensure they are saved
FLUSH PRIVILEGES;