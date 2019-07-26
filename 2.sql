create or replace trigger tri_checkdept
--新增、删除或更新部门信息（部门pk）字段时
  after update of pk_dept on hi_psnjob
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
	if updating then
	    SELECT code into vpkpin from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT name into vpkname from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT sex into vpsex from bd_psndoc where pk_psndoc = trim(:old.pk_psndoc);
		SELECT name into vpkdept from org_dept where pk_dept = trim(:new.pk_dept);
        select name into vpkorg from org_orgs where pk_org = trim(:new.pk_org);
	     AUDSTATUS := 'UPD';
         ISFINISH  := 'N';
		 flag := 'N';
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
			   flag);
		  commit;
	end if;
end;
