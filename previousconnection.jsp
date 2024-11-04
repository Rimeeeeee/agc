<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Previous Connections - Anila Gas Company</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-image: url('./txn.jpg');
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            width: 80%;
            max-width: 800px;
            margin: 20px auto;
            background: #ffffff;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        h2 {
            color: #333;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Your Previous Cylinder Requests</h2>
        <table>
            <thead>
                <tr>
                    <th>Type</th>
                    <th>Price</th>
                    <th>Quantity</th>
                    <th>Date of Request</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String username = (String) session.getAttribute("username");
                    if (username == null) {
                %>
                    <script>alert("User not logged in. Please login to continue.");</script>
                <%
                    } else {
                        Connection conn = null;
                        PreparedStatement pstmtConsumer = null;
                        PreparedStatement pstmtCylinder = null;
                        ResultSet rsConsumer = null;
                        ResultSet rsCylinder = null;

                        try {
                            Class.forName("oracle.jdbc.OracleDriver");
                            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                            // Fetch Consumer Number using Username
                            String sqlConsumer = "SELECT consumer_no FROM Consumer WHERE name = ?";
                            pstmtConsumer = conn.prepareStatement(sqlConsumer);
                            pstmtConsumer.setString(1, username);
                            rsConsumer = pstmtConsumer.executeQuery();

                            if (rsConsumer.next()) {
                                int consumerNo = rsConsumer.getInt("consumer_no");

                                // Fetch Cylinder Requests using Consumer Number
                                String sqlCylinder = "SELECT type, price, quantity, date_of_request FROM Cylinder WHERE consumer_no = ?";
                                pstmtCylinder = conn.prepareStatement(sqlCylinder);
                                pstmtCylinder.setInt(1, consumerNo);
                                rsCylinder = pstmtCylinder.executeQuery();

                                while (rsCylinder.next()) {
                                    String type = rsCylinder.getString("type");
                                    double price = rsCylinder.getDouble("price");
                                    int quantity = rsCylinder.getInt("quantity");
                                    Date dateOfRequest = rsCylinder.getDate("date_of_request");
                %>
                                    <tr>
                                        <td><%= type %></td>
                                        <td><%= price %></td>
                                        <td><%= quantity %></td>
                                        <td><%= dateOfRequest %></td>
                                    </tr>
                <%
                                }
                            } else {
                %>
                                <tr>
                                    <td colspan="4">No consumer information found for this user.</td>
                                </tr>
                <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                %>
                            <script>alert("Error: <%= e.getMessage() %>");</script>
                <%
                        } finally {
                            if (rsCylinder != null) rsCylinder.close();
                            if (pstmtCylinder != null) pstmtCylinder.close();
                            if (rsConsumer != null) rsConsumer.close();
                            if (pstmtConsumer != null) pstmtConsumer.close();
                            if (conn != null) conn.close();
                        }
                    }
                %>
            </tbody>
        </table>
    </div>
</body>
</html>