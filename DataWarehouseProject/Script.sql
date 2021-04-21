-- Ahlam Hassen 103031281
-- Ben Gardiner 102151272

--create databsse DW1272
use DW1272

--errorevent tableC:\Users\ben_g\Source\Repos\DataWarehouse_1\DataWarehouseProject\Script.sql


DROP TABLE if exists ERROREVENT; 

GO

CREATE TABLE ERROREVENT (
ERRORID INTEGER,
SOURCE_ID NVARCHAR(50),
SOURCE_TABLE NVARCHAR(50),
FILTERID INTEGER,
DATETIME DATETIME,
ACTION NVARCHAR(50),
CONSTRAINT ERROREVENTACTION CHECK (ACTION IN ('SKIP','MODIFY'))
);

GO

DROP SEQUENCE IF EXISTS ERRORID_SEQ

GO

CREATE SEQUENCE ERRORID_SEQ
START WITH 1
INCREMENT BY 1;


-- DWDATE



GO

drop table IF EXISTS [DWSALE];
drop table IF EXISTS [DWPROD];
drop table IF EXISTS [DWCUST];

GO

 CREATE TABLE [dbo].[DWPROD] (
    [DWPRODID]         INT IDENTITY(1,1) NOT NULL,
	[DWSOURCETABLE]    NVARCHAR (100)    NOT NULL,
	[DWSOURCEID]       INT				 NOT NULL,
    PRODNAME           NVARCHAR (100)	 NULL,
    PRODCATNAME        NVARCHAR (100)	 NULL,
    PRODMANUNAME       NVARCHAR (30)	 NULL,
    PRODSHIPNAME	   NVARCHAR (30)	 NULL,
	CONSTRAINT [Pk_dwprodid] PRIMARY KEY CLUSTERED ([DWPRODID] ASC),
	
);
--(5001, 'PRODUCT', '10732', 'NAVEL BOOK PRO', 3, 'Samdanced', 'EXPRESS OVERNIGHT')


GO

 CREATE TABLE [dbo].[DWCUST] (
    [DWCUSTID]        INT IDENTITY(1,1) NOT NULL,
	[DWSOURCEIDBRIS]   INT			NULL, 
	[DWSOURCEIDMELB]   INT			NULL, 
    [FIRSTNAME]       NVARCHAR (30) NULL,
    [SURNAME]         NVARCHAR (30) NULL,
    [GENDER]          NVARCHAR (10) NULL,
    [PHONE]           NVARCHAR (20) NULL,
    [POSTCODE]		  INT			NULL,
    [CITY]			  NVARCHAR (50) NULL,
    [STATE]           NVARCHAR (10) NULL,
    [CUSTCATNAME]     NVARCHAR (30) NULL,
   CONSTRAINT [Pk_dwCust] PRIMARY KEY CLUSTERED ([DWCUSTID] ASC),
);

--(4001, 639, NULL, 'Ngan', 'Noah', 'F', 9173601430, 7773, 'Parramatta', 'NSW', 'GENERAL')



CREATE TABLE [dbo].[DWSALE] (
	[DWSALEID]		INT IDENTITY(1,1) NOT NULL,
	[DWCUSTID]		INT			    NOT NULL,
	[DWPRODID]		INT				NOT NULL,
	DWSOURCEIDBRIS	INT				NULL,
	DWSOURCEIDMELB	INT				NULL,
	QTY				INT				NULL,
	SALE_DWDATEID	INT				NULL,
	SHIP_DWDATEID	INT				NULL, 
	SALEPRICE		DECIMAL (7, 2)	NULL,
	CONSTRAINT [PK_dwSaleId] PRIMARY KEY CLUSTERED ([DWSALEID] ASC),
	CONSTRAINT [FK_dwCustId] foreign KEY([DWCUSTID]) references [DWCUST],
	CONSTRAINT [FK_dwProdId] foreign KEY([DWPRODID]) references [DWPROD],
	CONSTRAINT [FK_dwSaleDateId] foreign KEY(SALE_DWDATEID) references DWDATE(DateKey),
	CONSTRAINT [FK_dwShipDateId] foreign KEY(SHIP_DWDATEID) references DWDATE(DateKey),
);

--(2001, 4001, 5001, 639, NULL, 5, 1091, 1091, 1210.10)

GO

DROP TABLE IF EXISTS GENDERSPELLING;

GO

CREATE TABLE GENDERSPELLING (

INVALID_VALUE VARCHAR(30),

NEW_VALUE VARCHAR(1) CHECK(NEW_VALUE IN('F', 'M')),

PRIMARY KEY(INVALID_VALUE)

);

GO


INSERT INTO GENDERSPELLING(INVALID_VALUE, NEW_VALUE) VALUES
('MAIL', 'M'),
('WOMAN', 'F'),
('FEM', 'F'),
('FEMALE', 'F'),
('MALE', 'M'),
('GENTELMAN', 'M'),
('MM', 'M'), 
('FF', 'F'),
('FEMAIL', 'F');

GO

-- TASK 2.1
-- PRODUCT TRANSFER FILTER #1
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(nvarchar(50), prodid), 'PRODUCT', 1, (SELECT SYSDATETIME()), 'SKIP'
from TPS.dbo.Product
WHERE product.prodname is null

GO

-- TASK 2.2
-- filter #2
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(nvarchar(50), prodid), 'PRODUCT', 2, (SELECT SYSDATETIME()), 'MODIFY'
from TPS.dbo.PRODUCT
WHERE PRODUCT.MANUFACTURERCODE is NULL;

GO

--SELECT * FROM ERROREVENT;
--SELECT * FROM TPS.dbo.PRODUCT
--WHERE MANUFACTURERCODE IS NULL;

GO

-- TASK 2.3
-- filter #3
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Prodid), 'PRODUCT', 3, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.dbo.PRODUCT 
WHERE Prodcategory IS NULL OR Prodcategory NOT IN (SELECT Productcategory FROM TPS.dbo.PRODCATEGORY);

-- SELECT * FROM ERROREVENT WHERE FILTERID = 3;
-- SELECT * FROM TPS.dbo.PRODUCT 
-- WHERE Prodcategory IS NULL OR Prodcategory NOT IN (SELECT Productcategory FROM TPS.dbo.PRODCATEGORY);

--/

go

--CREATE VIEW PRODUCT_DETAIL_JOIN AS
--SELECT C.*, PC.CATEGORYNAME, M.Manuname, S.DESCRIPTION
--FROM DW1272.dbo.CLEAN_PRODUCT C 
--LEFT JOIN TPS.dbo.SHIPPING S
--ON C.Shippingcode = S.Shippingcode
--LEFT JOIN TPS.dbo.MANUFACTURER M
--ON C.Manufacturercode = M.Manucode
--LEFT JOIN TPS.dbo.Prodcategory PC
--ON C.Prodcategory = PC.Productcategory;

--CREATE VIEW ERROREVEN_#2_JOIN AS
--SELECT C.*, PC.CATEGORYNAME, M.Manuname, S.DESCRIPTION
--FROM (SELECT * FROM TPS.dbo.PRODUCT 
--WHERE Manufacturercode IS NULL) C 
--LEFT JOIN TPS.dbo.SHIPPING S
--ON C.Shippingcode = S.Shippingcode
--LEFT JOIN TPS.dbo.MANUFACTURER M
--ON C.Manufacturercode = M.Manucode
--LEFT JOIN TPS.dbo.Prodcategory PC
--ON C.Prodcategory = PC.Productcategory;

 --CREATE VIEW ERROREVEN_#3_JOIN AS
 --SELECT C.*, PC.CATEGORYNAME, M.Manuname, S.DESCRIPTION
 --FROM (SELECT * FROM TPS.dbo.PRODUCT 
 --WHERE Prodid IN (SELECT SOURCE_ID FROM DW1272.dbo.ERROREVENT WHERE FILTERID = 3)) C 
 --LEFT JOIN TPS.dbo.SHIPPING S
 --ON C.Shippingcode = S.Shippingcode
 --LEFT JOIN TPS.dbo.MANUFACTURER M
 --ON C.Manufacturercode = M.Manucode
 --LEFT JOIN TPS.dbo.Prodcategory PC
 --ON C.Prodcategory = PC.Productcategory;

-- DROP VIEW IF EXISTS ERROREVEN_#5_JOIN

--CREATE VIEW ERROREVEN_#5_JOIN AS
--SELECT C.*, CC.CUSTCATNAME
--FROM (SELECT * FROM TPS.dbo.CUSTBRIS
--WHERE Custid IN (SELECT SOURCE_ID FROM DW1272.dbo.ERROREVENT WHERE FILTERID = 5)) C 
--LEFT JOIN TPS.dbo.CUSTCATEGORY CC
--ON C.Custcatcode = CC.CUSTCATNAME


--CREATE VIEW CLEAN_CUSTBRIS AS
--SELECT * FROM TPS.dbo.CUSTBRIS 
--WHERE Custid NOT IN (SELECT CONVERT(INT, SOURCE_ID) FROM DW1272.dbo.ERROREVENT);

 --CREATE VIEW CUSTBRIS_JOIN AS
 --SELECT CBR.*, CC.CUSTCATNAME 
 --FROM DW1271.dbo.CLEAN_CUSTBRIS CBR
 --LEFT JOIN TPS.dbo.CUSTCATEGORY CC
 --ON CBR.Custcatcode = CC.Custcatcode;

--CREATE VIEW FILTER_#4 AS
--SELECT * FROM TPS.dbo.CUSTBRIS 
--WHERE Custid IN (SELECT CONVERT(INT, SOURCE_ID) FROM DW1272.dbo.ERROREVENT WHERE FILTERID = 4);

--CREATE VIEW FILTER_#5 AS
--SELECT * FROM TPS.dbo.CUSTBRIS 
--WHERE Custid IN (SELECT (CONVERT(INT, SOURCE_ID) FROM DW1272.dbo.ERROREVENT WHERE FILTERID = 5);


-- Task 2.4.3 (a)

INSERT INTO DWPROD(DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
SELECT 'PRODUCT', CONVERT(NVARCHAR(50), Prodid), Prodname, CATEGORYNAME, Manuname, [DESCRIPTION] FROM PRODUCT_DETAIL_JOIN;

GO
-- SELECT * FROM DWPROD;

--/

--Task 2.4.4 (b)

INSERT INTO DWPROD(DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
SELECT 'PRODUCT', CONVERT(NVARCHAR(50), Prodid), Prodname, CATEGORYNAME, 'UNKNOWN', [DESCRIPTION] FROM ERROREVEN_#2_JOIN;

GO
-- SELECT * FROM DWPROD WHERE PRODMANUNAME = 'UNKNOWN';

--/

-- Task 2.4.5 (C)

INSERT INTO DWPROD(DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
SELECT 'PRODUCT', CONVERT(NVARCHAR(50), Prodid), Prodname, 'UNKNOWN', Manuname, [DESCRIPTION] FROM ERROREVEN_#3_JOIN;

GO
 --SELECT * FROM DWPROD WHERE PRODCATNAME = 'UNKNOWN';

--/

-- Task 3.1
-- Filter #4 

-- **********I have added the IS NULL check althought it is not asked in 
-- the question as there is a row with null custcat value *************

--delete from ERROREVENT
--Where FILTERID = 4;

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Custid), 'CUSTBRIS', 4, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.dbo.CUSTBRIS 
WHERE Custcatcode IS NULL OR Custcatcode NOT IN (SELECT Custcatcode FROM TPS.dbo.CUSTCATEGORY);

GO
 --SELECT * FROM ERROREVENT WHERE FILTERID = 4;
-- SELECT * FROM TPS.dbo.CUSTBRIS 
-- WHERE Custcatcode IS NULL OR Custcatcode NOT IN (SELECT Custcatcode FROM TPS.dbo.CUSTCATEGORY);

--/

-- Task 3.2
-- Filter #5 

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Custid), 'CUSTBRIS', 5, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.dbo.CUSTBRIS
WHERE Phone LIKE '% %' OR Phone LIKE '%-%';

GO
 --SELECT * FROM ERROREVENT WHERE FILTERID = 5;
 --SELECT * FROM TPS.dbo.CUSTBRIS 
 --WHERE Phone LIKE '% %' OR Phone LIKE '%-%';

--/

-- Task 3.3
-- Filter #6 
 
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Custid), 'CUSTBRIS', 6, (SELECT SYSDATETIME()), 'SKIP'
FROM TPS.dbo.CUSTBRIS
WHERE Phone NOT IN (SELECT Phone FROM TPS.dbo.CUSTBRIS WHERE Phone LIKE '% %' OR Phone LIKE '%-%') AND
LEN(Phone) != 10;

GO
-- SELECT * FROM ERROREVENT WHERE FILTERID = 6;
-- SELECT * FROM TPS.dbo.CUSTBRIS 
-- WHERE Phone NOT IN (SELECT Phone FROM TPS.dbo.CUSTBRIS WHERE Phone LIKE '% %' OR Phone LIKE '%-%') AND
-- LEN(Phone) != 10;

--/

-- Task 3.4
-- Filter #7 

-- ************** IT DID NOT SPECIFY WHERE GENDER IS NULL I ADED THAT MY SELF ASK TIM ****************

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Custid), 'CUSTBRIS', 7, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.dbo.CUSTBRIS
WHERE Gender IS NULL OR UPPER(Gender) NOT IN ('M', 'F');

GO
-- SELECT * FROM ERROREVENT WHERE FILTERID = 7;
-- SELECT * FROM TPS.dbo.CUSTBRIS 
-- WHERE Gender IS NULL OR UPPER(Gender) NOT IN ('M', 'F');

--/

-- Task 3.5.1 

-- ****** are the dwsourceIdBris and melb corrosponding to that customer id in each table??? ******

INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
SELECT Custid, NULL, Fname, Sname,  UPPER(Gender), Phone, Postcode, City, [State], CUSTCATNAME
from DW1272.dbo.CUSTBRIS_JOIN;

gO
--SELECT * FROM DWCUST;

--/

-- Task 3.5.2

INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
SELECT Custid, NULL, Fname, Sname,  UPPER(Gender), Phone, Postcode, City, [State], 'UNKNOWN'
FROM DW1272.dbo.FILTER_#4;

GO
-- SELECT * FROM DWCUST WHERE CUSTCATNAME = 'UNKNOWN';
-- SELECT Custid, NULL, Fname, Sname,  UPPER(Gender), Phone, Postcode, City, [State], 'UNKNOWN'
-- FROM DW1272.dbo.FILTER_#4;

--/

--Task 3.5.3 
-- a) Write code to insert rows into the DWCUST table. 
-- Insert the rows from the table that are listed in the ERROREVENT table and have a filterid 
-- value =5. 
-- • In each case, remove all spaces or hyphens. 
-- • All GENDER values should be in uppercase. 

INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
SELECT Custid, NULL, Fname, Sname, UPPER(Gender), REPLACE(REPLACE(Phone, ' ', ''), '-', ''), Postcode, City, [State], (SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = F.Custcatcode)
FROM DW1272.dbo.FILTER_#5 F

--select * from
--FILTER_#5
--select * from
--ERROREVENT
--SELECT * FROM DWCUST

--/

--Task 3.5.4
--c) Write code to insert rows into the DWCUST table.
--Insert the rows from the CUSTBRIS table that are listed in the ERROREVENT table and have a filterid
--value =7. 

--where gender is in the spelling table
INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
SELECT Custid, NULL, Fname, Sname, 
	   upper((SELECT GS.NEW_VALUE FROM GENDERSPELLING GS WHERE gs.invalid_value = tcb.Gender)), Phone, Postcode, City, [State], 
	   (SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = TCB.Custcatcode)
FROM TPS.DBO.CUSTBRIS TCB
WHERE Custid IN (SELECT SOURCE_ID FROM ERROREVENT WHERE SOURCE_TABLE = 'CUSTBRIS' AND FILTERID = 7)
and TCB.Gender in (select gs2.invalid_value from GENDERSPELLING gs2)
--where spelling is not in the table or valu is null
UNION
SELECT Custid, NULL, Fname, Sname, 'U', Phone, Postcode, City, [State], 
		(SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = TCB.Custcatcode)
FROM TPS.DBO.CUSTBRIS TCB
WHERE Custid IN (SELECT SOURCE_ID FROM ERROREVENT WHERE SOURCE_TABLE = 'CUSTBRIS' AND FILTERID = 7)
and (TCB.Gender in (select gs2.invalid_value from GENDERSPELLING gs2) or TCB.Gender IS NULL)

--select * 
--from dwcust

--/

--Task 4.1
--a) Write code to MERGE rows into the DWCUST table. 

MERGE DWCUST DW
USING TPS.DBO.CUSTMELB CM 
ON CM.Fname = DW.FIRSTNAME
AND CM.Sname = DW.SURNAME
AND CM.Postcode = DW.POSTCODE
WHEN MATCHED THEN
UPDATE SET DW.DWSOURCEIDMELB = CM.CUSTID
WHEN NOT MATCHED THEN
INSERT (DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
values (NULL, Custid, Fname, Sname, upper(Gender), Phone, Postcode, City, [State], 
	   (SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = cm.Custcatcode));

--select *
--from DWCUST dc

----where the fname, surname and postcode matches
--INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
--Select NULL, Custid, Fname, Sname, upper(Gender), Phone, Postcode, City, [State], 
--	   (SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = cm.Custcatcode)
--from tps.dbo.custmelb cm
--where cm.Fname in (select dc.FIRSTNAME from DW1272.dbo.dwcust dc)
--and cm.Sname in (select dc.SURNAME from DW1272.dbo.dwcust dc)
--and cm.Postcode in (select dc.POSTCODE from DW1272.dbo.dwcust dc)

---- where NOT matches
--INSERT INTO DWCUST(DWSOURCEIDBRIS, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, [STATE], CUSTCATNAME)
--Select NULL, Custid, Fname, Sname, upper(Gender), Phone, Postcode, City, [State], 
--	   (SELECT TCC.CUSTCATNAME from tps.dbo.CUSTCATEGORY TCC where TCC.Custcatcode = cm.Custcatcode)
--from tps.dbo.custmelb cm
--where cm.Fname not in (select dc.FIRSTNAME from DW1272.dbo.dwcust dc)
--and cm.Sname not in (select dc.SURNAME from DW1272.dbo.dwcust dc)
--and cm.Postcode not in (select dc.POSTCODE from DW1272.dbo.dwcust dc)

--/

--Task 4.2
--Testing: You should execute the entire Script.sql file to ensure that all tasks can run without error. 

--/

--Task 5.1

--Filter #8
--a) Write code to insert a row into the ERROREVENT table for each row in the SALEBRIS table where
--PRODID does not match a DWPROD. DWSOURCEID. The action must be set to 'SKIP'
--b) Testing: You should test your code and ensure that ERROREVENT have been updated correctly

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEBRIS', 8, (SELECT SYSDATETIME()), 'SKIP'
FROM TPS.dbo.SALEBRIS SB
WHERE SB.prodid not in (SELECT DWSOURCEID from dbo.DWPROD DP where DP.DWSOURCEID = SB.Prodid)

--testing
--select *
--FROM TPS.dbo.SALEBRIS SB
--WHERE SB.prodid not in (SELECT DWSOURCEID from dbo.DWPROD DP where DP.DWSOURCEID = SB.Prodid)

--\

--Task 5.2
--Filter #9
--a) Write code to insert a row into the ERROREVENT table for each row in the SALEBRIS table where
--CUSTID does not match a DWCUST. DWSOURCEIDBRIS. The action must be set to 'SKIP' 

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEBRIS', 9, (SELECT SYSDATETIME()), 'SKIP'
FROM TPS.dbo.SALEBRIS SB
WHERE SB.custid not in (SELECT DWSOURCEIDBRIS from dbo.DWCUST DC where DC.DWSOURCEIDBRIS = SB.custid)

--testing

--select *
--FROM TPS.dbo.SALEBRIS SB
--WHERE SB.custid not in (SELECT DWSOURCEIDBRIS from dbo.DWCUST DC where DC.DWSOURCEIDBRIS = SB.custid)

--select * 
--from ERROREVENT ee
--where filterid = 9

--/

--Task 5.3
--Filter #10
--Task 3.5.5
--a) Write code to insert a row into the ERROREVENT table for each row in the SALEBRIS table where
--SHIPDATE is earlier than SALEDATE. The action must be set to 'MODIFY'
 
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEBRIS', 10, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.DBO.SALEBRIS SB
WHERE ((SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.SHIPDATE = DD.datevalue) < (SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue))

--select * 
--from ERROREVENT ee
--where filterid = 10

----testing
--select *
--FROM TPS.DBO.SALEBRIS SB
--WHERE ((SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.SHIPDATE = DD.datevalue) < (SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue))

--/

--Task 5.4
--Filter #11
--a) Write code to insert a row into the ERROREVENT table for each row in the SALEBRIS table where
--SALEPRICE is Null. The action must be set to 'MODIFY'
begin transaction
INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEBRIS', 11, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.DBO.SALEBRIS SB
WHERE SB.UNITPRICE IS NULL
commit transaction
GO
--SELECT *
--FROM TPS.DBO.SALEBRIS SB
--WHERE SB.UNITPRICE IS NULL

--select * 
--from ERROREVENT ee
--where filterid = 11

--/


--Task 5.5
--a) Write the code that inserts records from SALEBRIS into DWSALE into the script file. This code
--must ensure that: 
--• All rows not listed in the ERROREVENT table are uploaded to DWSALE
--• Each new sale added to the DWSALE table must be given unique DWSALEID value.
--The DWSALEID value must be obtained from a the appropriate sequence as created
--in Part 1
--• The DWSOURCEIDBRIS value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST
--table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD
--table
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate
--DWDATE.DATEKEY 


INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SB.CUSTID = DC.DWSOURCEIDBRIS), 
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SB.PRODID = DP.DWSOURCEID),
(SB.SALEID), 
NULL, 
SB.QTY, 
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue), 
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.SHIPDATE = DD.datevalue), 
SB.UNITPRICE
FROM TPS.DBO.SALEBRIS SB
WHERE SB.SALEID NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_ID = SB.SALEID)


----TESTING
--SELECT 
--(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SB.CUSTID = DC.DWSOURCEIDBRIS) AS DWCUSTID, 
--(SELECT DP.DWPRODID FROM DWPROD DP WHERE SB.PRODID = DP.DWSOURCEID) AS DWPRODID,
--(SB.SALEID), 
--NULL AS MELBSOUCEID, 
--SB.QTY, 
--(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue) AS SALEDATE, 
--(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.SHIPDATE = DD.datevalue) AS SHIPDATE, 
--SB.UNITPRICE
--FROM TPS.DBO.SALEBRIS SB
--WHERE SB.SALEID NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_ID = SB.SALEID)


----testing
--SELECT *
--FROM TPS.DBO.SALEBRIS SB
--WHERE SB.SALEID NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_ID = SB.SALEID)

----testing
--select *
--from DWCUST

--/

--Task 5.6
--a) Write the code that inserts records from SALEBRIS that are listed in ERROREVENT and have a
--filterid value =10 into DWSALE into the script file.
--This code must ensure that:
--• Each new sale added to the DWSALE table must be given unique DWSALEID value. The
--DWSALEID value must be obtained from a the appropriate sequence as created in Part 1
--• The DWSOURCEIDBRIS value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD table
--• MODIFY the SHIPDATE so that it equals the SALEDATE plus 2 days
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate 
--DWDATE.DATEKEY
--b) Testing: You should test your code and ensure that DWSALE have been updated correctly. 



INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
--AS DWCUSTID
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SB.CUSTID = DC.DWSOURCEIDBRIS),
--AS DWPRODID
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SB.PRODID = DP.DWSOURCEID),
(SB.SALEID), 
--AS MELBSOUCEID
NULL, 
SB.QTY, 
--AS SALEDATE
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue), 
--AS SHIPDATE
((SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue) + 2), 
SB.UNITPRICE
FROM TPS.DBO.SALEBRIS SB
WHERE SB.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEBRIS' AND FILTERID = 10)



----TESTING
--SELECT *
--FROM TPS.DBO.SALEBRIS SB
--WHERE SB.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEBRIS' AND FILTERID = 10)

--SELECT COUNT(*)
--FROM ERROREVENT 
--WHERE FILTERID = 10

--/

--Task 5.7
--a) Write the code that inserts records from SALEBRIS that are listed in ERROREVENT and have filterid
--value = 11 into DWSALE into the script file.
--This code must ensure that:
--• Each new sale added to the DWSALE table must be given unique DWSALEID value. The
--DWSALEID value must be obtained from a the appropriate sequence as created in Part 1
--• The DWSOURCEIDBRIS value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD table
--• MODIFY the SALEPRICE so that it equals the maximum sale price for that product in
--SALEBRIS
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate
--DWDATE.DATEKEY
--b) Testing: You should test your code and ensure that DWSALE table have been updated correctly.
--Task 5.8
--Testing: You should execute the entire Script.sql file to ensure that all tasks can run without error. 

INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
--AS DWCUSTID
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SB.CUSTID = DC.DWSOURCEIDBRIS and DC.DWSOURCEIDBRIS is not null),
--AS DWPRODID
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SB.PRODID = DP.DWSOURCEID and dp.DWSOURCEID is not null),
SB.SALEID, 
--AS MELBSOUCEID
NULL, 
SB.QTY, 
--AS SALEDATE
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.saledate = DD.datevalue),  
--AS SHIPDATE
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SB.SHIPDATE = DD.datevalue),  
--max unit price from the salebris table
(select max(unitprice) from TPS.dbo.salebris sb2 where sb2.prodid  = sb.Prodid )
FROM TPS.DBO.SALEBRIS SB
WHERE SB.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEBRIS' AND FILTERID = 11)


--select MAX(Unitprice) as unitprice, prodid
--from tps.dbo.SALEBRIS
--where Prodid = 10743 
--group by Prodid

--/

--Task 6.1
--Filter #12
--1. a) Write code to insert a row into the ERROREVENT table for each row in the SALEMELB
--table where PRODID does not match a DWPROD. DWSOURCEID. The action must be set to
--'SKIP'
--2. b) Testing: You should test your code and ensure that ERROREVENT have been updated
--correctly. 

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEMELB', 12, (SELECT SYSDATETIME()), 'SKIP'
FROM TPS.dbo.SALEMELB SM
WHERE SM.prodid not in (SELECT DWSOURCEID from dbo.DWPROD DP where DP.DWSOURCEID = SM.Prodid)


--testing
--select *
--FROM TPS.dbo.SALEMELB SM
--WHERE SM.prodid not in (SELECT DWSOURCEID from dbo.DWPROD DP where DP.DWSOURCEID = SM.Prodid)

--select * 
--from ERROREVENT ee
--where filterid = 12

--\


---Task 6.2
--Filter #13
--1. a) Write code to insert a row into the ERROREVENT table for each row in the SALEMELB
--table where CUSTID does not match a DWCUST. DWSOURCEIDMELB. The action must be set
--to 'SKIP'
--2. b) Testing: You should test your code and ensure that ERROREVENT have been updated
--correctly. 

INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEMELB', 13, (SELECT SYSDATETIME()), 'SKIP'
FROM TPS.dbo.SALEMELB SM
WHERE SM.custid not in (SELECT DC.DWSOURCEIDMELB from dbo.DWCUST DC where DC.DWSOURCEIDMELB = SM.custid)
OR SM.custid is null


--testing

--select *
--FROM TPS.dbo.SALEMELB SM
--WHERE SM.custid not in (SELECT DWSOURCEIDMELB from dbo.DWCUST DC where DC.DWSOURCEIDMELB = SM.custid) and sm.Custid is not null


--select * 
--from ERROREVENT ee
--where filterid = 13

--/

--Task 6.3
--Filter #14
--1. a) Write code to insert a row into the ERROREVENT table for each row in the SALEMELB
--table where SHIPDATE is earlier than SALEDATE. The action must be set to 'MODIFY'
--2. b) Testing: You should test your code and ensure that ERROREVENT have been updated
--correctly.


INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEMELB', 14, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.DBO.SALEMELB SM
WHERE ((SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.SHIPDATE = DD.datevalue) < (SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.saledate = DD.datevalue))


----TESTING
--SELECT *
--FROM ERROREVENT 
--WHERE FILTERID = 14



--/


--Task 6.4
--Filter #15
--1. a) Write code to insert a row into the ERROREVENT table for each row in the SALEMELB
--table where SALEPRICE is Null. The action must be set to 'MODIFY'
--2. b) Testing: You should test your code and ensure that ERROREVENT have been updated
--correctly. 


INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATETIME], [ACTION])
SELECT NEXT VALUE FOR ERRORID_SEQ, CONVERT(NVARCHAR(50), Saleid), 'SALEMELB', 15, (SELECT SYSDATETIME()), 'MODIFY'
FROM TPS.DBO.SALEMELB SM
WHERE SM.UNITPRICE IS NULL


----TESTING = 8
--SELECT *
--FROM TPS.DBO.SALEMELB SM
--WHERE SM.UNITPRICE IS NULL

--SELECT * = 8 
--FROM ERROREVENT
--WHERE FILTERID = 15

--/


--Task 6.5
--1. a) Write the code that inserts records from SALEMELB into DWSALE into the script file. This
--code must ensure that:
--• All rows not listed in the ERROREVENT table are uploaded to DWSALE
--• Each new sale added to the DWSALE table must be given unique DWSALEID value.
--The DWSALEID value must be obtained from a the appropriate sequence as created
--in Part 1
--• The DWSOURCEIDMELB value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST
--table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD
--table
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate
--DWDATE.DATEKEY
--2. b) Testing: You should test your code and ensure that DWSALE have been updated
--correctly. 

INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SM.CUSTID = DC.DWSOURCEIDMELB), 
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SM.PRODID = DP.DWSOURCEID),
NULL,
(SM.SALEID),  
SM.QTY, 
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.saledate = DD.datevalue), 
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.SHIPDATE = DD.datevalue), 
SM.UNITPRICE
FROM TPS.DBO.SALEMELB SM
WHERE SM.SALEID NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_ID = SM.SALEID)

----TESTING
--SELECT *
--FROM TPS.DBO.SALEMELB SM
--WHERE SM.SALEID NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_ID = SM.SALEID)





--Task 6.6
--a) Write the code that inserts records from SALEMELB that are listed in ERROREVENT and have a
--filterid value =14 into DWSALE into the script file.
--This code must ensure that:
--• Each new sale added to the DWSALE table must be given unique DWSALEID value. The
--DWSALEID value must be obtained from a the appropriate sequence as created in Part 1
--• The DWSOURCEIDMELB value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD table
--• MODIFY the SHIPDATE so that it equals the SALEDATE plus 2 days
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate
--DWDATE.DATEKEY
--b) Testing: You should test your code and ensure that DWSALE have been updated correctly.

INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
--AS DWCUSTID
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SM.CUSTID = DC.DWSOURCEIDMELB),
--AS DWPRODID
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SM.PRODID = DP.DWSOURCEID),
NULL,
--AS MELBSOUCEID
(SM.SALEID), 
SM.QTY, 
--AS SALEDATE
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.saledate = DD.datevalue), 
--AS SHIPDATE
((SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.saledate = DD.datevalue) + 2), 
SM.UNITPRICE
FROM TPS.DBO.SALEMELB SM
WHERE SM.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEMELB' AND FILTERID = 14)
AND SM.Saleid NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE='SALEMELB' GROUP BY EE.SOURCE_ID HAVING COUNT(*) > 1)



------TESTING
--SELECT *
--FROM TPS.DBO.SALEMELB SM
--WHERE SM.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEMELB' AND FILTERID = 14)

--SELECT *
--FROM TPS.DBO.SALEMELB SM
--where sm.Saleid in (10762, 
--10898)


--SELECT *
--FROM DWCUST
--where DWSOURCEIDMELB is NULL
--AND DWSOURCEIDBRIS IS NULL


--Task 6.7
--a) Write the code that inserts records from SALEMELB that are listed in ERROREVENT and have a
--filterid value =15 into DWSALE into the script file.
--This code must ensure that:
--• Each new sale added to the DWSALE table must be given unique DWSALEID value. The
--DWSALEID value must be obtained from a the appropriate sequence as created in Part 1
--• The DWSOURCEIDMELB value must be set to the SALEID of the source table
--• The DWCUSTID value must be set to the appropriate DWCUSTID of the DWCUST table
--• The DWPRODID value must be set to the appropriate DWPRODID of the DWPROD table
--• MODIFY the SALEPRICE so that it equals the maximum sale price for that product in
--SALEMELB
--• SALE_DWDATEID, SHIP_DWDATEID in DWSALE must be set to the appropriate
--DWDATE.DATEKEY
--b) Testing: You should test your code and ensure that DWSALE table have been updated correctly.
--Task 6.8
--Testing: You should execute the entire Script.sql file to ensure that all tasks can run without error. 

INSERT INTO DWSALE(DWCUSTID, DWPRODID, DWSOURCEIDBRIS, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
SELECT 
--AS DWCUSTID
(SELECT DC.DWCUSTID FROM DWCUST DC WHERE SM.CUSTID = DC.DWSOURCEIDMELB),
--AS DWPRODID
(SELECT DP.DWPRODID FROM DWPROD DP WHERE SM.PRODID = DP.DWSOURCEID),
NULL,
--AS MELBSOUCEID
(SM.SALEID), 
SM.QTY, 
--as saledate
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.saledate = DD.datevalue), 
--as shipdate
(SELECT dd.DATEKEY FROM dwDATE DD WHERE SM.SHIPDATE = DD.datevalue), 
--max unit price from the salebris table
(select max(unitprice) from TPS.dbo.salemelb sm2 where sm2.prodid  = sm.Prodid) 
FROM TPS.DBO.SALEMELB SM
WHERE SM.SALEID IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE = 'SALEMELB' AND FILTERID = 15)
AND SM.Saleid NOT IN (SELECT EE.SOURCE_ID FROM ERROREVENT EE WHERE EE.SOURCE_TABLE='SALEMELB' GROUP BY EE.SOURCE_ID HAVING COUNT(*) > 1)








--PART 7. Task 7.1
--a) Until now no source data row has failed multiple filters, however some rows in SALEMELB do. No
--row that fails multiple filters is to be present in the DWSALE table. Modify your script so that this
--does not happen.
--b) Testing: You should test your code and ensure that DWSALE table have been updated correctly. 


SELECT * FROM ERROREVENT WHERE SOURCE_ID IN
(
	SELECT EE.SOURCE_ID
	FROM ERROREVENT EE GROUP BY EE.SOURCE_ID HAVING COUNT(*) > 1 
);




--PART 8 QUERIES
--Write SQL queries based on your data warehouse to display the following information.
--Note: The values used to create these examples will not match current values in the database tables. 

--1 LIST EACH WEEKDAY AND THE TOTAL SALES (QTY * SALEPRICE) IN DESC TOTAL SEQ
--SELECT (SELECT dd.DayOfWeek FROM dwDATE DD) AS "WEEKDAY", (SELECT DWSALE.QTY * DWSALE.SALEPRICE) AS "TOTAL SALES" 
--FROM DWSALE
--GROUP BY "WEEKDAY", 'TOTAL SALES"
--ORDER BY [TOTAL SALES] DESC


SELECT distinct (dd.Dayname) 
FROM dwDATE DD

select (Select dw.QTY * dw.SALEPRICE), convert(NVARCHAR, (SELECT distinct (dd.Dayname) FROM dwDATE DD)) 
from dwsale dw
where dw.SALE_DWDATEID = (SELECT dd.DateKey FROM dwDATE DD WHERE dw.SALE_DWDATEID = DD.DateKey) 



(SELECT dd.DayOfWeek FROM dwDATE DD) AS "WEEKDAY"

--(SELECT DWSALE.QTY * DWSALE.SALEPRICE) AS "TOTAL SALES" 

FROM DWSALE
GROUP BY (SELECT dd.DayOfWeek FROM dwDATE DD)