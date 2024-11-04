<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Anila Gas Company</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-image: url('./login-bg.jpg'); /* Replace with your image URL */
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
        /* Add backdrop overlay */
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
            background: rgba(255, 255, 255, 0.15); /* Glassmorphism effect */
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: slideIn 1s ease-out;
            z-index: 2; /* Ensure it appears above the backdrop */
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
        input[type="text"], input[type="password"] {
            width: calc(100% - 20px); /* Padding on each side */
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
        input[type="text"]:focus, input[type="password"]:focus {
            background: rgba(255, 255, 255, 0.5);
            outline: 2px solid #ffffff;
        }
        .btn {
            display: block;
            width: calc(100% - 20px); /* Padding on each side */
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
        <h2>Customer Login</h2>

        <form action="login.jsp" method="post">
            <label for="consumer_no">Consumer Number</label>
            <input type="text" id="consumer_no" name="consumer_no" required>

            <label for="name">Name</label>
            <input type="text" id="name" name="name" required>

            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>

            <input type="submit" value="Login" class="btn">
        </form>
        <div class="login-link">
           Not A Consumer? <a href="register.jsp">Go to Register</a>
        </div>
        <div class="login-link">
            Is A Distributor? <a href="dlogin.jsp">Distributor Login</a>
         </div>
    </div>

    <%
        if (request.getMethod().equalsIgnoreCase("post")) {
            String consumerNo = request.getParameter("consumer_no");
            String name = request.getParameter("name");
            String password = request.getParameter("password");

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                // JDBC connection setup
                Class.forName("oracle.jdbc.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "sys as sysdba", "2003");

                // Query to check if the consumer number, name, and password match
                String sql = "SELECT * FROM Login WHERE consumer_no = ? AND name = ? AND password = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(consumerNo));
                pstmt.setString(2, name);
                pstmt.setString(3, password);

                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // On successful login
                    session.setAttribute("username", name); // Set session attribute
    %>
                    <script>
                        alert("Login successful! Welcome, <%= name %>.");
                        window.location.href = "home.jsp"; // Redirect to home page
                    </script>
    <%
                } else {
    %>
                    <script>alert("Invalid login details. Please try again.");</script>
    <%
                }
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
        }
    %>
</body>
</html>
