USE [Care365]
GO
/****** Object:  StoredProcedure [dbo].[CPN_GetGeneralDataByPracticeId]    Script Date: 8/2/2017 11:07:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Jagadeeshwar Mosali>

-- Create date: <10-14-2016>

-- Description:	<Get data for General tab under practice based on practiceID>

-- CPN_GetGeneralDataByPracticeId  'de654a70-8f01-4f4f-aa7d-49e3d6a6b904'

-- =============================================

CREATE PROCEDURE [dbo].[CPN_GetGeneralDataByPracticeId]

	@practiceId uniqueIdentifier

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



	-- Insering data into the table on very first time if there is no on boarding and scan doc information for perticular practice

if not exists (select top 1 null from practiceScanDocs where practiceId = @practiceId)
begin
insert into practiceScanDocs(scandocid, practiceId,practiceDocumentMasterId, uploadedFilePath,UploadedBy,UploadedDate,ModifiedDate, ModifiedBy,IsActive)
select newId(), @practiceId,practiceDocumentMasterId,'',createdby,null,null,'',0
from practicedocumentMaster
end


if not exists (select top 1 null from practiceOnboardingProcess where practiceId = @practiceId)
begin
insert into practiceOnboardingProcess (practiceOnBoardingProcessId, practiceId,ModifiedDate,ModifiedBy,CreatedBy,CreatedDate,IsActive,PracticeOnBoardingMasterId)
select newid(), @practiceId,getdate(),'',CreatedBy,CreatedDate,0,PracticeOnBoardingMasterId
from practiceOnBoardingMaster

end


	-- Get on boarding process data

select * into #temp2 from practiceOnBoardingProcess

where practiceId = @practiceId

select p.practiceOnBoardingMasterId, p1.IsActive, p1.PracticeId,p1.createdDate, p1.ModifiedBy,p1.ModifiedDate into #temp3 from PracticeOnBoardingMaster p

left join #temp2 p1 on p1.practiceOnBoardingMasterId = p.practiceOnBoardingMasterId


select a.PracticeId, 

isnull(a.IsActive,0) as IntroductionCall, a.CreatedDate as ICCreatedDate, a.ModifiedBy as ICModifiedBy,a.ModifiedDate as ICModifiedDate, IcId,

isnull(b.IsActive,0) PTANVerification, b.CreatedDate as PTCreatedDate, b.ModifiedBy as PTModifiedBy,b.ModifiedDate as PTModifiedDate,PtId,

isnull(c.IsActive,0) as IntroductionEmail, c.CreatedDate as IECreatedDate, c.ModifiedBy as IEModifiedBy,c.ModifiedDate as IEModifiedDate,IeId,

isnull(d.IsActive,0) as [followup], d.CreatedDate as FUCreatedDate, d.ModifiedBy as FUModifiedBy,d.ModifiedDate as FUModifiedDate,FuId,

isnull(e.IsActive,0) as [BillingCall], e.CreatedDate as BCCreatedDate, e.ModifiedBy as BCModifiedBy, e.ModifiedDate as BCModifiedDate,BcId

into #processData

from 

(select PracticeId,CreatedDate, ModifiedBy,ModifiedDate, PracticeOnBoardingMasterId as ICId, case when isactive is null then 0 else isactive end as isActive from #temp3 where PracticeOnBoardingMasterId = '03D935EA-0BFC-490C-B617-0559B49B0171')a 

left join

(select PracticeId,CreatedDate, ModifiedBy,ModifiedDate,PracticeOnBoardingMasterId as PtId, case when isactive is null then 0 else isactive end as isActive from #temp3 where PracticeOnBoardingMasterId = 'C4858678-509F-4009-AE9B-33C514692CFE')  b

 on a.practiceId = b.PracticeId

left join 

(select PracticeId,CreatedDate, ModifiedBy,ModifiedDate,PracticeOnBoardingMasterId as IeId, case when isactive is null then 0 else isactive end as isActive from #temp3 where PracticeOnBoardingMasterId = '3813DC0C-EB0F-43B9-AF90-966B73EE2274') c

on c.practiceId = a.PracticeId

left join 

(select PracticeId,CreatedDate, ModifiedBy,ModifiedDate,PracticeOnBoardingMasterId as FuId, case when isactive is null then 0 else isactive end as isActive from #temp3 where PracticeOnBoardingMasterId = 'A7BB3041-2C97-4019-8FD8-EA0EDABB1F52') d

on d.practiceId = a.PracticeId

left join 

(select PracticeId, CreatedDate, ModifiedBy,ModifiedDate,PracticeOnBoardingMasterId as BcId ,case when isactive is null then 0 else isactive end as isActive from #temp3 where PracticeOnBoardingMasterId = '2689D87E-A7EC-4825-962D-F65944055D75') e

on e.practiceId = a.PracticeId



-- Get practice document Data



select * into #temp5 from practiceScanDocs

where practiceId = @practiceId



select p.practiceDocumentMasterid, p1.IsActive, p1.PracticeId,p1.uploadedDate, p1.ModifiedBy into #temp6 from PracticeDocumentMaster p

left join #temp5 p1 on p1.practiceDocumentMasterid = p.practiceDocumentMasterid



select a.PracticeId,

 isnull(a.IsActive,0) as NonDisclosure, a.UploadedDate as NDCreatedDate,a.ModifiedBy as NDModifiedBy,NdId,

 isnull(b.IsActive,0) ServiceAgreement, b.UploadedDate as SACreatedDate, b.ModifiedBy as SAModifiedBy,SaId,

 isnull(c.IsActive,0) as BusinessAgreement, c.UploadedDate as BACreatedDate, c.ModifiedBy as BAModifiedBy,BaId

into #documentData

from 

(select PracticeId, UploadedDate, ModifiedBy ,practiceDocumentMasterId as NdId, case when isactive is null then 0 else isactive end as isActive from #temp6 where practiceDocumentMasterid = '120883EF-66FD-40AA-A1C2-3E28EBC1C30A')a 

left join

(select PracticeId, UploadedDate, ModifiedBy ,practiceDocumentMasterId as SaId,case when isactive is null then 0 else isactive end as isActive from #temp6 where practiceDocumentMasterid = '4A8B2B3B-E7B7-4783-8798-40BE577315A5')  b

on a.practiceId = b.PracticeId

left join 

(select PracticeId, UploadedDate, ModifiedBy ,practiceDocumentMasterId as BaId,case when isactive is null then 0 else isactive end as isActive from #temp6 where practiceDocumentMasterid = 'A20244B3-F1F2-45DF-BD03-851A5580F70C') c

on c.practiceId = a.PracticeId





-- get the final data based on the practice id



select  pr.practiceid, 

convert(bit, pd.IntroductionCall) IntroductionCall,convert(bit, pd.Ptanverification) as Ptanverification,

convert(bit, pd.IntroductionEmail) as IntroductionEmail, convert(bit, pd.FollowUp) FollowUp,convert(bit, pd.BillingCall) BillingCall,

convert(bit,dd.nondisclosure) nonDisclosure, convert(bit,dd.serviceAgreement) ServiceAgreement,convert(bit, dd.businessagreement) BusinessAgreement,

dd.NDModifiedBy, dd.SAModifiedBy,dd.BAmodifiedBy, dd.NDCreatedDate,dd.sacreateddate,dd.bacreateddate,
dd.NdId,dd.SaId,dd.Baid, pd.Icid,pd.ptid,pd.ieid,pd.bcid,pd.fuid,

pd.iccreateddate,pd.icmodifiedby,pd.ptcreateddate,pd.ptmodifiedby,pd.iecreateddate,pd.iemodifiedby,pd.fucreateddate,pd.fumodifiedby,pd.bccreateddate,pd.BCModifiedDate,pd.ICModifiedDate,pd.PTModifiedDate,pd.IEModifiedDate,pd.FUModifiedDate,pd.bcmodifiedby



from practices pr

inner join #processData pd on pd.PracticeId = pr.practiceId

inner join #documentData dd on dd.PracticeId = pr.practiceId



where pr.practiceId = @practiceId

    

END



GO
