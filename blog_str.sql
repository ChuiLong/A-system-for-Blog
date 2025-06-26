/*
 Navicat Premium Dump SQL

 Source Server         : Easy
 Source Server Type    : MySQL
 Source Server Version : 80404 (8.4.4)
 Source Host           : localhost:3307
 Source Schema         : blog_str

 Target Server Type    : MySQL
 Target Server Version : 80404 (8.4.4)
 File Encoding         : 65001

 Date: 02/06/2025 21:01:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins`  (
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hire_date` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`user_id`) USING BTREE,
  CONSTRAINT `fk_admin_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES ('00000000-0000-0000-0000-000000000001', '2025-05-30');

-- ----------------------------
-- Table structure for announcements
-- ----------------------------
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements`  (
  `announcement_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_pinned` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`announcement_id`) USING BTREE,
  INDEX `idx_pinned_active`(`is_pinned` DESC, `is_active` ASC, `created_at` DESC) USING BTREE,
  INDEX `fk_announcement_author`(`author_id` ASC) USING BTREE,
  CONSTRAINT `fk_announcement_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of announcements
-- ----------------------------
INSERT INTO `announcements` VALUES ('283d4666-105f-45be-aee9-15603d03b39e', '测试', '亲爱的创作者伙伴：\r\n\r\n为持续提升账户安全防护等级，保障每位创作者的数字资产与创作权益，我们诚挚建议您完成三方账号绑定，开启双重验证守护。此举将为您带来以下便利：\r\n\r\n一键快捷登录体验，减少密码管理烦恼\r\n实时登录动态提醒，随时掌握账户安全状态\r\n专属身份核验通道，确保创作成果妥善保护\r\n绑定方法：头像下拉菜单中，进入「个人中心」-「账号设置」，选择第三方绑定，进入后，绑定任意三方账号（微信，QQ，GitHub，新浪微博，百度，华为）均可完整绑定操作。\r\n\r\n绑定过程中如遇任何疑问，欢迎随时通过「在线客服」通道联系我们的专属服务团队。让我们携手共建更安全、优质的创作空间，让灵感自由绽放。', '00000000-0000-0000-0000-000000000001', '2025-05-31 21:02:15', 0, 1);
INSERT INTO `announcements` VALUES ('772d5220-3e18-11f0-8563-3024a99540ab', '欢迎来到南开博客', '这是一条测试公告，欢迎大家使用我们的博客系统！', '00000000-0000-0000-0000-000000000001', '2025-05-31 20:12:04', 1, 1);
INSERT INTO `announcements` VALUES ('847dc413-e9bd-44ac-9367-7527e095fdcb', '测试', '这是\r\n\r\n一条\r\n\r\n足够\r\n\r\n长\r\n\r\n的\r\n\r\n通知\r\n\r\n！！！', '00000000-0000-0000-0000-000000000001', '2025-05-31 21:01:28', 0, 0);

-- ----------------------------
-- Table structure for board_follows
-- ----------------------------
DROP TABLE IF EXISTS `board_follows`;
CREATE TABLE `board_follows`  (
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `board_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `follow_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `board_id`) USING BTREE,
  INDEX `fk_follow_board`(`board_id` ASC) USING BTREE,
  CONSTRAINT `fk_follow_board` FOREIGN KEY (`board_id`) REFERENCES `boards` (`board_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_follow_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of board_follows
-- ----------------------------
INSERT INTO `board_follows` VALUES ('00000000-0000-0000-0000-000000000001', '0442e24e-ade0-494a-833b-02e3c5327717', '2025-05-31 21:17:33');
INSERT INTO `board_follows` VALUES ('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '2025-05-30 11:52:19');
INSERT INTO `board_follows` VALUES ('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', '2025-05-30 11:52:19');
INSERT INTO `board_follows` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', '1f857153-c027-4b06-929a-092d892e2395', '2025-06-02 20:52:41');
INSERT INTO `board_follows` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', '345025a5-aa03-43d1-b452-59072981ebeb', '2025-06-02 20:52:38');
INSERT INTO `board_follows` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', '44444444-4444-4444-4444-444444444444', '2025-06-02 20:52:42');
INSERT INTO `board_follows` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', '9b8367e9-5895-4d10-8f36-42eb28967005', '2025-06-02 20:52:40');

-- ----------------------------
-- Table structure for boards
-- ----------------------------
DROP TABLE IF EXISTS `boards`;
CREATE TABLE `boards`  (
  `board_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`board_id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of boards
-- ----------------------------
INSERT INTO `boards` VALUES ('0442e24e-ade0-494a-833b-02e3c5327717', '编程问答', '这是关于编程问答的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('1f857153-c027-4b06-929a-092d892e2395', '心理健康', '这是关于心理健康的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('2098d3e3-7837-431e-9a68-98c7eeda965a', '课程评价', '关于课程的经验和评价');
INSERT INTO `boards` VALUES ('345025a5-aa03-43d1-b452-59072981ebeb', '兼职信息', '关于校内外的兼职渠道');
INSERT INTO `boards` VALUES ('44444444-4444-4444-4444-444444444444', '志愿服务', '校内志愿服务招募');
INSERT INTO `boards` VALUES ('46f0c298-772a-4433-a344-010853bf942c', '游戏讨论', '这是关于游戏讨论的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('55555555-5555-5555-5555-555555555555', '生活风格', '美食、旅行与健康分享');
INSERT INTO `boards` VALUES ('57dbb53f-7374-46c8-8dfa-1e3ecb199d7a', '理财投资', '这是关于理财投资的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('64da97eb-ff24-474b-9467-086d4c803065', '艺术设计', '这是关于艺术设计的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('87f49225-ede6-4fc5-9be3-3327ac4efb61', '旅行攻略', '这是关于旅行攻略的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('88e30860-3d9d-4ce8-88bc-8f9ab6ac06e1', '音乐欣赏', '这是关于音乐欣赏的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('969d8f55-db5c-4b48-bdce-28b6551b5969', '美食天地', '这是关于美食天地的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('9b8367e9-5895-4d10-8f36-42eb28967005', '体育竞技', '这是关于体育竞技的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('9d1dc282-7801-4571-81e2-2d8bcdd7f0f8', '时尚潮流', '这是关于时尚潮流的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('a7f2360e-bac8-410c-9705-719d523623d8', '科学探索', '这是关于科学探索的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('e4ded9d4-e833-47b0-b16f-b2ffb6fbf37e', '读书笔记', '这是关于读书笔记的讨论版块，欢迎交流分享。');
INSERT INTO `boards` VALUES ('f26cf880-be1e-487e-a663-96caedff0061', '汽车之家', '这是关于汽车之家的讨论版块，欢迎交流分享。');

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `comment_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `thread_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_comment_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `fk_comment_thread`(`thread_id` ASC) USING BTREE,
  INDEX `fk_comment_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_comment_parent`(`parent_comment_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `comments` (`comment_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_thread` FOREIGN KEY (`thread_id`) REFERENCES `threads` (`thread_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES ('09d26210-f93c-442f-903f-630c01232203', '9a87ee64-66a7-4218-bbeb-fabda7230105', '00000000-0000-0000-0000-000000000001', '4141fa17-20c9-4867-8d3a-b4f6644d5b63', '2443', '2025-06-02 20:06:40');
INSERT INTO `comments` VALUES ('0cd33d24-1277-46b7-b574-b5f519827055', '284fa70b-03df-48c0-8011-910205184f89', '00000000-0000-0000-0000-000000000001', NULL, '测试：插入', '2025-06-02 19:48:05');
INSERT INTO `comments` VALUES ('146f2629-6b01-4a34-8743-40d815a6aafd', 'b4dbc7ec-c364-4f22-a2b1-24269c300cb7', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', NULL, '好好', '2025-06-02 20:53:37');
INSERT INTO `comments` VALUES ('17ed161e-4ae6-49ce-a067-c3fda31114f2', 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '00000000-0000-0000-0000-000000000001', NULL, '1', '2025-06-02 15:38:58');
INSERT INTO `comments` VALUES ('1a1956c5-42a0-4151-9dda-74ff239ae3d6', 'b4dbc7ec-c364-4f22-a2b1-24269c300cb7', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', NULL, '1', '2025-06-02 20:53:29');
INSERT INTO `comments` VALUES ('4141fa17-20c9-4867-8d3a-b4f6644d5b63', '9a87ee64-66a7-4218-bbeb-fabda7230105', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', NULL, '1', '2025-06-02 18:58:15');
INSERT INTO `comments` VALUES ('7dccd79d-4838-4fdc-9cf9-5d82427f5f44', 'b4dbc7ec-c364-4f22-a2b1-24269c300cb7', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '1a1956c5-42a0-4151-9dda-74ff239ae3d6', '想来', '2025-06-02 20:53:33');
INSERT INTO `comments` VALUES ('8e1001cd-e3ac-4618-a2bf-dc754a03a332', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', 'eac97ab4-703c-41e4-9776-b5aa893deb25', '1', '2025-06-02 20:52:09');
INSERT INTO `comments` VALUES ('c1216ef8-489a-4887-ba4a-d0908d2db242', '284fa70b-03df-48c0-8011-910205184f89', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', NULL, '1', '2025-06-02 18:57:54');
INSERT INTO `comments` VALUES ('e4e02998-e0c3-4740-908c-ed1b8a9a6d1d', '9a87ee64-66a7-4218-bbeb-fabda7230105', '00000000-0000-0000-0000-000000000001', NULL, '24', '2025-06-02 20:06:41');
INSERT INTO `comments` VALUES ('e5075976-c3e7-486d-b86e-dc1f7b99cf15', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '8e1001cd-e3ac-4618-a2bf-dc754a03a332', '3', '2025-06-02 20:52:11');
INSERT INTO `comments` VALUES ('eac97ab4-703c-41e4-9776-b5aa893deb25', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', NULL, '如何', '2025-06-02 20:52:06');
INSERT INTO `comments` VALUES ('f837bf28-65e8-40e3-b88b-32f44e596c5e', '284fa70b-03df-48c0-8011-910205184f89', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '0cd33d24-1277-46b7-b574-b5f519827055', '回复', '2025-06-02 20:51:58');

-- ----------------------------
-- Table structure for levels
-- ----------------------------
DROP TABLE IF EXISTS `levels`;
CREATE TABLE `levels`  (
  `level_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_points` int NOT NULL,
  `max_points` int NOT NULL,
  `css_class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`level_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of levels
-- ----------------------------
INSERT INTO `levels` VALUES (1, '新手', 0, 9, 'level-novice');
INSERT INTO `levels` VALUES (2, '入门', 10, 49, 'level-beginner');
INSERT INTO `levels` VALUES (3, '熟手', 50, 199, 'level-intermediate');
INSERT INTO `levels` VALUES (4, '高手', 200, 499, 'level-advanced');
INSERT INTO `levels` VALUES (5, '大师', 500, 999, 'level-master');
INSERT INTO `levels` VALUES (6, '宗师', 1000, 999999, 'level-legend');

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages`  (
  `message_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `sender_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`) USING BTREE,
  INDEX `idx_conversation`(`sender_id` ASC, `receiver_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_receiver_unread`(`receiver_id` ASC, `is_read` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES ('0e768372-037a-4973-95f0-24021977d657', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2456543234565432', 0, '2025-06-02 15:12:02');
INSERT INTO `messages` VALUES ('19d28bf0-7bc0-4d5a-97db-71564a98440a', '00000000-0000-0000-0000-000000000001', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '好好好', 1, '2025-05-31 21:25:19');
INSERT INTO `messages` VALUES ('1fc67922-60f8-4fc5-9b57-c1265c577dd0', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '245664435454', 0, '2025-06-02 15:11:58');
INSERT INTO `messages` VALUES ('220c4dd3-b932-4107-9375-58710eb71d76', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '333', 0, '2025-06-02 15:11:50');
INSERT INTO `messages` VALUES ('36b4e40d-dfba-4435-9275-5f314a7f1db0', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '666', 0, '2025-06-02 15:11:48');
INSERT INTO `messages` VALUES ('3dcca3a0-ee3a-422b-b079-d48ed48812a2', 'e9a820dd-8ea8-4bb8-be49-4c9940321b64', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '你好呀！你的帖子真好', 1, '2025-06-02 17:39:52');
INSERT INTO `messages` VALUES ('50c0f52d-5e4a-40e3-95ad-ecfdf48379e5', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '444', 0, '2025-06-02 15:11:53');
INSERT INTO `messages` VALUES ('5d1fa05c-cbd2-49a6-b20c-91f4c982e50a', '00000000-0000-0000-0000-000000000001', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '12', 1, '2025-05-31 20:47:43');
INSERT INTO `messages` VALUES ('5d74886f-1fab-480d-8d67-f9db2c14006f', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '2914c475-702d-4896-b574-3126b79e5d69', '谢谢！', 0, '2025-06-02 17:58:11');
INSERT INTO `messages` VALUES ('62e3356b-0ade-420f-a5e9-de27d8c69541', 'a3c398d1-0b00-4ba8-9a28-916eb1d48ff5', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '交个朋友吧！', 1, '2025-06-02 17:41:55');
INSERT INTO `messages` VALUES ('a21ac5bd-7780-4f3f-8489-c974866e2917', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '543234565432', 0, '2025-06-02 15:12:08');
INSERT INTO `messages` VALUES ('b63a8e4d-010f-4839-ab63-c875e099f106', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '00000000-0000-0000-0000-000000000001', '你在说什么？', 1, '2025-05-31 20:48:02');
INSERT INTO `messages` VALUES ('bc1fcdfd-80e8-4fb4-9cfa-c6c3ff346d6d', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '222', 0, '2025-06-02 15:11:51');
INSERT INTO `messages` VALUES ('bd4427a2-3d40-4659-b20d-63e4c73af6eb', '2914c475-702d-4896-b574-3126b79e5d69', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '写的真好！', 1, '2025-06-02 17:41:36');
INSERT INTO `messages` VALUES ('e8bc781f-5a06-408b-964a-d56ede2e7e60', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '56753434554', 0, '2025-06-02 15:11:55');
INSERT INTO `messages` VALUES ('fe29bd23-de70-4ef0-b601-4f75d335ea6f', '00000000-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '56654323456543456', 0, '2025-06-02 15:12:05');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `notification_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thread_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('comment') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'comment',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`) USING BTREE,
  INDEX `idx_notif_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_notif_thread`(`thread_id` ASC) USING BTREE,
  INDEX `idx_notif_comment`(`comment_id` ASC) USING BTREE,
  CONSTRAINT `fk_notif_comment` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`comment_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_notif_thread` FOREIGN KEY (`thread_id`) REFERENCES `threads` (`thread_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES ('0a2a7372-3faa-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '9a87ee64-66a7-4218-bbeb-fabda7230105', '09d26210-f93c-442f-903f-630c01232203', 'comment', 0, '2025-06-02 20:06:39');
INSERT INTO `notifications` VALUES ('0a2a7db0-3faa-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '9a87ee64-66a7-4218-bbeb-fabda7230105', '09d26210-f93c-442f-903f-630c01232203', 'comment', 0, '2025-06-02 20:06:39');
INSERT INTO `notifications` VALUES ('5eb9dc08-3fb0-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '284fa70b-03df-48c0-8011-910205184f89', 'f837bf28-65e8-40e3-b88b-32f44e596c5e', 'comment', 0, '2025-06-02 20:51:58');
INSERT INTO `notifications` VALUES ('5eb9e5f2-3fb0-11f0-a584-3024a99540ab', '00000000-0000-0000-0000-000000000001', '284fa70b-03df-48c0-8011-910205184f89', 'f837bf28-65e8-40e3-b88b-32f44e596c5e', 'comment', 0, '2025-06-02 20:51:58');
INSERT INTO `notifications` VALUES ('5eb9eb0d-3fb0-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '284fa70b-03df-48c0-8011-910205184f89', 'f837bf28-65e8-40e3-b88b-32f44e596c5e', 'comment', 0, '2025-06-02 20:51:58');
INSERT INTO `notifications` VALUES ('5eb9ee9b-3fb0-11f0-a584-3024a99540ab', '00000000-0000-0000-0000-000000000001', '284fa70b-03df-48c0-8011-910205184f89', 'f837bf28-65e8-40e3-b88b-32f44e596c5e', 'comment', 0, '2025-06-02 20:51:58');
INSERT INTO `notifications` VALUES ('636bee72-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'eac97ab4-703c-41e4-9776-b5aa893deb25', 'comment', 0, '2025-06-02 20:52:06');
INSERT INTO `notifications` VALUES ('636bf636-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'eac97ab4-703c-41e4-9776-b5aa893deb25', 'comment', 0, '2025-06-02 20:52:06');
INSERT INTO `notifications` VALUES ('64ddded1-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '8e1001cd-e3ac-4618-a2bf-dc754a03a332', 'comment', 0, '2025-06-02 20:52:08');
INSERT INTO `notifications` VALUES ('64dde429-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '8e1001cd-e3ac-4618-a2bf-dc754a03a332', 'comment', 0, '2025-06-02 20:52:08');
INSERT INTO `notifications` VALUES ('6646f28f-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e5075976-c3e7-486d-b86e-dc1f7b99cf15', 'comment', 0, '2025-06-02 20:52:11');
INSERT INTO `notifications` VALUES ('6646f80f-3fb0-11f0-a584-3024a99540ab', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e5075976-c3e7-486d-b86e-dc1f7b99cf15', 'comment', 0, '2025-06-02 20:52:11');
INSERT INTO `notifications` VALUES ('71d0b999-3fa7-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '284fa70b-03df-48c0-8011-910205184f89', '0cd33d24-1277-46b7-b574-b5f519827055', 'comment', 0, '2025-06-02 19:48:05');
INSERT INTO `notifications` VALUES ('71d0be95-3fa7-11f0-a584-3024a99540ab', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '284fa70b-03df-48c0-8011-910205184f89', '0cd33d24-1277-46b7-b574-b5f519827055', 'comment', 0, '2025-06-02 19:48:05');
INSERT INTO `notifications` VALUES ('7bb6b4f2-3fa0-11f0-a584-3024a99540ab', '00000000-0000-0000-0000-000000000001', '9a87ee64-66a7-4218-bbeb-fabda7230105', '4141fa17-20c9-4867-8d3a-b4f6644d5b63', 'comment', 0, '2025-06-02 18:58:15');

-- ----------------------------
-- Table structure for thread_favorites
-- ----------------------------
DROP TABLE IF EXISTS `thread_favorites`;
CREATE TABLE `thread_favorites`  (
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thread_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `favorited_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `thread_id`) USING BTREE,
  INDEX `fk_fav_thread`(`thread_id` ASC) USING BTREE,
  CONSTRAINT `fk_fav_thread` FOREIGN KEY (`thread_id`) REFERENCES `threads` (`thread_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of thread_favorites
-- ----------------------------
INSERT INTO `thread_favorites` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', 'f441e582-a887-4590-a6f5-89b111f65e3e', '2025-06-02 20:51:41');

-- ----------------------------
-- Table structure for thread_likes
-- ----------------------------
DROP TABLE IF EXISTS `thread_likes`;
CREATE TABLE `thread_likes`  (
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thread_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `liked_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `thread_id`) USING BTREE,
  INDEX `fk_like_thread`(`thread_id` ASC) USING BTREE,
  CONSTRAINT `fk_like_thread` FOREIGN KEY (`thread_id`) REFERENCES `threads` (`thread_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of thread_likes
-- ----------------------------
INSERT INTO `thread_likes` VALUES ('00000000-0000-0000-0000-000000000001', '77777777-7777-7777-7777-777777777777', '2025-05-30 14:35:30');
INSERT INTO `thread_likes` VALUES ('11111111-1111-1111-1111-111111111111', '77777777-7777-7777-7777-777777777777', '2025-05-30 11:52:19');
INSERT INTO `thread_likes` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', 'f441e582-a887-4590-a6f5-89b111f65e3e', '2025-06-02 20:51:39');

-- ----------------------------
-- Table structure for threads
-- ----------------------------
DROP TABLE IF EXISTS `threads`;
CREATE TABLE `threads`  (
  `thread_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `board_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT NULL,
  `like_count` int UNSIGNED NOT NULL DEFAULT 0,
  `comment_count` int UNSIGNED NOT NULL DEFAULT 0,
  `status` enum('published','under_review','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'published',
  PRIMARY KEY (`thread_id`) USING BTREE,
  INDEX `fk_thread_author`(`author_id` ASC) USING BTREE,
  INDEX `idx_board_time`(`board_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_thread_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_thread_board` FOREIGN KEY (`board_id`) REFERENCES `boards` (`board_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of threads
-- ----------------------------
INSERT INTO `threads` VALUES ('284fa70b-03df-48c0-8011-910205184f89', 'e4ded9d4-e833-47b0-b16f-b2ffb6fbf37e', 'c7ffa768-3552-4918-9183-4c5cbf6643c4', '《认知觉醒》读书笔记1', '1', '2025-06-02 17:16:58', NULL, 0, 3, 'published');
INSERT INTO `threads` VALUES ('455a4325-2265-454a-bcff-e3168b992654', '9b8367e9-5895-4d10-8f36-42eb28967005', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '招人一起看球！', 'NBA比赛', '2025-06-02 20:53:02', NULL, 0, 0, 'published');
INSERT INTO `threads` VALUES ('77777777-7777-7777-7777-777777777777', '55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', '低成本健康饮食', '分享一些学生党也可以坚持的健康饮食方案～', '2025-05-30 11:52:19', NULL, 1, 0, 'published');
INSERT INTO `threads` VALUES ('9a87ee64-66a7-4218-bbeb-fabda7230105', '0442e24e-ade0-494a-833b-02e3c5327717', '00000000-0000-0000-0000-000000000001', '测试1', '哈哈哈哈', '2025-06-02 16:27:26', NULL, 0, 3, 'published');
INSERT INTO `threads` VALUES ('b4dbc7ec-c364-4f22-a2b1-24269c300cb7', '345025a5-aa03-43d1-b452-59072981ebeb', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '家教，有意向私信！', '11', '2025-06-02 20:53:24', NULL, 0, 3, 'published');
INSERT INTO `threads` VALUES ('bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '0442e24e-ade0-494a-833b-02e3c5327717', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Python 中如何优雅处理异常？', '大家好，请问 try/except 有什么最佳实践吗？', '2025-05-31 21:24:12', NULL, 0, 3, 'published');
INSERT INTO `threads` VALUES ('bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '1f857153-c027-4b06-929a-092d892e2395', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '如何应对考试焦虑？', '下周要考试了，感觉压力很大，大家有什么缓解方法吗？', '2025-05-31 21:24:12', NULL, 0, 1, 'published');
INSERT INTO `threads` VALUES ('bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2098d3e3-7837-431e-9a68-98c7eeda965a', 'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '《算法设计与分析》这门课怎么样？', '想了解这门课的作业量和授课风格，求推荐！', '2025-05-31 21:24:12', NULL, 0, 0, 'published');
INSERT INTO `threads` VALUES ('f441e582-a887-4590-a6f5-89b111f65e3e', '57dbb53f-7374-46c8-8dfa-1e3ecb199d7a', 'e422cd5a-67f4-4e57-a058-d4cd6222a879', '234人d', '个人', '2025-06-02 20:51:37', NULL, 1, 0, 'published');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `registered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_type` enum('guest','normal','member','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default.png',
  `points` int UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('00000000-0000-0000-0000-000000000001', 'admin', 'pbkdf2:sha256:1000000$Gmnfd7yd$c6e6fac6e8ebcbd7e425b99e43d87a71c255cecc10f8556381687ec725870a3a', 'admin@example.com', '2025-05-30 11:52:19', 'admin', 'default.png', 1);
INSERT INTO `users` VALUES ('11111111-1111-1111-1111-111111111111', 'alice', 'pbkdf2:sha256:1000000$bX1isaLj$fa397ef988dda77da1d9fb87774bd826c49c6c2dfe234ac4326b7ec63b76548c', 'alice@mail.com', '2025-05-30 11:52:19', 'normal', 'default.png', 120);
INSERT INTO `users` VALUES ('22222222-2222-2222-2222-222222222222', 'bob', 'pbkdf2:sha256:1000000$xdIWB76z$0bff45edfd49bb19ee016596fdb2e41e54936b0b8295d2c99b033b5faea92cb3', 'bob@mail.com', '2025-05-30 11:52:19', 'member', 'default.png', 450);
INSERT INTO `users` VALUES ('2914c475-702d-4896-b574-3126b79e5d69', '1234567', 'scrypt:32768:8:1$2UH1Yq6GZogOhIDc$abea05352e48753484ce88c664728725a9b462ea57fff3d69c6244c1c4d9fab33f039610027b339654437247dc4045ee4945349eff07776adc57131eef304abf', '1234567@qq.com', '2025-06-02 17:41:22', 'normal', 'default.png', 0);
INSERT INTO `users` VALUES ('33333333-3333-3333-3333-333333333333', 'guest1', 'pbkdf2:sha256:1000000$9oHGmq7U$12ae8c2413242ce7b193374dbbf899bcdb5d94aa59291753d57ba1d95b41dcc7', 'guest1@mail.com', '2025-05-30 11:52:19', 'guest', 'default.png', 0);
INSERT INTO `users` VALUES ('a3c398d1-0b00-4ba8-9a28-916eb1d48ff5', '123456', 'scrypt:32768:8:1$8PVks3RR86IAEtDt$ec52171e7a163657c5f3c768a4719e0ad9dc4d5f5fc08d9e2ca3780e463d9297b022ee66f8842ac9145440b4a846620621aa12dca3ddb5df0e71db62980abe60', '123456#qq.com', '2025-06-02 17:40:15', 'normal', 'default.png', 0);
INSERT INTO `users` VALUES ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'charlie', 'dummyhash1', 'charlie@example.com', '2025-05-31 21:24:12', 'normal', 'default.png', 0);
INSERT INTO `users` VALUES ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'diana', 'dummyhash2', 'diana@example.com', '2025-05-31 21:24:12', 'normal', 'default.png', 0);
INSERT INTO `users` VALUES ('aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'eric', 'dummyhash3', 'eric@example.com', '2025-05-31 21:24:12', 'member', 'default.png', 0);
INSERT INTO `users` VALUES ('c7ffa768-3552-4918-9183-4c5cbf6643c4', '123', 'scrypt:32768:8:1$2Jq0tVaOGZhP7ZQ6$14727d0f3ffce6a18f9e64ee310ece8d35ed3be7924eefa40601ee6c8b5ce2440b30ea0b1e3c86a2cdbda6074944ae616d92b8648f8598c06a86376878fba965', '123@qq.com', '2025-05-30 17:24:09', 'normal', 'c7ffa768-3552-4918-9183-4c5cbf6643c4.png', 5);
INSERT INTO `users` VALUES ('e422cd5a-67f4-4e57-a058-d4cd6222a879', '222', 'scrypt:32768:8:1$ZziECS9aYfaBoeUN$30f13ff6a0a45f76224d01e82df676ab912ea90b02838aa3196d6e65d210c1a6f2c60d23772ce5f5d8e431ef785c62f1a0004a3ffe046f3f2fa103f51ed220fb', '222@qq.com', '2025-06-02 20:41:20', 'normal', 'default.png', 4);
INSERT INTO `users` VALUES ('e9a820dd-8ea8-4bb8-be49-4c9940321b64', '1234', 'scrypt:32768:8:1$5TS6Bdd6lO9MIn9T$7153952b4737207a6988d1d7821dcdecf76739c3d3a62e1ee1822a951581eccd5b54458627ced334ce49ba1345adae424b6ae12cf0b8ce33bb4a8d6453b34ed6', '1234@qq.com', '2025-06-02 17:34:59', 'normal', 'default.png', 0);

-- ----------------------------
-- View structure for v_announcements
-- ----------------------------
DROP VIEW IF EXISTS `v_announcements`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_announcements` AS select `a`.`announcement_id` AS `announcement_id`,`a`.`title` AS `title`,`a`.`content` AS `content`,`a`.`author_id` AS `author_id`,`a`.`created_at` AS `created_at`,`a`.`is_pinned` AS `is_pinned`,`a`.`is_active` AS `is_active`,`u`.`username` AS `author_name` from (`announcements` `a` join `users` `u` on((`a`.`author_id` = `u`.`user_id`))) where (`a`.`is_active` = true) order by `a`.`is_pinned` desc,`a`.`created_at` desc;

-- ----------------------------
-- View structure for v_conversations
-- ----------------------------
DROP VIEW IF EXISTS `v_conversations`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_conversations` AS select (case when (`m`.`sender_id` < `m`.`receiver_id`) then concat(`m`.`sender_id`,':',`m`.`receiver_id`) else concat(`m`.`receiver_id`,':',`m`.`sender_id`) end) AS `conversation_id`,`m`.`sender_id` AS `sender_id`,`m`.`receiver_id` AS `receiver_id`,`m`.`content` AS `last_content`,`m`.`created_at` AS `last_message_time`,`m`.`is_read` AS `is_read`,`s`.`username` AS `sender_name`,`s`.`avatar` AS `sender_avatar`,`r`.`username` AS `receiver_name`,`r`.`avatar` AS `receiver_avatar` from ((`messages` `m` join `users` `s` on((`m`.`sender_id` = `s`.`user_id`))) join `users` `r` on((`m`.`receiver_id` = `r`.`user_id`))) where `m`.`message_id` in (select max(`m2`.`message_id`) from `messages` `m2` where (((`m2`.`sender_id` = `m`.`sender_id`) and (`m2`.`receiver_id` = `m`.`receiver_id`)) or ((`m2`.`sender_id` = `m`.`receiver_id`) and (`m2`.`receiver_id` = `m`.`sender_id`))) group by least(`m2`.`sender_id`,`m2`.`receiver_id`),greatest(`m2`.`sender_id`,`m2`.`receiver_id`));

-- ----------------------------
-- View structure for v_favorited_posts
-- ----------------------------
DROP VIEW IF EXISTS `v_favorited_posts`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_favorited_posts` AS select `tf`.`user_id` AS `user_id`,`t`.`thread_id` AS `thread_id`,`t`.`title` AS `title`,`t`.`created_at` AS `posted_at`,`tf`.`favorited_at` AS `favorited_at` from (`thread_favorites` `tf` join `threads` `t` on((`tf`.`thread_id` = `t`.`thread_id`)));

-- ----------------------------
-- View structure for v_liked_posts
-- ----------------------------
DROP VIEW IF EXISTS `v_liked_posts`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_liked_posts` AS select `tl`.`user_id` AS `user_id`,`t`.`thread_id` AS `thread_id`,`t`.`title` AS `title`,`t`.`created_at` AS `posted_at`,`tl`.`liked_at` AS `liked_at` from (`thread_likes` `tl` join `threads` `t` on((`tl`.`thread_id` = `t`.`thread_id`)));

-- ----------------------------
-- View structure for v_my_posts
-- ----------------------------
DROP VIEW IF EXISTS `v_my_posts`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_my_posts` AS select `threads`.`thread_id` AS `thread_id`,`threads`.`author_id` AS `author_id`,`threads`.`title` AS `title`,`threads`.`created_at` AS `created_at`,`threads`.`like_count` AS `like_count`,`threads`.`comment_count` AS `comment_count` from `threads`;

-- ----------------------------
-- View structure for v_user_info
-- ----------------------------
DROP VIEW IF EXISTS `v_user_info`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_user_info` AS select `u`.`user_id` AS `user_id`,`u`.`username` AS `username`,`u`.`email` AS `email`,`u`.`registered_at` AS `registered_at`,`u`.`user_type` AS `user_type`,`u`.`points` AS `points`,`u`.`avatar` AS `avatar` from `users` `u`;

-- ----------------------------
-- Procedure structure for delete_comment_sp
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_comment_sp`;
delimiter ;;
CREATE PROCEDURE `delete_comment_sp`(IN p_comment_id CHAR(36),
  IN p_user_id    CHAR(36))
BEGIN
  DECLARE v_cmt_user CHAR(36);
  DECLARE v_tid      CHAR(36);
  DECLARE v_user_type ENUM('guest','normal','member','admin');

  -- 查评论所属用户和对应的 thread_id
  SELECT user_id, thread_id
    INTO v_cmt_user, v_tid
    FROM comments
   WHERE comment_id = p_comment_id
   LIMIT 1;

  IF v_cmt_user IS NULL THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '评论不存在';
  ELSE
    -- 查调用者类型
    SELECT user_type
      INTO v_user_type
      FROM users
     WHERE user_id = p_user_id
     LIMIT 1;

    IF v_user_type IS NULL THEN
      SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '用户不存在';
    ELSEIF v_cmt_user <> p_user_id AND v_user_type <> 'admin' THEN
      -- 既不是作者，也不是管理员
      SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '无权删除此评论';
    ELSE
      -- 开始事务：删除评论及直接回复，更新帖子评论数
      START TRANSACTION;
        DELETE FROM comments
         WHERE comment_id = p_comment_id
            OR parent_comment_id = p_comment_id;

        UPDATE threads
           SET comment_count = (
             SELECT COUNT(*) 
               FROM comments 
              WHERE thread_id = v_tid
           )
         WHERE thread_id = v_tid;
      COMMIT;
    END IF;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for delete_thread_sp
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_thread_sp`;
delimiter ;;
CREATE PROCEDURE `delete_thread_sp`(IN p_thread_id CHAR(36),
  IN p_user_id   CHAR(36))
BEGIN
  DECLARE v_author    CHAR(36);
  DECLARE v_user_type ENUM('guest','normal','member','admin');

  -- 1) 查帖子作者
  SELECT author_id
    INTO v_author
    FROM threads
   WHERE thread_id = p_thread_id
   LIMIT 1;
  IF v_author IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='帖子不存在';
  END IF;

  -- 2) 查调用者类型
  SELECT user_type
    INTO v_user_type
    FROM users
   WHERE user_id = p_user_id
   LIMIT 1;
  IF v_user_type IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='用户不存在';
  END IF;

  -- 3) 权限校验：作者本人或管理员可删
  IF v_author <> p_user_id AND v_user_type <> 'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='无权删除此帖子';
  END IF;

  -- 4) 事务：删 favorites、likes、comments、thread
  START TRANSACTION;
    DELETE FROM thread_favorites WHERE thread_id = p_thread_id;
    DELETE FROM thread_likes     WHERE thread_id = p_thread_id;
    DELETE FROM comments         WHERE thread_id = p_thread_id;
    DELETE FROM threads          WHERE thread_id = p_thread_id;
  COMMIT;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for merge_boards_sp
-- ----------------------------
DROP PROCEDURE IF EXISTS `merge_boards_sp`;
delimiter ;;
CREATE PROCEDURE `merge_boards_sp`(IN p_src_bid   CHAR(36),
    IN p_dest_bid  CHAR(36),
    IN p_admin_uid CHAR(36))
BEGIN
  DECLARE v_type VARCHAR(10);

  -- 1) 权限校验
  SELECT user_type INTO v_type 
    FROM users 
   WHERE user_id = p_admin_uid;
  IF v_type<>'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='无权限合并板块';
  END IF;

  -- 2) 参数校验
  IF p_src_bid = p_dest_bid THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='源与目标板块相同';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM boards WHERE board_id = p_src_bid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='源板块不存在';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM boards WHERE board_id = p_dest_bid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='目标板块不存在';
  END IF;

  START TRANSACTION;
    -- 3) 多表 JOIN，一次更新 threads 和 board_follows
    UPDATE threads AS t
    JOIN board_follows AS bf
      ON t.board_id = bf.board_id
     AND bf.board_id = p_src_bid
    SET
      t.board_id  = p_dest_bid,
      bf.board_id = p_dest_bid
    WHERE t.board_id = p_src_bid;

    -- 4) 删除源板块
    DELETE FROM boards 
     WHERE board_id = p_src_bid;
  COMMIT;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sync_thread_comment_count
-- ----------------------------
DROP PROCEDURE IF EXISTS `sync_thread_comment_count`;
delimiter ;;
CREATE PROCEDURE `sync_thread_comment_count`()
BEGIN
  -- 将每个 thread 的 comment_count 设为 comments 表中对应 thread_id 的实际行数
  UPDATE threads AS t
  LEFT JOIN (
    SELECT thread_id, COUNT(*) AS cnt
    FROM comments
    GROUP BY thread_id
  ) AS c ON t.thread_id = c.thread_id
  SET t.comment_count = IFNULL(c.cnt, 0);
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table comments
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_before_insert_comment`;
delimiter ;;
CREATE TRIGGER `trg_before_insert_comment` BEFORE INSERT ON `comments` FOR EACH ROW BEGIN
  DECLARE v_thread_exists INT DEFAULT 0;
  DECLARE v_parent_exists INT DEFAULT 0;

  -- 1) 非空校验
  IF NEW.comment_id    IS NULL 
     OR NEW.thread_id  IS NULL 
     OR NEW.user_id    IS NULL 
     OR NEW.content    IS NULL THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '缺少必填字段';
  END IF;

  -- 2) 内容长度 1~500
  IF CHAR_LENGTH(TRIM(NEW.content)) = 0 THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '评论内容不能为空';
  ELSEIF CHAR_LENGTH(NEW.content) > 500 THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '评论长度不能超过500字';
  END IF;

  -- 3) 违禁词检测（示例）  
  IF LOWER(NEW.content) LIKE '%nmsl%' 
     OR LOWER(NEW.content) LIKE '%fuck%' THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '评论包含违禁词';
  END IF;

  -- 4) 帖子必须存在
  SELECT COUNT(*) INTO v_thread_exists
    FROM threads
   WHERE thread_id = NEW.thread_id;
  IF v_thread_exists = 0 THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = '帖子不存在，无法评论';
  END IF;

  -- 5) 如果是回复，父评论必须存在
  IF NEW.parent_comment_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_parent_exists
      FROM comments
     WHERE comment_id = NEW.parent_comment_id;
    IF v_parent_exists = 0 THEN
      SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '父评论不存在';
    END IF;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table comments
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_after_insert_comment_notification`;
delimiter ;;
CREATE TRIGGER `trg_after_insert_comment_notification` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
  DECLARE v_thread_author CHAR(36);
  DECLARE v_parent_user   CHAR(36);

  -- 取出帖子作者
  SELECT author_id INTO v_thread_author
    FROM threads
   WHERE thread_id = NEW.thread_id
   LIMIT 1;

  -- 通知帖子作者（评论者≠作者）
  IF NEW.user_id <> v_thread_author THEN
    INSERT INTO notifications
      (notification_id, user_id, type, comment_id, thread_id)
    VALUES(
      UUID(), 
      v_thread_author, 
      'comment',
      NEW.comment_id,     -- ← 改为 comment_id
      NEW.thread_id
    );
  END IF;

  -- 如果是回复，则通知父评论作者（去重）
  IF NEW.parent_comment_id IS NOT NULL THEN
    SELECT user_id INTO v_parent_user
      FROM comments
     WHERE comment_id = NEW.parent_comment_id
     LIMIT 1;

    IF v_parent_user IS NOT NULL
       AND v_parent_user <> NEW.user_id
       AND v_parent_user <> v_thread_author THEN
      INSERT INTO notifications
        (notification_id, user_id, type, comment_id, thread_id)
      VALUES(
        UUID(), 
        v_parent_user, 
        'comment',
        NEW.comment_id,   -- ← 同样改为 comment_id
        NEW.thread_id
      );
    END IF;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table comments
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_after_insert_comment`;
delimiter ;;
CREATE TRIGGER `trg_after_insert_comment` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
  DECLARE v_thread_author CHAR(36);
  DECLARE v_parent_user   CHAR(36);

  -- 1) 给帖主插入通知
  SELECT author_id INTO v_thread_author
    FROM threads
   WHERE thread_id = NEW.thread_id
   LIMIT 1;
  IF NEW.user_id <> v_thread_author THEN
    INSERT INTO notifications
      (notification_id, user_id, type, comment_id, thread_id)
    VALUES
      (UUID(), v_thread_author, 'comment',
       NEW.comment_id, NEW.thread_id);
  END IF;

  -- 2) 如果是回复，则给父评论作者再插入一条通知
  IF NEW.parent_comment_id IS NOT NULL THEN
    SELECT user_id INTO v_parent_user
      FROM comments 
     WHERE comment_id = NEW.parent_comment_id
     LIMIT 1;
    IF v_parent_user IS NOT NULL
       AND v_parent_user <> NEW.user_id
       AND v_parent_user <> v_thread_author THEN
      INSERT INTO notifications
        (notification_id, user_id, type, comment_id, thread_id)
      VALUES
        (UUID(), v_parent_user, 'comment',
         NEW.comment_id, NEW.thread_id);
    END IF;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table thread_likes
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_after_insert_like`;
delimiter ;;
CREATE TRIGGER `trg_after_insert_like` AFTER INSERT ON `thread_likes` FOR EACH ROW BEGIN
  UPDATE users SET points = points + 1
    WHERE user_id = NEW.user_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table threads
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_after_insert_thread`;
delimiter ;;
CREATE TRIGGER `trg_after_insert_thread` AFTER INSERT ON `threads` FOR EACH ROW BEGIN
  UPDATE users SET points = points + 1
    WHERE user_id = NEW.author_id;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
