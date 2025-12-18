@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachments Inferface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_B_ATTACH
  as select from zap_a_attach

{
  key attachment_uuid               as AttachmentUuid,
      parent_uuid                   as ParentUuid,
      attachment_id                 as AttachmentId,
      attachment_type               as AttachmentType,
      file_name                     as FileName,
      file_extension                as FileExtension,
      file_size                     as FileSize,
      aws_s3_file_arn               as AwsS3FileArn,
      aws_s3_bucket                 as AwsS3Bucket,
      aws_s3_object_key             as AwsS3ObjectKey,
      aws_s3_signed_url             as AwsS3SignedUrl,
      aws_s3_signed_url_expiry_date as AwsS3SignedUrlExpiryDate,
      local_created_by              as LocalCreatedBy,
      local_created_at              as LocalCreatedAt,
      local_last_changed_by         as LocalLastChangedBy,
      local_last_changed_at         as LocalLastChangedAt,
      last_changed_at               as LastChangedAt
}
