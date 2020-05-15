CREATE TABLE IF NOT EXISTS `pointshop_points` (
    `sid64` CHAR(17) PRIMARY KEY,
    `points` INTEGER
);

CREATE TABLE IF NOT EXISTS `pointshop_items` (
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `sid64` VARCHAR(17),
    `item_id` VARCHAR(30),
    `modifiers` VARCHAR(200),
    `equipped` BOOLEAN
);