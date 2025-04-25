SELECT TOP 1000 
    l.inserted_date 'Inserted Date',
    l.updated_date 'Updated Date',
    l.id 'ID',
    l.request_id 'Request ID',
    l.[LIST NAME] [List Name],
    l.[LIST RECORD ID] [List Record ID],
    l.CAMPAIGN 'Campaign',
    l.TIMESTAMP 'Timestamp',
    l.STATUS 'Status',
    l.[LAST ATTEMPT CALL ID] [Last Attempt Call ID],
    l.[LAST ATTEMPT PHONE NUMBER] [Last Attempt Phone Number],
    l.[LAST CALL TIMESTAMP] [Last Call Timestamp],
    l.[LAST DISPOSITION] [Last Disposition],
    l.[LAST AGENT] [Last Agent],
    l.[AGENT NAME] [Agent Name],
    l.[DIAL ATTEMPTS] [Dial Attempts],
    l.[FINAL DISPOSITION] [Final Disposition],
    l.[CONTACT ID] 'Contact ID',
    l.[number1 DIAL ATTEMPTS] [Number1 Dial Attempts],
    l.[number1 MAX DIAL ATTEMPTS REACHED] [Number1 Max Dial Attempts Reached],
    l.[number1 LAST CALL TIMESTAMP] [Number1 Last Call Timestamp],
    l.[number1 LAST DISPOSITION] [Number1 Last Disposition],
    l.[number2 DIAL ATTEMPTS] [Number2 Dial Attempts],
    l.[number2 MAX DIAL ATTEMPTS REACHED] [Number2 Max Dial Attempts Reached],
    l.[number2 LAST DISPOSITION] [Number2 Last Disposition],
    l.[number3 DIAL ATTEMPTS] [Number3 Dial Attempts],
    l.[number3 MAX DIAL ATTEMPTS REACHED] [Number3 Max Dial Attempts Reached],
    l.[number3 LAST CALL TIMESTAMP] [Number3 Last Call Timestamp],
    l.[number3 LAST DISPOSITION] [Number3 Last Disposition],
    l.[ASAP FLAG] [ASAP Flag],
    CASE cd.[CONTACT_IN_DNC] 
        WHEN 1 THEN 'Yes'
        ELSE 'No'
    END [Contact in DNC]
FROM five9.GetListDetailsReport l
JOIN five9.GetContactDetailsReport cd
  ON cd.[CONTACT_ID] = l.[CONTACT ID]