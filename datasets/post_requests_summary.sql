SELECT DATETRUNC(DAY, inserted_date) insert_date,
  vendor_code,
  vendor_campaign_name, 
  lead_status, 
  vici_post_status, 
  call_back_status,
  COUNT(DISTINCT post_request_id) requests
FROM dbo.post_request 
GROUP BY DATETRUNC(DAY, inserted_date),
  vendor_code,
  vendor_campaign_name, 
  lead_status, 
  vici_post_status, 
  call_back_status