@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comm Attachments Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_COMM_ATTACH_UI
  as projection on ZAP_I_ATTACH

{
  key AttachmentUuid,
      ParentUuid,
      AttachmentType,
      @UI.identification: [{
        position: 30,
        label:    'Filename',
        type:     #WITH_URL,
        url:      'AwsS3SignedUrl'
      }]
      @UI.lineItem: [{
        position: 30,
        label:    'Filename',
        type:     #WITH_URL,
        url:      'AwsS3SignedUrl'
      }]
      FileName,
      FileExtension,
      FileSize,
      AwsS3FileArn,
      AwsS3Bucket,
      AwsS3ObjectKey,
      AwsS3SignedUrl,
      AwsS3SignedUrlExpiryDate,
      @ObjectModel.text.element: [ 'LocalCreatedByUserName' ]
      LocalCreatedBy,
      LocalCreatedAt,
      @ObjectModel.text.element: [ 'LocalLastChangedByUserName' ]
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Technical */
      @UI.hidden: true
      _CreatedUser.UserDescription as LocalCreatedByUserName,
      @UI.hidden: true
      _ChangedUser.UserDescription as LocalLastChangedByUserName,

      /* Associations */
      _Comm : redirected to parent ZAP_C_COMM_UI
}
