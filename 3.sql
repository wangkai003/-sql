create or replace trigger tri_checktbm
--新增、删除或更新部门信息（部门pk）字段时
  after insert or delete or update of  pk_org,pk_psnjob,ts  on tbm_psndoc
  for each row
  declare
  --定义变量：更新标记
  AUDSTATUS varchar2(100);
  ISFINISH  varchar2(100);
  seal      number;
  flag      varchar2(100);
  vpkpin   varchar2(100);
  vpkname  varchar2(100);
  vpkorg   varchar2(100);
  vpkdept varchar2(100);
  vpsex   NUMBER(36);
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
   if inserting then
    AUDSTATUS := 'ADD';
    ISFINISH  := 'N';
    SELECT code into vpkpin from bd_psndoc where pk_psndoc = trim(:new.pk_psndoc);
		SELECT name into vpkname from bd_psndoc where pk_psndoc = trim(:new.pk_psndoc);
		SELECT sex into vpsex from bd_psndoc where pk_psndoc = trim(:new.pk_psndoc);
		SELECT name into vpkdept from org_dept where pk_dept = (select pk_dept from (SELECT * from hi_psnjob where dr=0 and ismainjob = 'Y' and lastflag='Y' and  pk_psnjob = trim(:new.pk_psnjob)  order by to_date(ts,'yyyy-mm-dd hh24:mi:ss')  desc) where rownum=1);
    select name into vpkorg from org_orgs where pk_org = trim(:new.pk_org);	
		insert into wljt_checkattendance
		  (dr,
		   pin,
		   name,
		   gender,
		   department,
		   company,
		   leavedate,
		   ts,
		   audstatus,
		   isfinish,
		   def3)
		  values
			(  0,
			   vpkpin,
			   vpkname,
			   vpsex,
			   vpkdept,
			   vpkorg,
			   trim(:new.ts),
			   TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'),
			   AUDSTATUS,
			   ISFINISH,
			   trim('Y'));
		  commit;
	end if;
	if deleting then
		AUDSTATUS := 'DEL';
		ISFINISH  := 'Y';
		SELECT code into vpkpin from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT name into vpkname from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT sex into vpsex from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT name into vpkdept from org_dept where pk_dept = (select pk_dept from (SELECT * from hi_psnjob where dr=0 and ismainjob = 'Y' and lastflag='Y' and  pk_psnjob = trim(:old.pk_psnjob)  order by to_date(ts,'yyyy-mm-dd hh24:mi:ss')  desc) where rownum=1);
    select name into vpkorg from org_orgs where pk_org = trim(:old.pk_org);
		insert into wljt_checkattendance
		  (dr,
		   pin,
		   name,
		   gender,
		   department,
		   company,
		   leavedate,
		   ts,
		   audstatus,
		   isfinish,
		   def3)
		  values
			(  0,
			   vpkpin,
			   vpkname,
			   vpsex,
			   vpkdept,
			   vpkorg,
			   trim(:old.ts),
			   TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss'),
			   AUDSTATUS,
			   ISFINISH,
			   trim('Y'));
		  commit;
	end if;
end;
