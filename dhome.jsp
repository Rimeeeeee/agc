<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Distributor Home - Anila Gas Company</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-image: url('./dh.jpg'); /* Replace with the path to your image */
            background-size: cover;
            background-position: center;
            margin: 0;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #ffffff;
            margin-bottom: 20px;
        }
        h2{
            color: #ffffff; 
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background-color: rgba(255, 255, 255, 0.8);
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #005a9c;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #ddd;
        }
        .approve-btn {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .approve-btn:hover {
            background-color: #218838;
        }
        .container {
            max-width: 1200px;
            margin: auto;
            padding: 20px;
        }
        .logout-btn {
            background-color: #ff7eb3;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            float: right;
            margin-top: -50px; /* Adjust position */
            margin-bottom: 20px;
        }
        .logout-btn:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String distributorName = (String) session.getAttribute("DName");
    if (distributorName == null) {
%>
        <script>
            alert("User not logged in. Please login.");
            window.location.href = 'dlogin.jsp';
        </script>
<%
    } else {
%>
        <div class="container">
            <form action="" method="post" style="display:inline;">
                <input type="submit" value="Logout" class="logout-btn" name="logout">
            </form>

            <h1>Welcome, <%= distributorName %>!</h1>
            
            <h2>Distributor Details</h2>
            <table>
                <tr>
                    <th>Distributor No</th>
                    <th>Name</th>
                    <th>Address</th>
                    <th>Total Sales</th>
                </tr>
<%
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

            // Fetch distributor details
            String distributorSql = "SELECT * FROM Distributor WHERE name = ?";
            pstmt = conn.prepareStatement(distributorSql);
            pstmt.setString(1, distributorName);
            ResultSet distributorRs = pstmt.executeQuery();
            
            // Fetch details from the TV table for the distributor
            String sql = "SELECT * FROM TV WHERE distributor_name = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, distributorName);
            rs = pstmt.executeQuery();
            
            if (distributorRs.next()) {
%>
                <tr>
                    <td><%= distributorRs.getInt("distributor_no") %></td>
                    <td><%= distributorRs.getString("name") %></td>
                    <td><%= distributorRs.getString("address") %></td>
                    <td><%= distributorRs.getDouble("total_sales") %></td>
                </tr>
<%
            } else {
%>
                <tr>
                    <td colspan="4">Distributor details not found.</td>
                </tr>
<%
            }
            distributorRs.close();
%>
            </table>

            <h2>TV Details</h2>
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
                    <th>Transferee Distributor Name</th>
                    <th>Amount Paid</th>
                    <th>Remark</th>
                    <th>Approval Status</th>
                    <th>Request Status</th>
                    <th>Action</th>
                </tr>
<%
            while (rs.next()) {
%>
                <tr>
                    <td><%= rs.getInt("tv_no") %></td>
                    <td><%= rs.getDate("tv_date") %></td>
                    <td><%= rs.getInt("consumer_no") %></td>
                    <td><%= rs.getInt("sv_no") %></td>
                    <td><%= rs.getDate("sv_date") %></td>
                    <td><%= rs.getString("cylinder_type") %></td>
                    <td><%= rs.getString("consumer_name") %></td>
                    <td><%= rs.getString("consumer_address") %></td>
                    <td><%= rs.getString("transferee_distributor_name") %></td>
                    <td><%= rs.getDouble("amount_paid") %></td>
                    <td><%= rs.getString("remark") %></td>
                    <td><%= rs.getString("approval_status") %></td>
                    <td><%= rs.getString("request_status") %></td>
                    <td>
                        <form action="" method="post" style="display:inline;">
                            <input type="hidden" name="tv_no" value="<%= rs.getInt("tv_no") %>">
                            <input type="hidden" name="distributor_name" value="<%= distributorName %>">
                            <% if (!"Y".equals(rs.getString("approval_status"))) { %>
                                <input type="submit" name="approve" value="Approve" class="approve-btn">
                            <% } else { %>
                                <span style="color: green; font-weight: bold;">Approved</span>
                            <% } %>
                        </form>
                    </td>
                </tr>
<%
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
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }

        // Handle logout process if form is submitted
        if (request.getMethod().equalsIgnoreCase("post") && request.getParameter("logout") != null) {
            session.invalidate(); // Kill the session
            response.sendRedirect("dlogin.jsp"); // Redirect to dlogin.jsp
        }

        // Handle approval process if form is submitted
        if (request.getMethod().equalsIgnoreCase("post") && request.getParameter("approve") != null) {
            int tvNo = Integer.parseInt(request.getParameter("tv_no"));
            distributorName = request.getParameter("distributor_name");
            Connection approveConn = null;
            PreparedStatement approvePstmt = null;

            try {
                Class.forName("oracle.jdbc.OracleDriver");
                approveConn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                // Update the TV entry for approval
                String updateSql = "UPDATE TV SET approval_status = 'Y', request_status = 'N' WHERE tv_no = ?";
                approvePstmt = approveConn.prepareStatement(updateSql);
                approvePstmt.setInt(1, tvNo);
                int rowsUpdated = approvePstmt.executeUpdate();

                if (rowsUpdated > 0) {
%>
                    <script>alert("Approval successful!"); window.location.href = "dhome.jsp";</script>
<%
                } else {
%>
                    <script>alert("Approval failed. Please try again."); window.location.href = "dhome.jsp";</script>
<%
                }
            } catch (Exception e) {
                e.printStackTrace();
%>
                <script>alert("Error: <%= e.getMessage() %>"); window.location.href = "dhome.jsp";</script>
<%
            } finally {
                if (approvePstmt != null) approvePstmt.close();
                if (approveConn != null) approveConn.close();
            }
        }
    }
%>
</body>
</html>