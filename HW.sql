-- Assignment 2 Questions

-- Task 1: Select all employees from Employee table.
select * from employee;

-- Task 2 – Select all records from the Employee table where last name is King.
select * from employee where lastname = 'King';

-- Task 3 – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname = 'Andrew' and reportsto is null;


--| 2.2 ORDER BY |---------------------------------------------------------


-- Task 1 – Select all albums in Album table and sort result set in descending order by title.
select * from album order by title desc;

-- Task 2 – Select first name from Customer and sort result set in ascending order by city
select firstname from customer order by city asc;


--| 2.3 INSERT INTO |---------------------------------------------------------


-- Task 1 – Insert two new records into Genre table
INSERT INTO genre (genreid, name)
VALUES
 (26, 'EDM'),(27,'Grunge');

-- Task 2 – Insert two new records into Employee table
INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) 
VALUES
 (9, 'Omar', 'Mohamed', 'IT Staff', 5, '1995/1/17', '2019/01/14', '2222 Drive', 'Tampa', 'FL', 'United States', '11111', '+1 (888) 888-8888', '+1 (777) 777-7777', 'momar@email.com'),
(10,'Orlando', 'Peter', 'IT Staff', 6, '1992/1/11', '2019/01/14', '2222 Drive', 'Tampa', 'FL', 'United States', '22222', '+1 (888) 888-8888', '+1 (777) 777-7777', 'peter@email.com');
select * from employee; 

-- Task 3 – Insert two new records into Customer table
INSERT INTO customer (customerid, firstname, lastname, address, city, country, postalcode, phone, email, supportrepid)
VALUES
 (60, 'Omar', 'Mohamed', 'Bruce B Downs Blvd', 'New York', 'United States', '55555', '+1 (666) 666-6666', 'momar@email.com', 9),
(61,'Orlando', 'Peter', 'Bruce B Downs Blvd', 'Miami', 'United States', '66666', '+1 (777) 777-7777', 'peter@email.com', 10);
select * from customer;


--| 2.4 UPDATE |---------------------------------------------------------


-- Task 1 – Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname = 'Robert', lastname = 'Walter' where firstname = 'Aaron' and lastname = 'Mitchell';

-- Task 2 – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist set name = 'CCR' where name = 'Creedence Clearwater Revival';



--| 2.5 LIKE |---------------------------------------------------------


-- Task 1 – Select all invoices with a billing address like “T%”
select * from invoice where billingaddress like 'T%';


--| 2.6 BETWEEN |---------------------------------------------------------


-- Task 1 – Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;


-- Task 2 – Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate between '2003-06-01' and '2004-03-01';



--| 2.7 DELETE |---------------------------------------------------------


-- Task 1 – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
-- DELETE FROM table_name WHERE [condition];
create view targetID as select customerid from customer where firstname = 'Robert' and lastname = 'Walter';
delete from invoiceline where invoiceid in (select invoiceid from invoice where customerid = (select customerid from targetID));
delete from invoice where customerid = (select customerid from targetID);
delete from customer where customerid = (select customerid from targetID);
select * from customer where firstname = 'Robert';



--| 3.1 System Defined Functions |---------------------------------------------------------



-- Task 1 – Create a function that returns the current time.
CREATE FUNCTION getTime() RETURNS timestamptz AS $$
   SELECT now() AS result;
$$ LANGUAGE SQL;
select * from gettime();


-- Task 2 – create a function that returns the length of a mediatype from the mediatype table
CREATE FUNCTION length() RETURNS bigint AS $$
   SELECT COUNT("name") from mediatype AS result;
$$ LANGUAGE SQL;

select * from length();


--| 3.2 System Defined Aggregate Functions |---------------------------------------------------------


--| Task 1 – Create a function that returns the average total of all invoices
create function average() returns numeric AS $$
   select sum(total)/count(total) from invoice AS result;
$$ LANGUAGE SQL;

select * from average();




--| Task 2 – Create a function that returns the most expensive track
create function maxPrice() returns setof track AS $$
    select * from track where unitprice = (select max(unitprice) from track);
$$ LANGUAGE SQL;

select * from maxPrice();



--| 3.3 User Defined Scalar Functions |---------------------------------------------------------


--| Task 1 – Create a function that returns the average price of invoiceline items in the invoiceline table
create function averageInvoice() returns numeric AS $$
   select sum(unitprice)/count(unitprice) from invoiceline AS result;
$$ LANGUAGE SQL;

select * from averageInvoice();



--| 3.4 User Defined Table Valued Functions |---------------------------------------------------------


--| Task 1 – Create a function that returns all employees who are born after 1968.
create function bornLater() returns setof employee AS $$
    select * from employee where birthdate > '1968-12-31';
$$ LANGUAGE SQL;

select * from bornLater();



--| 4.1 Basic Stored Procedure |---------------------------------------------------------


-- Task 1 – Create a stored procedure that selects the first and last names of all the employees.
create or replace function employeeNames()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select firstname, lastname from employee;
		return ref;
	end;
$$ language plpgsql;

create table e_names (
	employeeid serial primary key,
	firstname text,
	lastname text
);

do $$
declare
    curs refcursor;
  	v_firstname text;
  	v_lastname text;
begin
    select employeeNames() into curs;
   	loop
        fetch curs into v_firstname, v_lastname;
        exit when not found;
        insert into e_names (firstname, lastname) values(v_firstname, v_lastname);
   	end loop;
end;
$$ language plpgsql;

select * from e_names;



--| 4.2 Stored Procedure Input Parameters |---------------------------------------------------------


-- Task 1 – Create a stored procedure that updates the personal information of an employee.
create or replace function update_emp(
	p_id int, 
	p_birthdate timestamp, 
	p_address varchar, 
	p_city varchar, 
	p_state varchar,
	p_country varchar,
    p_postalcode varchar,
    p_phone varchar,
    p_fax varchar,
    p_email varchar
) returns void as $$
begin
    update employee
    	set birthdate = p_birthdate,
    	address = p_address,
    	city = p_city,
    	state = p_state,
    	country = p_country,
    	postalcode = p_postalcode,
    	phone = p_phone,
    	fax = p_fax,
    	email = p_email
        where employeeid = p_id;
end;
$$ language plpgsql;

select update_emp(10, '1980-01-20', 'Bruce B Downs Blvd', 'Tampa', 'FL', 'US', '44444', '444-444-4444', 'lololol', 'bkjr@gmail.com');



-- Task 2 – Create a stored procedure that returns the managers of an employee.
create table e_managers (
	employeeid serial primary key,
	m_name text,
	e_name text
);

create or replace function employeeManagers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(m.firstname, ', ', m.lastname) as "Manager Name",
			concat(e.firstname, ', ', e.lastname) as "Employee Name"
			from employee as m
			inner join employee as e  
			on m.employeeid = e.reportsto
			order by m.employeeid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_m_name text;
  	v_e_name text;
begin
    select employeeManagers() into curs;
   	loop
        fetch curs into v_m_name, v_e_name;
        exit when not found;
        insert into e_managers (m_name, e_name) values(v_m_name, v_e_name);
   	end loop;
end;
$$ language plpgsql;

select * from e_managers;


--| 4.3 Stored Procedure Output Parameters |---------------------------------------------------------


-- Task 1 – Create a stored procedure that returns the name and company of a customer.
create table temp_customers (
	id serial primary key,
	name text,
	company text
);

create or replace function getCustomers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(firstname, ' ', lastname),
			company
			from customer
			order by customerid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_name text;
  	v_company text;
begin
    select getCustomers() into curs;
   	loop
        fetch curs into v_name, v_company;
        exit when not found;
        insert into temp_customers (name, company) values(v_name, v_company);
   	end loop;
end;
$$ language plpgsql;

select * from temp_customers;


--| 5.0 Transactions |---------------------------------------------------------


-- Task 1 – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
begin;
	delete from invoice where invoiceid = 405;
commit;

-- Task 2 – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
create or replace function insert_customer(
	p_id integer, 
	p_firstname varchar, 
	p_lastname varchar, 
	p_company varchar, 
	p_address varchar, 
	p_city varchar, 
	p_state varchar, 
	p_country varchar, 
	p_postalcode varchar, 
	p_phone varchar, 
	p_fax varchar, 
	p_email varchar, 
	p_supportrepid int
) 
returns void as $$
	begin
		insert into customer values(p_id, p_firstname, p_lastname, p_company, p_address, p_city, p_state, p_country, p_postalcode, p_phone, p_fax, p_email, p_supportrepid);
	end;
$$ language plpgsql;

select insert_customer(62, 'Blake', 'Kruppa', 'Revature', 'Bruce B Downs Blvd', 'Tampa', 'FL', 'US', '55555', '555-555-5555', '555-555-555', 'bkruppa@gmail.com', 9);



--| 6.1 AFTER/FOR |---------------------------------------------------------


-- Task 1 - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger after_employee_insert
	after insert on employee
	for each row
    execute procedure hello_world();
   
drop trigger after__employee_insert on employee;

-- Task 2 – Create an after update trigger on the album table that fires after a row is inserted in the table
create trigger after_album_update
	after update on album
	for each row
    execute procedure hello_world();
   
insert into album values (350, 'Test', 275);
update album set title = 'New Title' where albumid = 350;
select * from album;
delete from album where albumid = 350;

drop trigger after_album_update on album;

-- Task 3 – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
create trigger after_customer_delete
	after delete on customer
	for each row
    execute procedure hello_world();
   
insert into customer (customerid, firstname, lastname, email) values (62, 'John', 'Doe', 'jd@gmail.com');
select * from customer;
delete from customer where customerid = 62;

drop trigger after_customer_delete on customer;


--| 7.1 INNER |---------------------------------------------------------


-- Task 1 – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
select C.firstname, C.lastname, I.invoiceid from customer C join invoice I on C.customerid = I.invoiceid;


--| 7.2 OUTER |---------------------------------------------------------

-- Task 2 – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
select C.customerid ,C.firstname, C.lastname, I.invoiceid, I.total from customer C full outer join invoice I on C.customerid = I.invoiceid;


--| 7.3 RIGHT |---------------------------------------------------------

-- Task 3 – Create a right join that joins album and artist specifying artist name and title.
select B."name", A.title from album A right join artist B on A.albumid = B.artistid;


--| 7.4 CROSS |---------------------------------------------------------

-- Task 4 – Create a cross join that joins album and artist and sorts by artist name in ascending order.
select B."name" from album A cross join artist B order by name asc;


--| 7.5 SELF |---------------------------------------------------------

-- Task 5 – Perform a self-join on the employee table, joining on the reportsto column.
SELECT 
    concat(e.firstname, ' ', e.lastname) employee,
    concat(m.firstname, ' ', m.lastname) employee
FROM
    employee e
INNER JOIN
    employee m ON m.employeeid = e.reportsto;






