*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
types: ty_ocr_head    type zap_a_ocr_head,
       ty_tt_ocr_items type standard table of zap_a_ocr_item,
       ty_tt_ocr_log  type standard table of zap_a_ocr_log.

*For now use the OCR tables
types: ty_parking_head     type zap_a_ocr_head,
       ty_tt_parking_items type standard table of zap_a_ocr_item,
       ty_tt_parking_logs  type standard table of zap_a_ocr_log.
