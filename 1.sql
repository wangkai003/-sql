create or replace trigger tri_checkattendance
--新增、删除或更新人员信息（人员信息PK、人员编号、人员姓名、人员性别、人员部门、人员公司、离职日期）字段时
  after insert or delete or update of code, name, sex, pk_org, pk_group, dr, enablestate on bd_psndoc
  for each row
declare
  --定义变量：更新标记
  AUDSTATUS varchar2(100);
  ISFINISH  varchar2(100);
  seal      number;
  flag      varchar2(100);
  vpkorg   varchar2(100);
  vpkdept varchar2(100);
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  if deleting then
    AUDSTATUS := 'DEL';
    ISFINISH  := 'Y';
	SELECT name into vpkdept from org_dept where pk_dept = (SELECT pk_dept from HI_PSNJOB where dr=0 and ismainjob = 'Y' and lastflag='Y' and  pk_psndoc = trim(:old.pk_psndoc));
  select name into vpkorg from org_orgs where pk_org = trim(:old.pk_org);
    --同步删除数据到中间表
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
      (0,
       trim(:old.code),
       trim(:old.name),
       :old.sex,
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
