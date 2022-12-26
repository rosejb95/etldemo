SELECT
    ProductID AS something,
    Name
FROM SalesLT.Product p1
WHERE EXISTS
    (
        SELECT *
        FROM SalesLT.Product p2
        WHERE p1.ProductNumber = p2.ProductNumber
            AND p2.Color = 'Black'
    )
