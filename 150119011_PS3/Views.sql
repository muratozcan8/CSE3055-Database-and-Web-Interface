Create View NotRentedServer
As 
Select s.ServiceTag, s.Model, s.CPU, s.RAM, s.Storage, s.Price, s.CabinID 
From Server s
Where s.CustomerID is null


--------------------------------------------------------------------------------


Create View NumberOfEmployeeInDepartments
As
Select d.DeptNo,d.DepartmentName,d.MgrSsn, count(*) NoOfEmployee
From Department d
	inner join Employee e on d.DeptNo=e.DeptNo
Group By d.DeptNo,d.DepartmentName, d.MgrSsn


-----------------------------------------------------------------------------------

Create View CabinNoOfEmptyRail
AS
Select * 
From 
    (Select c.CabinID,c.CabinType, c.Capacity-COUNT(*) as EmptyRails
    From Cabin c 
            left outer join Server s on c.CabinID=s.CabinID
    Group By c.CabinID,c.CabinType,c.Capacity) nt
Where nt.EmptyRails!=0
Order By nt.EmptyRails desc,nt.CabinID desc offset 0 rows

--------------------------------------------------------------------------------------

Create View ExpensiveServer
As
Select *
From Server s
Where s.Price > (Select avg(s.Price) From Server s )
Go

--------------------------------------------------------------------------------------

Create View TotalAmountCustomer
As
Select c.Ssn,c.FullName,sum(s.Price) as TotalAmountOfOrders
From Customer c inner join Orderr o on c.Ssn=o.CustomerID
     inner join Server s on o.CustomerID=s.CustomerID and o.OrderID=s.OrderID
Group by c.Ssn,c.FullName
Go


