Create Procedure GetEmployeesWithGenderAndSalary 
@Gender char(1)
as
	Select e.FullName, e.Salary
	From Employee e
	Where e.Gender=@Gender and e.Salary >= (Select avg(emp.Salary)
											From Employee emp)
	Order By e.Salary desc
exec GetEmployeesWithGenderAndSalary 'K'

------------------------------------------------------------------------------------
Create Procedure GetServersWithPropertiesAndPrice
@CPU nvarchar(50),
@RAM nvarchar(10),
@Storage int,
@Price int
as
	Select s.ServiceTag, s.CPU, s.RAM, s.Storage, s.Price
	From Server s
	Where s.ServiceTag in (Select nrs.ServiceTag
						   From NotRentedServer nrs)
		  and s.CPU = @CPU
		  and s.RAM = @RAM
		  and s.Storage = @Storage
		  and s.Price <= @Price
	Order By s.Price asc

exec GetServersWithPropertiesAndPrice 'INTEL i3', '64', 512, 15000

------------------------------------------------------------------------------------

Create Procedure GetRepresentetivesByNumbers
@number int,
@Gender char(1)
as
	Select e.FullName, count(*) NoOfCustomers
	From Employee e
		inner join Customer c on e.Ssn=c.RepresentativeID
	Where e.Gender = @Gender
	Group By e.FullName
	Having count(*) >= @number
	Order By count(*) desc

exec GetRepresentetivesByNumbers 3, 'K'

--------------------------------------------------------------------------------------

Create Procedure GetRetireYear
@Ssn int
as
declare
@Age int,
@limityear int = 55,
@fullName nvarchar(40)

Select @Age=Age, @fullName=FullName
From Employee
Where Ssn=@Ssn

if(@limityear <= @Age)
	print @fullName + ' can retire'
else 
	print @fullName + ' can not retire. Remaining years ' + convert(varchar, @limityear-@Age)

exec GetRetireYear 101
exec GetRetireYear 102
exec GetRetireYear 103
exec GetRetireYear 104


---------------------------------------------------------------------------------------------------

Create Procedure RentsServer
@Ssn int,
@ServiceTag nvarchar(10)
as
declare 
@orderID int,
@price int;

	Update Server Set CustomerID = @Ssn Where ServiceTag=@ServiceTag
	
	Insert Into Orderr(CustomerID) values(@Ssn);

	Select @orderID=OrderID From Orderr 

	Update Server Set OrderID = @orderID Where ServiceTag=@ServiceTag

exec RentsServer 519, 'MP2S69Y'

-----------------------------------------------------------------------------------------------

Create Procedure GetCityWithNoOfOrders(@City as nvarchar(20))
As
Begin
    Select a.City,Count(*) as noOfOrder
    From Customer c 
        inner join Orderr o on c.Ssn=o.CustomerID
        right outer join Address a on a.Ssn=c.Ssn
    Where a.City=@City
    Group By a.City
End

exec GetCityWithNoOfOrders 'Diyarbakýr'

---------------------------------------------------------------------------------------------------

Create Procedure GetCabinWithNoOfServers(@CabinID as int)
As
Begin
    Select c.CabinID,c.CabinType,COUNT(*) as noOfServer
    From Cabin c 
        left outer join Server s on c.CabinID=s.CabinID
    Where c.CabinID=@CabinID
    Group By c.CabinID,c.CabinType
End

exec GetCabinWithNoOfServers 2

--------------------------------------------------------------------------------------------------

CREATE PROCEDURE CheckCabinStatus(@CabinID as int)
AS
BEGIN
    DECLARE @noOfEmptyRails int;
    DECLARE @tempCabinID int;
    Select @tempCabinID=c.CabinID,@noOfEmptyRails=c.EmptyRails
    From CabinNoOfEmptyRail c
    Where c.CabinID=@CabinID

    IF @tempCabinID is not null
    BEGIN 
        PRINT 'There are '+ CAST(@noOfEmptyRails as nvarchar(10)) +' empty rails in cabin with CabinID '+ CAST(@tempCabinID as nvarchar(10))+'.'
    END
    ELSE
    BEGIN
        PRINT 'There are no empty rail in cabin with CabinID '+ CAST(@CabinID as nvarchar(10))+'.'
    END
END

exec CheckCabinStatus 12

--------------------------------------------------------------------------------------------------

Create Procedure totalAmount(
@FullName nvarchar(100),
@Ssn int
)
as
Begin
Select c.Ssn,c.FullName,sum(s.Price) as TotalAmountOfOrders
From Customer c inner join Orderr o on c.Ssn=o.CustomerID
     inner join Server s on o.CustomerID=s.CustomerID and o.OrderID=s.OrderID
Where @Ssn=o.CustomerID and @FullName=c.FullName
Group by c.Ssn,c.FullName

end;

exec totalAmount 'Tahir Eracar',504

--------------------------------------------------------------------------------------------------

Create Procedure totalAmountGivenDateRange(
@startDate date,
@endDate date
)
as
Begin

select sum(s.Price) as TotalAmountOfOrdersInGivenRange
From Customer c inner join Orderr o on c.Ssn=o.CustomerID
                inner join Server s on o.CustomerID=s.CustomerID and o.OrderID=s.OrderID,Bill b
Where @startDate<=b.Date and @endDate>=b.Date
end;

exec totalAmountGivenDateRange '2017-03-05','2021-11-15'

----------------------------------------------------------------------------------------------

Create Procedure customerInSameCabin(
@CabinID int
)
as
Begin
	Select c.Ssn,c.FullName,cbn.CabinID
	From Customer c 
		inner join Server s on c.Ssn=s.CustomerID 
		inner join Cabin cbn on s.CabinID=cbn.CabinID
	Where @CabinID=cbn.CabinID
End

exec customerInSameCabin 6

-------------------------------------------------------------------------

Create Procedure createCustomer
@Ssn int,
@FirstName nvarchar(40),
@LastName nvarchar(50),
@Gender char(1),
@Birthdate smalldatetime,
@PhoneNumber nvarchar(11),
@Mail nvarchar(100),
@UserPassword nvarchar(16)
As
	Insert Into Customer(Ssn, FirstName, LastName, Gender, BirthDate, PhoneNumber, Mail, UserPassword)
		values(@Ssn, @FirstName, @LastName, @Gender, @Birthdate, @PhoneNumber, @Mail, @UserPassword);

exec createCustomer '3000','Murat','Özcan','E','1968-12-19','05300068850','Phdsaddudsas@lobortis.cc','ZHAdS6DSA51'

-----------------------------------------------------------------------------------------------

Create Procedure CreateServer 
(@ServiceTag as nvarchar(10),
@Model as nvarchar(20),
@CPU as nvarchar(50),
@RAM as nvarchar(10),
@Storage as int,
@Price as int,
@CabinID as int)
As
Begin
    Insert Into Server(ServiceTag,Model,CPU,RAM,Storage,Price,CabinID) 
    Values (@ServiceTag,@Model,@CPU,@RAM,@Storage,@Price,@CabinID)
End

--------------------------------------------------------------------------------------------------
Create Procedure DeleteServer (@ServiceTag as nvarchar(10))
As
Begin
declare
@tempServiceTag nvarchar(10);

	Select @tempServiceTag=s.ServiceTag From Server s Where s.CustomerID is null and s.ServiceTag=@ServiceTag

	if @tempServiceTag is not null
	Begin
		Delete From Server Where ServiceTag=@ServiceTag 
	End
	else
	Begin
		print 'Server cannot be deleted because it has been hired.'
	End
End

exec CreateServer 'AA4S82Y', 'XR11', 'INTEL XEON E-2300', '128', 2048, 1670, 0 
exec CreateServer 'SY8L86E', 'T550', 'INTEL PENTIUM', '64', 8192, 8142, 12
exec DeleteServer 'SY8L86E'