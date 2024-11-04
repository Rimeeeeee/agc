<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Transaction History</title>
    <style>
        body {
            background-image: url('svtv.jpg'); /* Replace with the path to your image */
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
    <script>alert("User not logged in. Please login to continue."); window.location.href = 'login.jsp';</script>
<%
    } else {
        Connection conn = null;
        PreparedStatement pstmtSV = null;
        PreparedStatement pstmtTV = null;
        ResultSet rsSV = null;
        ResultSet rsTV = null;

        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

            // Fetch SV data
            String sqlSV = "SELECT * FROM SV WHERE consumer_name = ?";
            pstmtSV = conn.prepareStatement(sqlSV);
            pstmtSV.setString(1, username);
            rsSV = pstmtSV.executeQuery();
%>
    <div class="container">
        <h1>SV Details for <%= username %></h1>
        <table>
            <tr>
                <th>Consumer No</th>
                <th>Consumer Name</th>
                <th>Address</th>
                <th>Date of Connection</th>
                <th>Distributor Name</th>
                <th>Deposit Amount</th>
                <th>Type of Cylinder</th>
                <th>No of Cylinders</th>
            </tr>
<%
            boolean hasRecordsSV = false;
            while (rsSV.next()) {
                hasRecordsSV = true;
%>
                <tr>
                    <td><%= rsSV.getInt("consumer_no") %></td>
                    <td><%= rsSV.getString("consumer_name") %></td>
                    <td><%= rsSV.getString("address") %></td>
                    <td><%= rsSV.getDate("date_of_connection") %></td>
                    <td><%= rsSV.getString("distributor_name") %></td>
                    <td><%= rsSV.getDouble("deposit_amount") %></td>
                    <td><%= rsSV.getString("type_of_cylinder") %></td>
                    <td><%= rsSV.getInt("no_of_cylinders") %></td>
                </tr>
<%
            }
            if (!hasRecordsSV) {
%>
                <tr>
                    <td colspan="8" class="no-records">No SV records found.</td>
                </tr>
<%
            }
%>
        </table>

<%
        // Fetch TV data based on consumer_no from SV
        String sqlTV = "SELECT * FROM TV WHERE consumer_no IN (SELECT consumer_no FROM SV WHERE consumer_name = ?)";
        pstmtTV = conn.prepareStatement(sqlTV);
        pstmtTV.setString(1, username);
        rsTV = pstmtTV.executeQuery();
%>
        <h1>TV Transaction History for <%= username %></h1>
        <table>
            <tr>
                <th>TV No</th>
                <th>TV Date</th>
                <th>Consumer No</th>
                <th>SV No</th>
                <th>SV Date</th>
                <th>Cylinder Type</th>
                <th>Consumer Name</th>
                <th>Consumer Address</th>
                <th>Distributor Name</th>
                <th>Transferee Distributor Name</th>
                <th>Amount Paid</th>
                <th>Remark</th>
                <th>Approval Status</th>
                <th>Request Status</th>
            </tr>
<%
            boolean hasRecordsTV = false;
            while (rsTV.next()) {
                hasRecordsTV = true;
%>
                <tr>
                    <td><%= rsTV.getInt("tv_no") %></td>
                    <td><%= rsTV.getDate("tv_date") %></td>
                    <td><%= rsTV.getInt("consumer_no") %></td>
                    <td><%= rsTV.getInt("sv_no") %></td>
                    <td><%= rsTV.getDate("sv_date") %></td>
                    <td><%= rsTV.getString("cylinder_type") %></td>
                    <td><%= rsTV.getString("consumer_name") %></td>
                    <td><%= rsTV.getString("consumer_address") %></td>
                    <td><%= rsTV.getString("distributor_name") %></td>
                    <td><%= rsTV.getString("transferee_distributor_name") %></td>
                    <td><%= rsTV.getDouble("amount_paid") %></td>
                    <td><%= rsTV.getString("remark") %></td>
                    <td><%= rsTV.getString("approval_status") %></td>
                    <td><%= rsTV.getString("request_status") %></td>
                </tr>
<%
            }
            if (!hasRecordsTV) {
%>
                <tr>
                    <td colspan="14" class="no-records">No TV records found.</td>
                </tr>
<%
            }
%>
        </table>
    </div>
<%
        } catch (Exception e) {
            e.printStackTrace();
            String errorMessage = e.getMessage(); // Store error message to be displayed
%>
    <script>alert("Error: " + "<%= errorMessage %>");</script>
<%
        } finally {
            try {
                if (rsSV != null) rsSV.close();
                if (rsTV != null) rsTV.close();
                if (pstmtSV != null) pstmtSV.close();
                if (pstmtTV != null) pstmtTV.close();
                if (conn != null) conn.close();
            } catch (SQLException sqlEx) {
                sqlEx.printStackTrace();
            }
        }
    }
%>
</body>
</html>