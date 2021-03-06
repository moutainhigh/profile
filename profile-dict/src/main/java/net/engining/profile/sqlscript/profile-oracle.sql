
/* Drop Tables */

DROP TABLE PROFILE_BRANCH CASCADE CONSTRAINTS;
DROP TABLE PROFILE_MENU CASCADE CONSTRAINTS;
DROP TABLE PROFILE_MENU_INTERF CASCADE CONSTRAINTS;
DROP TABLE PROFILE_PWD_HIST CASCADE CONSTRAINTS;
DROP TABLE PROFILE_ROLE_AUTH CASCADE CONSTRAINTS;
DROP TABLE PROFILE_USER_ROLE CASCADE CONSTRAINTS;
DROP TABLE PROFILE_ROLE CASCADE CONSTRAINTS;
DROP TABLE PROFILE_SECOPER_LOG CASCADE CONSTRAINTS;
DROP TABLE PROFILE_USER CASCADE CONSTRAINTS;




/* Create Tables */

-- PROFILE_BRANCH
CREATE TABLE PROFILE_BRANCH
(
	-- 机构号
	ORG_ID VARCHAR2(12) NOT NULL,
	-- 分支编码
	BRANCH_ID VARCHAR2(9) NOT NULL,
	-- 上级分支
	SUPERIOR_ID VARCHAR2(9),
	-- 分支名
	BRANCH_NAME VARCHAR2(100) NOT NULL,
	-- 所属地区码
	ADDR_CODE VARCHAR2(100),
	-- 地址
	ADDRESS VARCHAR2(120),
	-- 区
	DISTRICT VARCHAR2(60),
	-- 城市
	CITY VARCHAR2(60),
	-- 联系电话1
	TELEPHONE1 VARCHAR2(40),
	-- 联系电话2
	TELEPHONE2 VARCHAR2(40),
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (ORG_ID, BRANCH_ID)
);


-- 菜单表
CREATE TABLE PROFILE_MENU
(
	-- ID
	ID NUMBER(10,0) NOT NULL,
	-- 机构号
	ORG_ID VARCHAR2(12),
	-- 应用代码 : 接入授权中心对应的client_id
	APP_CD VARCHAR2(50),
	-- 菜单代码 : 菜单代码,不同app下可以相同
	MENU_CD VARCHAR2(30) NOT NULL,
	-- 菜单名称
	MNAME VARCHAR2(100) NOT NULL,
	-- 菜单路径
	PATH_URL VARCHAR2(500) NOT NULL,
	-- 上级菜单ID : 0表示顶级菜单
	PARENT_ID NUMBER(10,0) DEFAULT 0 NOT NULL,
	-- 序号
	SORTN NUMBER(10,0) NOT NULL,
	-- 图标路径
	ICON VARCHAR2(255),
	-- 修改时间
	MTN_TIMESTAMP TIMESTAMP,
	-- 修改用户
	MTN_USER VARCHAR2(40),
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (ID),
	CONSTRAINT UNI_APP_MENU UNIQUE (APP_CD, MENU_CD)
);


-- 接口表
CREATE TABLE PROFILE_MENU_INTERF
(
	-- ID
	ID NUMBER(10,0) NOT NULL,
	-- 应用代码 : 接入授权中心对应的client_id
	APP_CD VARCHAR2(50),
	-- 接口代码 : 作为Auth的权限标识，以及前端的接口标识，不同app下可以相同
	INTERF_CD VARCHAR2(50) NOT NULL,
	-- 接口名称
	INAME VARCHAR2(100) NOT NULL,
	-- 菜单ID : 接口代码所属菜单ID
	MENU_ID NUMBER(10,0) NOT NULL,
	-- 修改时间
	MTN_TIMESTAMP TIMESTAMP,
	-- 修改用户
	MTN_USER VARCHAR2(40),
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (ID),
	CONSTRAINT UNI_APP_INTERF UNIQUE (APP_CD, INTERF_CD)
);


-- 密码维护历史表 : 记录每个用户的密码历史，以便判断密码重复。
CREATE TABLE PROFILE_PWD_HIST
(
	-- ID
	ID NUMBER(10,0) NOT NULL,
	-- PU_ID : ###uuid2###
	PU_ID VARCHAR2(64) NOT NULL,
	-- 密码
	PASSWORD VARCHAR2(300) NOT NULL,
	-- 密码建立时间
	PWD_CRE_TIME TIMESTAMP  NOT NULL,
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (ID)
);


-- 角色定义表
CREATE TABLE PROFILE_ROLE
(
	-- 角色ID
	ROLE_ID VARCHAR2(20) NOT NULL,
	-- 机构号
	ORG_ID VARCHAR2(12) NOT NULL,
	-- 应用代码 : 接入授权中心对应的client_id
	APP_CD VARCHAR2(50),
	-- 分支编码
	BRANCH_ID VARCHAR2(9) NOT NULL,
	-- 角色名
	ROLE_NAME VARCHAR2(200) NOT NULL,
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (ROLE_ID)
);


-- 权限表
CREATE TABLE PROFILE_ROLE_AUTH
(
	-- 角色ID
	ROLE_ID VARCHAR2(20) NOT NULL,
	-- 权限标识
	AUTHORITY VARCHAR2(100) NOT NULL,
	-- 权限URI
	AUTU_URI VARCHAR2(500) NOT NULL,
	PRIMARY KEY (ROLE_ID, AUTHORITY)
);


-- 用户安全操作日志
CREATE TABLE PROFILE_SECOPER_LOG
(
	-- 日志序号
	LOG_ID NUMBER(10,0) NOT NULL,
	-- PU_ID : ###uuid2###
	PU_ID VARCHAR2(64) NOT NULL,
	-- 被操作用户ID
	BEOPERATED_ID VARCHAR2(64),
	-- 操作业务类型 : ///
	-- @net.engining.profile.enums.OperationType
	OPER_TYPE VARCHAR2(2) NOT NULL,
	-- IP地址
	OPER_IP VARCHAR2(30) NOT NULL,
	-- 操作时间
	OPER_TIME TIMESTAMP  NOT NULL,
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (LOG_ID)
);


-- 用户信息表
CREATE TABLE PROFILE_USER
(
	-- PU_ID : ###uuid2###
	PU_ID VARCHAR2(64) NOT NULL,
	-- 机构号
	ORG_ID VARCHAR2(12) NOT NULL,
	-- 分支编码
	BRANCH_ID VARCHAR2(9),
	-- 登陆ID
	USER_ID VARCHAR2(40) NOT NULL UNIQUE,
	-- 姓名
	NAME VARCHAR2(40) NOT NULL,
	-- 密码
	PASSWORD VARCHAR2(300) NOT NULL,
	-- 状态 : ///
	-- N|新增
	-- A|活动
	-- L|锁定
	STATUS VARCHAR2(1) NOT NULL,
	-- EMAIL
	EMAIL VARCHAR2(128),
	-- 密码过期日期
	PWD_EXP_DATE DATE,
	-- 密码错误次数
	PWD_TRIES NUMBER(10,0) NOT NULL,
	-- 修改时间
	MTN_TIMESTAMP TIMESTAMP ,
	-- 修改用户
	MTN_USER VARCHAR2(40),
	-- 乐观锁版本号
	JPA_VERSION NUMBER(10,0) NOT NULL,
	PRIMARY KEY (PU_ID)
);


-- 用户角色表
CREATE TABLE PROFILE_USER_ROLE
(
	-- ID
	ID NUMBER(10,0) NOT NULL,
	-- 角色ID
	ROLE_ID VARCHAR2(20) NOT NULL,
	-- PU_ID : ###uuid2###
	PU_ID VARCHAR2(64) NOT NULL,
	PRIMARY KEY (ID)
);



/* Comments */

COMMENT ON TABLE PROFILE_BRANCH IS 'PROFILE_BRANCH';
COMMENT ON COLUMN PROFILE_BRANCH.ORG_ID IS '机构号';
COMMENT ON COLUMN PROFILE_BRANCH.BRANCH_ID IS '分支编码';
COMMENT ON COLUMN PROFILE_BRANCH.SUPERIOR_ID IS '上级分支';
COMMENT ON COLUMN PROFILE_BRANCH.BRANCH_NAME IS '分支名';
COMMENT ON COLUMN PROFILE_BRANCH.ADDR_CODE IS '所属地区码';
COMMENT ON COLUMN PROFILE_BRANCH.ADDRESS IS '地址';
COMMENT ON COLUMN PROFILE_BRANCH.DISTRICT IS '区';
COMMENT ON COLUMN PROFILE_BRANCH.CITY IS '城市';
COMMENT ON COLUMN PROFILE_BRANCH.TELEPHONE1 IS '联系电话1';
COMMENT ON COLUMN PROFILE_BRANCH.TELEPHONE2 IS '联系电话2';
COMMENT ON COLUMN PROFILE_BRANCH.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_MENU IS '菜单表';
COMMENT ON COLUMN PROFILE_MENU.ID IS 'ID';
COMMENT ON COLUMN PROFILE_MENU.ORG_ID IS '机构号';
COMMENT ON COLUMN PROFILE_MENU.APP_CD IS '应用代码 : 接入授权中心对应的client_id';
COMMENT ON COLUMN PROFILE_MENU.MENU_CD IS '菜单代码 : 菜单代码,不同app下可以相同';
COMMENT ON COLUMN PROFILE_MENU.MNAME IS '菜单名称';
COMMENT ON COLUMN PROFILE_MENU.PATH_URL IS '菜单路径';
COMMENT ON COLUMN PROFILE_MENU.PARENT_ID IS '上级菜单ID : 0表示顶级菜单';
COMMENT ON COLUMN PROFILE_MENU.SORTN IS '序号';
COMMENT ON COLUMN PROFILE_MENU.ICON IS '图标路径';
COMMENT ON COLUMN PROFILE_MENU.MTN_TIMESTAMP IS '修改时间';
COMMENT ON COLUMN PROFILE_MENU.MTN_USER IS '修改用户';
COMMENT ON COLUMN PROFILE_MENU.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_MENU_INTERF IS '接口表';
COMMENT ON COLUMN PROFILE_MENU_INTERF.ID IS 'ID';
COMMENT ON COLUMN PROFILE_MENU_INTERF.APP_CD IS '应用代码 : 接入授权中心对应的client_id';
COMMENT ON COLUMN PROFILE_MENU_INTERF.INTERF_CD IS '接口代码 : 作为Auth的权限标识，以及前端的接口标识，不同app下可以相同';
COMMENT ON COLUMN PROFILE_MENU_INTERF.INAME IS '接口名称';
COMMENT ON COLUMN PROFILE_MENU_INTERF.MENU_ID IS '菜单ID : 接口代码所属菜单ID';
COMMENT ON COLUMN PROFILE_MENU_INTERF.MTN_TIMESTAMP IS '修改时间';
COMMENT ON COLUMN PROFILE_MENU_INTERF.MTN_USER IS '修改用户';
COMMENT ON COLUMN PROFILE_MENU_INTERF.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_PWD_HIST IS '密码维护历史表 : 记录每个用户的密码历史，以便判断密码重复。';
COMMENT ON COLUMN PROFILE_PWD_HIST.ID IS 'ID';
COMMENT ON COLUMN PROFILE_PWD_HIST.PU_ID IS 'PU_ID : ###uuid2###';
COMMENT ON COLUMN PROFILE_PWD_HIST.PASSWORD IS '密码';
COMMENT ON COLUMN PROFILE_PWD_HIST.PWD_CRE_TIME IS '密码建立时间';
COMMENT ON COLUMN PROFILE_PWD_HIST.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_ROLE IS '角色定义表';
COMMENT ON COLUMN PROFILE_ROLE.ROLE_ID IS '角色ID';
COMMENT ON COLUMN PROFILE_ROLE.ORG_ID IS '机构号';
COMMENT ON COLUMN PROFILE_ROLE.APP_CD IS '应用代码 : 接入授权中心对应的client_id';
COMMENT ON COLUMN PROFILE_ROLE.BRANCH_ID IS '分支编码';
COMMENT ON COLUMN PROFILE_ROLE.ROLE_NAME IS '角色名';
COMMENT ON COLUMN PROFILE_ROLE.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_ROLE_AUTH IS '权限表';
COMMENT ON COLUMN PROFILE_ROLE_AUTH.ROLE_ID IS '角色ID';
COMMENT ON COLUMN PROFILE_ROLE_AUTH.AUTHORITY IS '权限标识';
COMMENT ON COLUMN PROFILE_ROLE_AUTH.AUTU_URI IS '权限URI';
COMMENT ON TABLE PROFILE_SECOPER_LOG IS '用户安全操作日志';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.LOG_ID IS '日志序号';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.PU_ID IS 'PU_ID : ###uuid2###';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.BEOPERATED_ID IS '被操作用户ID';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.OPER_TYPE IS '操作业务类型 : ///
@net.engining.profile.enums.OperationType';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.OPER_IP IS 'IP地址';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.OPER_TIME IS '操作时间';
COMMENT ON COLUMN PROFILE_SECOPER_LOG.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_USER IS '用户信息表';
COMMENT ON COLUMN PROFILE_USER.PU_ID IS 'PU_ID : ###uuid2###';
COMMENT ON COLUMN PROFILE_USER.ORG_ID IS '机构号';
COMMENT ON COLUMN PROFILE_USER.BRANCH_ID IS '分支编码';
COMMENT ON COLUMN PROFILE_USER.USER_ID IS '登陆ID';
COMMENT ON COLUMN PROFILE_USER.NAME IS '姓名';
COMMENT ON COLUMN PROFILE_USER.PASSWORD IS '密码';
COMMENT ON COLUMN PROFILE_USER.STATUS IS '状态 : ///
N|新增
A|活动
L|锁定';
COMMENT ON COLUMN PROFILE_USER.EMAIL IS 'EMAIL';
COMMENT ON COLUMN PROFILE_USER.PWD_EXP_DATE IS '密码过期日期';
COMMENT ON COLUMN PROFILE_USER.PWD_TRIES IS '密码错误次数';
COMMENT ON COLUMN PROFILE_USER.MTN_TIMESTAMP IS '修改时间';
COMMENT ON COLUMN PROFILE_USER.MTN_USER IS '修改用户';
COMMENT ON COLUMN PROFILE_USER.JPA_VERSION IS '乐观锁版本号';
COMMENT ON TABLE PROFILE_USER_ROLE IS '用户角色表';
COMMENT ON COLUMN PROFILE_USER_ROLE.ID IS 'ID';
COMMENT ON COLUMN PROFILE_USER_ROLE.ROLE_ID IS '角色ID';
COMMENT ON COLUMN PROFILE_USER_ROLE.PU_ID IS 'PU_ID : ###uuid2###';



