<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Transaction History</title>
    <style>
        body {
            background-image: url('ud.jpg'); /* Replace with the path to your image */
            background-size: cover;
            background-position: center;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            color: #333;
        }

        .container {
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 10px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
            padding: 25px;
            max-width: 80%;
            animation: fadeIn 1s ease-in-out;
            text-align: center;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h1 {
            color: #005a9c;
            font-size: 28px;
            margin: 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            border-radius: 10px;
            overflow: hidden;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
            transition: all 0.3s ease;
        }

        th {
            background-color: #005a9c;
            color: white;
            font-weight: bold;
        }

        td {
            background-color: #f9f9f9;
        }

        tr:hover td {
            background-color: #e8f4ff;
        }

        .no-records {
            color: #888;
            font-style: italic;
        }
    </style>
</head>
<body>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
%>
    <script>alert("User not logged in. Please login to continue.");</script>
<%
    } else {
        Connection conn = null;
        PreparedStatement pstmtConsumer = null;
        PreparedStatement pstmtAreaOffice = null;
        ResultSet rsConsumer = null;
        ResultSet rsAreaOffice = null;

        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

            // Fetch consumer data
            String sqlConsumer = "SELECT * FROM Consumer WHERE name = ?";
            pstmtConsumer = conn.prepareStatement(sqlConsumer);
            pstmtConsumer.setString(1, username);
            rsConsumer = pstmtConsumer.executeQuery();

%>
    <div class="container">
        <h1>Consumer and Area Office Details</h1>
        <table>
            <tr>
                <th>Consumer No</th>
                <th>Address</th>
                <th>PIN</th>
                <th>Contact No</th>
                <th>Email</th>
                <th>Connection Date</th>
                <th>Distributor No</th>
            </tr>
<%
            boolean hasRecords = false;
            int consumerPIN = 0;
            while (rsConsumer.next()) {
                hasRecords = true;
                consumerPIN = rsConsumer.getInt("pin"); // Get PIN to use for area office lookup
%>
                <tr>
                    <td><%= rsConsumer.getInt("consumer_no") %></td>
                    <td><%= rsConsumer.getString("address") %></td>
                    <td><%= consumerPIN %></td>
                    <td><%= rsConsumer.getString("contact_no") %></td>
                    <td><%= rsConsumer.getString("email_id") %></td>
                    <td><%= rsConsumer.getDate("date_of_connection") %></td>
                    <td><%= rsConsumer.getString("distributor_no") %></td>
                </tr>
<%
            }
            if (!hasRecords) {
%>
                <tr>
                    <td colspan="7" class="no-records">No consumer records found.</td>
                </tr>
<%
            }
%>
        </table>
        
<%
        if (consumerPIN != 0) {
            // Fetch area office data based on the PIN/APIN match
            String sqlAreaOffice = "SELECT * FROM Area_Office WHERE APIN = ?";
            pstmtAreaOffice = conn.prepareStatement(sqlAreaOffice);
            pstmtAreaOffice.setInt(1, consumerPIN); // Use consumerPIN directly
            rsAreaOffice = pstmtAreaOffice.executeQuery();
        
            // Debugging: Log the query execution
            if (rsAreaOffice.isBeforeFirst()) {
                System.out.println("Area office records found.");
            } else {
                System.out.println("No area office records found for PIN: " + consumerPIN);
            }
%>
        <table>
            <tr>
                <th>Area Office Name</th>
                <th>Unique Area No</th>
                <th>Address</th>
                <th>Manager</th>
                <th>Total Distributors</th>
                <th>Total Sales</th>
                <th>State Office Name</th>
            </tr>
<%
            hasRecords = false;
            while (rsAreaOffice.next()) {
                hasRecords = true;
%>
                <tr>
                    <td><%= rsAreaOffice.getString("area_office_name") %></td>
                    <td><%= rsAreaOffice.getInt("unique_area_no") %></td>
                    <td><%= rsAreaOffice.getString("address") %></td>
                    <td><%= rsAreaOffice.getString("manager") %></td>
                    <td><%= rsAreaOffice.getInt("total_distributor") %></td>
                    <td><%= rsAreaOffice.getInt("total_sales") %></td>
                    <td><%= rsAreaOffice.getString("state_office_name") %></td>
                   
                </tr>
<%
            }
            if (!hasRecords) {
%>
                <tr>
                    <td colspan="7" class="no-records">No area office records found.</td>
                </tr>
<%
            }
        }
%>
        </table>
    </div>
<%
        } catch (Exception e) {
            e.printStackTrace();
%>
    <script>alert("Error: <%= e.getMessage() %>");</script>
<%
        } finally {
            if (rsConsumer != null) rsConsumer.close();
            if (rsAreaOffice != null) rsAreaOffice.close();
            if (pstmtConsumer != null) pstmtConsumer.close();
            if (pstmtAreaOffice != null) pstmtAreaOffice.close();
            if (conn != null) conn.close();
        }
    }
%>
</body>
</html>