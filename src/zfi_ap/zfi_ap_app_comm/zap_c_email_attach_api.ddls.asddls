@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachments'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_EMAIL_ATTACH_API
  as projection on ZAP_I_ATTACH
{
  key AttachmentUuid,
      ParentUuid,
      AttachmentType,
      FileName,
      FileExtension,
      FileSize,
      AwsS3FileArn,
      AwsS3Bucket,
      AwsS3ObjectKey,
      AwsS3SignedUrl,
      AwsS3SignedUrlExpiryDate,

      /* Associations */
      _Comm : redirected to parent ZAP_C_EMAIL_API
}
