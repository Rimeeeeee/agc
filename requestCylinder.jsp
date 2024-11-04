<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Request Cylinder - Anila Gas Company</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-image: url('./reqC.jpg'); /* Replace with your image URL */
            background-size: cover;
            background-position: center;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            max-width: 400px;
            width: 100%;
            background: rgba(255, 255, 255, 0.9);
            padding: 40px 30px;
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
        input, select {
            width: 100%;
            padding: 12px;
            margin-top: 8px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 14px;
        }
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
        .btn:hover {
            background-color: #218838;
        }
        #amount {
            font-weight: bold;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Cylinder Request</h2>
        <form action="requestCylinder.jsp" method="post">
            <label for="name">Consumer Name</label>
            <input type="text" id="name" name="name" required>

            <label for="type_of_cylinder">Type of Cylinder</label>
            <select id="type_of_cylinder" name="type_of_cylinder" required>
                <option value="type-1">Type - 1</option>
                <option value="type-2">Type - 2</option>
            </select>

            <label for="quantity">Quantity</label>
            <input type="number" id="quantity" name="quantity" required min="1">

            <div id="amount">Amount: <span id="amountValue">0</span></div>

            <input type="submit" value="Request" class="btn">
        </form>
    </div>

    <script>
        const typeSelector = document.getElementById("type_of_cylinder");
        const quantityInput = document.getElementById("quantity");
        const amountValue = document.getElementById("amountValue");

        function calculateAmount() {
            const type = typeSelector.value;
            const quantity = parseInt(quantityInput.value) || 0;
            const pricePerCylinder = type === "type-1" ? 500 : 700;
            amountValue.innerText = pricePerCylinder * quantity;
        }

        typeSelector.addEventListener("change", calculateAmount);
        quantityInput.addEventListener("input", calculateAmount);
    </script>

<%







String consumerName = request.getParameter("name");
String typeOfCylinder = request.getParameter("type_of_cylinder");
String quantityStr = request.getParameter("quantity");

if (consumerName != null && typeOfCylinder != null && quantityStr != null) {
    int quantity = Integer.parseInt(quantityStr);
    double price = typeOfCylinder.equals("type-1") ? 500 : 700;
    double totalAmount = price * quantity;

    Connection conn = null;
    PreparedStatement pstmtFetch = null;
    PreparedStatement pstmtCheckRequest = null;
    PreparedStatement pstmtInsert = null;

    try {
        Class.forName("oracle.jdbc.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

        // Fetch consumer_no
        String sqlFetch = "SELECT consumer_no FROM Consumer WHERE name = ?";
        pstmtFetch = conn.prepareStatement(sqlFetch);
        pstmtFetch.setString(1, consumerName);
        ResultSet rs = pstmtFetch.executeQuery();

        if (rs.next()) {
            int consumerNo = rs.getInt("consumer_no");

            // Check if there's a request in the current month
            String sqlCheckRequest = "SELECT * FROM Cylinder WHERE consumer_no = ? AND EXTRACT(MONTH FROM date_of_request) = EXTRACT(MONTH FROM SYSDATE) AND EXTRACT(YEAR FROM date_of_request) = EXTRACT(YEAR FROM SYSDATE)";
            pstmtCheckRequest = conn.prepareStatement(sqlCheckRequest);
            pstmtCheckRequest.setInt(1, consumerNo);
            ResultSet rsRequests = pstmtCheckRequest.executeQuery();

            if (rsRequests.next()) { // If there are any rows, a request has already been made
%>
                <script>alert("You have already made a request this month.");</script>
<%
            } else {
                String sqlInsert = "INSERT INTO Cylinder (type, price, quantity, consumer_no, date_of_request) VALUES (?, ?, ?, ?, SYSDATE)";
                pstmtInsert = conn.prepareStatement(sqlInsert);
                pstmtInsert.setString(1, typeOfCylinder);   // Set type
                pstmtInsert.setDouble(2, totalAmount);       // Set price
                pstmtInsert.setInt(3, quantity);             // Set quantity
                pstmtInsert.setInt(4, consumerNo);  

                int rows = pstmtInsert.executeUpdate();
                if (rows > 0) {
%>
                    <script>alert("Cylinder request registered successfully!");</script>
<%
                } else {
%>
                    <script>alert("Failed to register request. Please try again.");</script>
<%
                }
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
        if (pstmtCheckRequest != null) pstmtCheckRequest.close();
        if (pstmtFetch != null) pstmtFetch.close();
        if (conn != null) conn.close();
    }
}
%>

</body>
</html>