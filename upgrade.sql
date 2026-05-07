-- ============================================
-- 数据库升级脚本：V1 → V2（属性精简）
-- 在 Navicat 中对 pets_game 库执行此脚本
-- ============================================

USE pets_game;

-- 添加新列
ALTER TABLE pets ADD COLUMN affinity INT DEFAULT 0 AFTER cleanliness;
ALTER TABLE pets ADD COLUMN bond INT DEFAULT 0 AFTER affinity;
ALTER TABLE pets ADD COLUMN personality VARCHAR(20) DEFAULT '活泼' AFTER bond;

-- 迁移现有数据：将旧的5属性转化为亲密度/默契度
UPDATE pets SET affinity = LEAST(100, (strength + agility + intelligence + charm + defense) / 5);
UPDATE pets SET bond = LEAST(100, (strength + agility + intelligence) / 3);

-- 删除旧列
ALTER TABLE pets DROP COLUMN strength;
ALTER TABLE pets DROP COLUMN agility;
ALTER TABLE pets DROP COLUMN intelligence;
ALTER TABLE pets DROP COLUMN charm;
ALTER TABLE pets DROP COLUMN defense;

-- 验证
SELECT id, name, affinity, bond, personality FROM pets;
