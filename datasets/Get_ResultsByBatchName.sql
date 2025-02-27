SELECT * 
FROM OpenQuery(self_ref_for_superset, 
    'EXECUTE ndw.dbo.Get_ResultsByBatchName
        WITH RESULT SETS((
            file_name varchar(255), 
            batch_name varchar(255), 
            load_status varchar(255), 
            request_id varchar(255), 
            cnt int, 
            inserted_date date, 
            error_message varchar(255)))'
);