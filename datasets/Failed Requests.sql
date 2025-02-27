select updated_date, request_status, request_type, request_id, sum(count) count
from five9.vw_five9UpsertReportDaily
group by updated_date, request_status, request_type, request_id