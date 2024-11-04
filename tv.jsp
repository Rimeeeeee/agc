<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Transfer Voucher - Anila Gas Company</title>
    <style>
        /* Full-page background image */
        body {
            background-image: url('tv.jpg'); /* Replace with the path to your image */
            background-size: cover;
            background-position: center;
            font-family: Arial, sans-serif;
            color: #333;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }

        /* Centered container */
        .container {
            background-color: rgba(255, 255, 255, 0.9); /* Semi-transparent white */
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            padding: 20px 40px;
            width: 100%;
            max-width: 400px;
            text-align: center;
        }

        h1 {
            color: #005a9c; /* Dark blue color */
            font-size: 24px;
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }

        input[type="text"] {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }

        button {
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #005a9c; /* Dark blue */
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #003f6e;
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
        String consumerAddress = request.getParameter("address");
        String remark = request.getParameter("remark");

        if (consumerAddress != null && remark != null) {
            Connection conn = null;
            PreparedStatement pstmtFetchConsumerNo = null;
            PreparedStatement pstmtFetchSV = null;
            PreparedStatement pstmtInsertTV = null;

            try {
                Class.forName("oracle.jdbc.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                String sqlFetchConsumerNo = "SELECT consumer_no FROM Consumer WHERE name = ?";
                pstmtFetchConsumerNo = conn.prepareStatement(sqlFetchConsumerNo);
                pstmtFetchConsumerNo.setString(1, username);
                ResultSet rsConsumerNo = pstmtFetchConsumerNo.executeQuery();

                if (rsConsumerNo.next()) {
                    int consumerId = rsConsumerNo.getInt("consumer_no");

                    String sqlFetchSV = "SELECT type_of_cylinder, deposit_amount AS amount_paid, date_of_connection AS sv_date, distributor_name FROM SV WHERE consumer_no = ?";
                    pstmtFetchSV = conn.prepareStatement(sqlFetchSV);
                    pstmtFetchSV.setInt(1, consumerId);
                    ResultSet rsSV = pstmtFetchSV.executeQuery();

                    if (rsSV.next()) {
                        String cylinderType = rsSV.getString("type_of_cylinder");
                        double amountPaid = rsSV.getDouble("amount_paid");
                        Date svDate = rsSV.getDate("sv_date");
                        String distributorName = rsSV.getString("distributor_name");

                        String sqlInsertTV = "INSERT INTO TV (tv_no, tv_date, consumer_no, sv_no, sv_date, cylinder_type, consumer_name, consumer_address, distributor_name, transferee_distributor_name, amount_paid, remark, approval_status, request_status) VALUES (TV_SEQ.NEXTVAL, SYSDATE, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, 'N', 'Y')";
                        pstmtInsertTV = conn.prepareStatement(sqlInsertTV);
                        pstmtInsertTV.setInt(1, consumerId);
                        pstmtInsertTV.setInt(2, consumerId);
                        pstmtInsertTV.setDate(3, svDate);
                        pstmtInsertTV.setString(4, cylinderType);
                        pstmtInsertTV.setString(5, username);
                        pstmtInsertTV.setString(6, consumerAddress);
                        pstmtInsertTV.setString(7, distributorName);
                        pstmtInsertTV.setDouble(8, amountPaid);
                        pstmtInsertTV.setString(9, remark);

                        int rows = pstmtInsertTV.executeUpdate();
                        if (rows > 0) {
%>
                            <script>alert("Transfer Voucher created successfully!");</script>
<%
                        } else {
%>
                            <script>alert("Failed to create Transfer Voucher. Please try again.");</script>
<%
                        }
                    } else {
%>
                        <script>alert("SV details not found for the consumer.");</script>
<%
                    }
                } else {
%>
                    <script>alert("Consumer details not found.");</script>
<%
                }
            } catch (Exception e) {
                e.printStackTrace();
%>
                <script>alert("Error: <%= e.getMessage() %>");</script>
<%
            } finally {
                if (pstmtInsertTV != null) pstmtInsertTV.close();
                if (pstmtFetchSV != null) pstmtFetchSV.close();
                if (pstmtFetchConsumerNo != null) pstmtFetchConsumerNo.close();
                if (conn != null) conn.close();
            }
        } else {
%>
            <div class="container">
                <h1>Transfer Voucher</h1>
                <form method="post">
                    <label for="address">Address:</label>
                    <input type="text" name="address" id="address" required>

                    <label for="remark">Remark:</label>
                    <input type="text" name="remark" id="remark" required>

                    <button type="submit">Create Transfer Voucher</button>
                </form>
            </div>
<%
        }
    }
%>
</body>
</html>
