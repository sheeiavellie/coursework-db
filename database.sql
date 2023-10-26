    CREATE TABLE Supplier (
        ID INTEGER PRIMARY KEY
    );

    CREATE TABLE Product (
        ID SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        quantity INTEGER NOT NULL,
        price float8,
        departmentID INTEGER NOT NULL
    );

    CREATE TABLE Supply (
        ID SERIAL PRIMARY KEY,
        supplierID INTEGER NOT NULL,
        date TIMESTAMP NOT NULL,
        productID INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        resolved BOOLEAN DEFAULT FALSE
    );

    CREATE TABLE Employee (
        ID INTEGER PRIMARY KEY,
        departmentID INTEGER NOT NULL
    );

    CREATE TABLE Department (
        ID SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL
    );

    CREATE TABLE Sale (
        ID SERIAL PRIMARY KEY,
        employeeID INTEGER NOT NULL,
        date TIMESTAMP NOT NULL,
        productID INTEGER NOT NULL,
        departmentID INTEGER NOT NULL,
        quantity INTEGER NOT NULL
    );

    CREATE TABLE Credentials (
        ID SERIAL PRIMARY KEY,
        passport_number VARCHAR(255) NOT NULL,
        first_name VARCHAR(255) NOT NULL,
        last_name VARCHAR(255) NOT NULL,
        person_type VARCHAR(255) NOT NULL
    );

    ALTER TABLE Product ADD FOREIGN KEY (departmentID) REFERENCES Department (ID);

    ALTER TABLE Employee ADD FOREIGN KEY (departmentID) REFERENCES Department (ID);

    ALTER TABLE Supply ADD FOREIGN KEY (supplierID) REFERENCES Supplier (ID);

    ALTER TABLE Supply ADD FOREIGN KEY (productID) REFERENCES Product (ID);

    ALTER TABLE Sale ADD FOREIGN KEY (employeeID) REFERENCES Employee (ID);

    ALTER TABLE Sale ADD FOREIGN KEY (productID) REFERENCES Product (ID);

    ALTER TABLE Sale ADD FOREIGN KEY (departmentID) REFERENCES Department (ID);

    ALTER TABLE Supplier ADD FOREIGN KEY (ID) REFERENCES Credentials (ID);

    ALTER TABLE Employee ADD FOREIGN KEY (ID) REFERENCES Credentials (ID);

    CREATE OR REPLACE FUNCTION new_sale() 
        RETURNS TRIGGER 
        LANGUAGE plpgsql
        AS 
    $$
    BEGIN
        UPDATE Product p
            SET quantity = quantity - NEW.quantity
        WHERE p.ID = NEW.productID;
        RETURN NEW; 
    END;
    $$;

    CREATE TRIGGER update_amount_sale 
    BEFORE INSERT ON Sale 
    FOR EACH ROW EXECUTE PROCEDURE new_sale();

    CREATE OR REPLACE FUNCTION new_supply() 
        RETURNS TRIGGER 
        LANGUAGE plpgsql
        AS 
    $$
    BEGIN
        UPDATE Product p
            SET quantity = quantity + NEW.quantity
        WHERE p.ID = NEW.productID;
        RETURN NEW;
    END;
    $$;

    CREATE TRIGGER update_amount_supply
    BEFORE UPDATE ON Supply 
    FOR EACH ROW WHEN(NEW.resolved IS True AND OLD.resolved IS False) 
    EXECUTE PROCEDURE new_supply();

    CREATE OR REPLACE FUNCTION dow_name(p_index integer)
        RETURNS text 
        LANGUAGE sql 
        STRICT IMMUTABLE PARALLEL SAFE 
        AS
    $$
    SELECT (array['Sun','Mon','Tue','Wed','Thu','Fri','Sat'])[p_index + 1];
    $$;

     INSERT INTO Department (name) VALUES
        ('chocolate department'),
        ('hard candy department'),
        ('sour candy department'),
        ('pastry department');
    INSERT INTO Credentials (passport_number, first_name, last_name, person_type) VALUES
        ('11 11 111111, 111-111', 'John', 'Doe', 'employee'),
        ('22 22 222222, 222-222', 'James', 'Doe', 'employee'),
        ('33 33 333333, 333-333', 'Juan', 'Doe', 'employee'),
        ('44 44 444444, 444-444', 'Johnny', 'Doe', 'employee'),
        ('55 55 555555, 555-555', 'Jonathan', 'Doe', 'supplier'),
        ('66 66 666666, 666-666', 'Jordan', 'Doe', 'supplier');
    INSERT INTO Supplier (ID) VALUES
        (5),
        (6);
    INSERT INTO Employee (ID, departmentID) VALUES
        (1, 1),
        (2, 2),
        (3, 3),
        (4, 4);
    INSERT INTO Product (name, quantity, price, departmentID) VALUES
        ('dark chocolate bar', 100, 2.49, 1),
        ('chocolate bar', 80, 1.49, 1),
        ('peanut chocolate bar', 120, 1.99, 1),
        ('white chocolate bar', 75, 1.99, 1),
        ('Strawberry lollipop', 250, 0.49, 2),
        ('Mint lollipop', 200, 0.49, 2),
        ('Jawlbreaker', 15, 7.49, 2),
        ('haribo sour gummy worms', 230, 3.49, 3),
        ('croissant', 25, 3.49, 4),
        ('chocolate donut', 50, 2.25, 4);    

    -- Queries
    
    -- Employees info:

        -- SELECT 
        --   e.ID, passport_number, first_name, last_name, person_type, d.name as department_name
        -- FROM Credentials c 
        -- JOIN Employee e 
        -- ON e.ID = c.ID 
        -- JOIN Department d 
        -- ON e.departmentID = d.ID;
    
    -- Products info:

        -- SELECT 
        --     p.ID, p.name, quantity, price, d.name as department_name
        -- FROM Product p 
        -- JOIN Department d 
        -- ON p.ID = d.ID
        -- ORDER BY p.ID;

    -- Suppliers info:

        -- SELECT 
        --     s.ID, passport_number, first_name, last_name, person_type 
        -- FROM Credentials c 
        -- JOIN Supplier s 
        -- ON c.ID = s.ID;

    -- Sales by Department:

        -- Specific department:

        -- SELECT 
        --     s.ID, date(s.date), p.name, s.departmentID, d.name, s.quantity 
        -- FROM Sale s 
        -- JOIN Product p 
        -- ON s.productID = p.ID 
        -- JOIN Department d 
        -- ON s.departmentID = d.ID 
        -- WHERE s.departmentID = 1;

        -- All departments:

        -- SELECT 
        --     s.ID, date(s.date), p.name, s.departmentID, d.name, s.quantity 
        -- FROM Sale s 
        -- JOIN Product p 
        -- ON s.productID = p.ID 
        -- JOIN Department d 
        -- ON s.departmentID = d.ID;

    -- Products left in Department:

        -- Each product detailed:

        -- SELECT 
        --     p.ID, p.name, p.quantity, p.departmentID, d.name 
        -- FROM Product p 
        -- JOIN Department d 
        -- ON p.departmentID = d.ID 
        -- WHERE d.ID = 1;

        -- Only product quantity left for each department:

        -- SELECT 
        --     d.ID, d.name, SUM(p.quantity) as products_left 
        -- FROM Department d 
        -- JOIN Product p 
        -- ON p.departmentID = d.ID 
        -- GROUP BY d.ID, d.name
        -- ORDER BY d.ID;

    -- Sales with everything:
    
        -- SELECT 
        --     s.ID, s.employeeID, c.first_name, c.last_name, s.date, p.name, d.name, s.quantity 
        -- FROM Sale s 
        -- JOIN Department d 
        -- ON s.departmentID = d.ID 
        -- JOIN Product p 
        -- ON s.productID = p.ID 
        -- JOIN Credentials c
        -- ON s.employeeID = c.ID;

    -- Financial results: 
    
        -- By day for each Department:

        -- SELECT 
        --     d.ID, d.name, date(s.date) as date, SUM(s.quantity * p.price) as earned_revenue
        -- FROM Department d 
        -- JOIN Sale s 
        -- ON s.departmentID = d.ID 
        -- JOIN Product p 
        -- ON s.productID = p.ID 
        -- WHERE date(s.date) = '2023-09-29' 
        -- GROUP BY d.ID, d.name, date(s.date);

        -- Revenue for employee:

        -- SELECT 
        --     e.ID, c.first_name, c.last_name, date(s.date) as date, SUM(s.quantity * p.price) as earned_revenue 
        -- FROM Employee e 
        -- JOIN Credentials c 
        -- ON e.ID = c.ID 
        -- JOIN Sale s 
        -- ON s.employeeID = e.ID 
        -- JOIN Product p 
        -- ON s.productID = p.ID 
        -- WHERE date(s.date) = '2023-09-30' 
        -- GROUP BY e.ID, c.first_name, c.last_name, date(s.date);

    -- Sales volume:

        -- By day of week:

        -- SELECT 
        --     dow_name((extract(dow from s.date::timestamp))::integer) as day_of_week, 
        --     SUM(s.quantity) as total_sold, 
        --     TRIM(TRAILING ', ' FROM string_agg(DISTINCT d.name, ', ')) as departments 
        -- FROM Sale s 
        -- JOIN Department d 
        -- ON s.departmentID = d.ID 
        -- GROUP BY day_of_week;

        -- By month:
        
        -- SELECT 
        --     to_char(s.date, 'Month') as month, 
        --     SUM(s.quantity) as total_sold, 
        --     TRIM(TRAILING ', ' FROM string_agg(DISTINCT d.name, ', ')) as departments 
        -- FROM Sale s 
        -- JOIN Department d 
        -- ON s.departmentID = d.ID 
        -- GROUP BY month;
