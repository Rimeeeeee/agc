<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register Cylinder - Anila Gas Company</title>
    <style>
        /* Styling for the body and background */
        body {
            font-family: Arial, sans-serif;
            background-image: url('./rc.jpg'); /* Replace with your image URL */
            background-size: cover;
            background-position: center;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        /* Container styling with added padding and shadow */
        .container {
            max-width: 400px;
            width: 100%;
            background: rgba(255, 255, 255, 0.9);
            padding: 40px 30px; /* Added padding for better spacing */
            border-radius: 15px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            text-align: center;
        }

        h2 {
            margin-bottom: 20px;
            color: #333;
        }

        label {
            display: block;
            text-align: left;
            font-weight: bold;
            color: #555;
            margin-top: 15px;
            font-size: 14px;
        }

        /* Input and select styling with smooth borders */
        input, select {
            width: 100%;
            padding: 12px;
            margin-top: 8px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 14px;
        }

        /* Button styling for enhanced appearance */
        .btn {
            width: 100%;
            padding: 12px;
            background-color: #28a745;
            border: none;
            border-radius: 5px;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
            transition: background-color 0.3s ease;
        }

        /* Button hover effect */
        .btn:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Cylinder Registration</h2>
        <form action="registerCylinder.jsp" method="post">
            <label for="name">Consumer Name</label>
            <input type="text" id="name" name="name" required>

            <label for="no_of_cylinders">Number of Cylinders</label>
            <input type="number" id="no_of_cylinders" name="no_of_cylinders" required min="1">

            <label for="deposit_amount">Deposit Amount</label>
            <input type="number" id="deposit_amount" name="deposit_amount" required min="500" placeholder="Minimum 500">

            <label for="type_of_cylinder">Type of Cylinder</label>
            <select id="type_of_cylinder" name="type_of_cylinder">
                <option value="type-1">Type - 1</option>
                <option value="type-2">Type - 2</option>
            </select>

            <input type="submit" value="Register" class="btn">
        </form>
    </div>

    <%
        if (request.getMethod().equalsIgnoreCase("post")) {
            String consumerName = request.getParameter("name");
            int noOfCylinders = Integer.parseInt(request.getParameter("no_of_cylinders"));
            double depositAmount = Double.parseDouble(request.getParameter("deposit_amount"));
            String typeOfCylinder = request.getParameter("type_of_cylinder");

            if (depositAmount < 500) {
    %>
                <script>alert("Deposit amount must be greater than or equal to 500.");</script>
    <%
                return;
            }

            Connection conn = null;
            PreparedStatement pstmtFetch = null;
            PreparedStatement pstmtInsert = null;

            try {
                Class.forName("oracle.jdbc.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                // Fetch consumer_no and address
                String sqlFetch = "SELECT consumer_no, address FROM Consumer WHERE name = ?";
                pstmtFetch = conn.prepareStatement(sqlFetch);
                pstmtFetch.setString(1, consumerName);
                ResultSet rs = pstmtFetch.executeQuery();

                if (rs.next()) {
                    int consumerNo = rs.getInt("consumer_no");
                    String address = rs.getString("address");

                    // Insert data into SV table
                    String sqlInsert = "INSERT INTO SV (consumer_no, consumer_name, address, date_of_connection, distributor_name, deposit_amount, type_of_cylinder, no_of_cylinders) VALUES (?, ?, ?, SYSDATE, NULL, ?, ?, ?)";
                    pstmtInsert = conn.prepareStatement(sqlInsert);
                    pstmtInsert.setInt(1, consumerNo);
                    pstmtInsert.setString(2, consumerName);
                    pstmtInsert.setString(3, address);
                    pstmtInsert.setDouble(4, depositAmount);
                    pstmtInsert.setString(5, typeOfCylinder);
                    pstmtInsert.setInt(6, noOfCylinders);

                    int rows = pstmtInsert.executeUpdate();
                    if (rows > 0) {
    %>
                        <script>alert("Cylinder registered successfully!");</script>
    <%
                    } else {
    %>
                        <script>alert("Failed to register cylinder. Please try again.");</script>
    <%
                    }
                } else {
    %>
                    <script>alert("Consumer not found.");</script>
    <%
                }
            } catch (Exception e) {
                e.printStackTrace();
    %>
                <script>alert("Error: <%= e.getMessage() %>");</script>
    <%
            } finally {
                if (pstmtInsert != null) pstmtInsert.close();
                if (pstmtFetch != null) pstmtFetch.close();
                if (conn != null) conn.close();
            }
        }
    %>
</body>
</html>