Create Trigger insert_Representetive on Customer
After Insert As
Begin
	declare 
	@empID int

	Select @empID=e.Ssn
	From Employee e
	Where e.Ssn in (Select e.Ssn
				 From Employee e 
					inner join Customer c on e.Ssn=c.RepresentativeID
				 Group By e.Ssn
				 Having count(*) < 5)
		
	Update Customer Set RepresentativeID = @empID Where RepresentativeID is null
End



INSERT INTO Customer (Ssn, FirstName, LastName, Gender, BirthDate, Mail, PhoneNumber, UserPassword) 
	VALUES ('3000','Murat','Özcan','E','1968-12-19','Phdsaddudsas@lobortis.cc','05300068850','ZHAdS6DSA51');

INSERT INTO Customer (Ssn, FirstName, LastName, Gender, BirthDate, Mail, PhoneNumber, UserPassword) 
	VALUES ('3001','Berkkan','Rençber','E','1968-12-19','Phudasddsas@lobortis.cc','05311168850','AHAdS6DSA51');

INSERT INTO Customer (Ssn, FirstName, LastName, Gender, BirthDate, Mail, PhoneNumber, UserPassword) 
	VALUES ('3002','Faruk','Akdemir','E','1968-12-19','Phuasddsadas@lobortis.cc','05322268850','BHAdS6DSA51');
-------------------------------------------------------------------------------------------------------------------------------------------


Create Trigger insert_Bill
ON Orderr
After Insert
As
Begin
    declare @lastBillID int;
    declare @totalAmount int;
    declare @lastOrderID int;

    Select @lastBillID=MAX(BillID)
    From Bill

    Select @lastOrderID=i.OrderID,@totalAmount=sum(s.Price)
    From inserted i 
		inner join Server s on i.CustomerID=s.CustomerID
    Group By i.OrderID

    Insert Into Bill(BillID,OrderID,Amount,Date) VALUES (@lastBillID+10,@lastOrderID,@totalAmount,GETDATE()) 
End


--------------------------------------------------------------------
