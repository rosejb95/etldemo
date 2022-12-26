SELECT *
FROM SomeTable st
WHERE EXISTS
  (
    SELECT *
    FROM SomeTable ot
    WHERE st.Id != ot.Id
      AND st.Test_Date > ot.Test_Date
  )