Create Table Employee(
	Ssn int primary key identity(1,1),
	FirstName nvarchar(40),
	LastName nvarchar(50),
	FullName as FirstName + ' ' + LastName,
	Gender char(1),
	Birthdate smalldatetime,
	Age as (year(CURRENT_TIMESTAMP) - year(Birthdate)),
	PhoneNumber varchar(11) unique,
	Mail nvarchar(100) unique,
	Salary int default 8500,
	DeptNo int,
	SuperSsn int,
	Foreign Key (SuperSsn) references Employee(Ssn),
);

Create Index EmployeeIndex on Employee(SuperSsn)

Create Table Department(
	DeptNo int primary key identity(101,100),
	DepartmentName nvarchar(40),
	MgrSsn int
	Foreign Key (MgrSsn) references Employee(Ssn)
);

Create Index DepartmentIndex on Department(MgrSsn)
Alter Table Employee Add Foreign Key (DeptNo) references Department(DeptNo)

Create Table Customer(
	Ssn int primary key,
	FirstName nvarchar(40),
	LastName nvarchar(40),
	FullName as FirstName + ' ' + LastName,
	Gender char(1),
	BirthDate smalldatetime,
	Age as (year(CURRENT_TIMESTAMP) - year(Birthdate)),
	PhoneNumber varchar(11) unique,
	Mail nvarchar(100) unique,
	UserID int unique identity(1001,1),
	UserPassword nvarchar(16),
	RepresentativeID int,
	Foreign Key (RepresentativeID) references Employee(Ssn),
	Constraint Check_UserPassword check (Len(UserPassword) >= 8)
);

Create Index CustomerIndex on Customer(Ssn)

Create Index CustomerRepIndex on Customer(RepresentativeID)

Create Table Address(
	Ssn int,
	District nvarchar(20),
	City nvarchar(20),
	ZipCode nvarchar(5),
	Address as District + '/' + City + ',' + ZipCode
);

Create Table Orderr(
	OrderID int primary key identity(1,1),
	CustomerID int,
	Foreign Key (CustomerID) references Customer(Ssn)
);

Create Index OrderIndex on Orderr(CustomerID)


Create Table Cabin(
	CabinID int primary key,
	Capacity int,
	CabinType nvarchar(10) default 'Quarter'
);

Create Table NetworkSwitch(
	SwitchID int primary key,
	CabinID int,
	EthernetPort int identity(0,1),
	IdracPortNo int,
	Foreign Key (CabinID) references Cabin(CabinID)
);

Create Index NetworkIndex on NetworkSwitch(CabinID)

Create Table Server(
	ServiceTag nvarchar(10) primary key,
	Model nvarchar(20),
	CPU nvarchar(50),
	RAM nvarchar(10),
	Storage int,
	Price int,
	CustomerID int,
	CabinID int,
	OrderID int,
	Foreign Key (CustomerID) references Customer(Ssn),
	Foreign Key (CabinID) references Cabin(CabinID),
	Foreign Key (OrderID) references Orderr(OrderID),
	Constraint Check_Storage check (Storage >= 128)
);

Create Index ServerCustIndex on Server(CustomerID)
Create Index ServerCabinIndex on Server(CabinID)
Create Index ServerOrdIndex on Server(OrderID)

Create Table Bill(
	BillID int primary key,
	OrderID int,
	Amount int,
	Date smalldatetime,
	Foreign Key (OrderID) references Orderr(OrderID),
);

Update Bill Set Amount = s.Price From Server s Where Bill.OrderID=s.OrderID

Create Index BillIndex on Bill(OrderID)

