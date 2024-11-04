<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register New Customer - Anila Gas Company</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-image: url('./re.jpg'); /* Replace with your image URL */
            background-size: cover;
            background-position: center;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            padding: 20px;
            position: relative;
            animation: fadeIn 1.5s ease-in;
        }

        body::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6); /* Adjust opacity and color */
            z-index: 1;
        }

        .container {
            position: relative;
            width: 100%;
            max-width: 450px;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: slideIn 1s ease-out;
            z-index: 2;
        }

        h2 {
            color: #ffffff;
            text-align: center;
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-top: 15px;
            color: #ffffff;
            font-weight: bold;
        }

        input[type="text"],
        input[type="number"],
        input[type="email"] {
            width: calc(100% - 20px);
            padding: 12px 10px;
            margin-top: 5px;
            border: none;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.3);
            color: #ffffff;
            font-size: 16px;
            transition: background-color 0.3s ease, border-color 0.3s ease;
            outline: none;
        }

        input[type="text"]:focus,
        input[type="number"]:focus,
        input[type="email"]:focus {
            background: rgba(255, 255, 255, 0.5);
            outline: 2px solid #ffffff;
        }

        .btn {
            display: block;
            width: calc(100% - 20px);
            padding: 12px;
            margin-top: 20px;
            border: none;
            background: linear-gradient(135deg, #ff758c, #ff7eb3);
            color: white;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            outline: none;
        }

        .btn:hover {
            background: linear-gradient(135deg, #ff7eb3, #ff758c);
        }

        .login-link {
            text-align: center;
            margin-top: 15px;
            color: #ffffff;
            font-weight: bold;
        }

        .login-link a {
            color: #ff7eb3;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { transform: translateY(-20px); }
            to { transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Customer Registration</h2>

        <form action="register.jsp" method="post">
            <label for="name">Full Name</label>
            <input type="text" id="name" name="name" required>

            <label for="address">Address</label>
            <input type="text" id="address" name="address" required>

            <label for="pin">PIN Code</label>
            <input type="number" id="pin" name="pin" required>

            <label for="contact">Contact Number</label>
            <input type="text" id="contact" name="contact" required>

            <label for="email">Email ID</label>
            <input type="email" id="email" name="email" required>

            <input type="submit" value="Register" class="btn">
        </form>

        <div class="login-link">
            Already registered? <a href="login.jsp">Go to Login</a>
        </div>
    </div>

    <%
        if (request.getMethod().equalsIgnoreCase("post")) {
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String pin = request.getParameter("pin");
            String contact = request.getParameter("contact");
            String email = request.getParameter("email");

            Connection conn = null;
            PreparedStatement pstmt = null;
            PreparedStatement pstmtLogin = null;

            try {
                String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                StringBuilder password = new StringBuilder();
                Random rnd = new Random();
                for (int i = 0; i < 8; i++) {
                    password.append(characters.charAt(rnd.nextInt(characters.length())));
                }
                String generatedPassword = password.toString();

                Class.forName("oracle.jdbc.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                String sql = "INSERT INTO Consumer (consumer_no, name, address, pin, contact_no, email_id, no_of_cylinders) " +
                             "VALUES (Consumer_seq.NEXTVAL, ?, ?, ?, ?, ?, 0)";
                pstmt = conn.prepareStatement(sql, new String[]{"consumer_no"});
                pstmt.setString(1, name);
                pstmt.setString(2, address);
                pstmt.setInt(3, Integer.parseInt(pin));
                pstmt.setString(4, contact);
                pstmt.setString(5, email);

                int rows = pstmt.executeUpdate();

                if (rows > 0) {
                    ResultSet rs = pstmt.getGeneratedKeys();
                    if (rs.next()) {
                        int consumerNo = rs.getInt(1);

                        String sqlLogin = "INSERT INTO Login (consumer_no, name, password) VALUES (?, ?, ?)";
                        pstmtLogin = conn.prepareStatement(sqlLogin);
                        pstmtLogin.setInt(1, consumerNo);
                        pstmtLogin.setString(2, name);
                        pstmtLogin.setString(3, generatedPassword);

                        pstmtLogin.executeUpdate();

    %>
                        <script>
                            alert("Customer registered successfully! Your generated password is: <%= generatedPassword %>");
                        </script>
    <%
                    }
                } else {
    %>
                    <script>alert("Failed to register customer. Please try again.");</script>
    <%
                }
            } catch (Exception e) {
                e.printStackTrace();
    %>
                <script>alert("Error: <%= e.getMessage() %>");</script>
    <%
            } finally {
                if (pstmtLogin != null) pstmtLogin.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        }
    %>
</body>
</html>
