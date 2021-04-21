--PART 8 QUERIES
--Write SQL queries based on your data warehouse to display the following information.
--Note: The values used to create these examples will not match current values in the database tables. 

-- LIST EACH WEEKDAY AND THE TOTAL SALES (QTY * SALEPRICE) IN DESC TOTAL SEQ


SELECT DD.DayName AS [WEEKDAY], SUM((DS.QTY) * DS.SALEPRICE) AS [TOTAL SALES]
FROM DWSALE DS
LEFT JOIN DWDATE DD
ON DS.SALEPRICE = DD.DATEKEY
WHERE DD.DayName IS NOT NULL
GROUP BY DD.DayName
ORDER BY [TOTAL SALES]
