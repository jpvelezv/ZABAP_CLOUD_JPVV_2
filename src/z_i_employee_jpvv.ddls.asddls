@AbapCatalog.sqlViewName: 'ZV_EMPL_JPVV'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'HCM - Master'
define root view Z_I_EMPLOYEE_JPVV
  as select from zemployee_jpvv as Employee
{
      //HCMMaster
  key e_number,
      e_name,
      e_department,
      status,
      job_title,
      start_date,
      end_date,
      email,
      m_number,
      m_name,
      m_department,
      crea_date_time,
      crea_uname,
      lchg_date_time,
      lchg_uname
}
