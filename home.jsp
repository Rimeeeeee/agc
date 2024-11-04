<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Anila Gas Company</title>
    <style>
        /* Body and Background */
        body {
            font-family: Arial, sans-serif;
            background-image: url('./homepg-bg.jpg'); /* Replace with your image URL */
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            height: 100vh;
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            color: #ffffff;
            animation: fadeIn 1.5s ease-in;
        }

        /* Backdrop Overlay */
        body::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7); /* Adjust opacity and color */
            z-index: 1;
        }

        /* Navbar */
        .navbar {
            position: fixed;
            top: 0;
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 30px;
            background: rgba(0, 0, 0, 0.8);
            z-index: 2;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
        }
        .mt-4{
            margin-top: 40px;
        }
        /* Circular logo with border */
        .navbar img {
            height: 50px;
            width: 50px;
            border-radius: 50%;
            border: 2px solid #ffffff;
            margin-right: 20px;
        }

        .navbar a {
            color: #ffffff;
            text-decoration: none;
            margin: 0 15px;
            font-size: 18px;
            font-weight: bold;
            transition: color 0.3s ease;
        }

        .navbar a:hover {
            color: #ff7eb3;
        }

        /* Main Content with Glassmorphism */
        .content {
            z-index: 2;
            text-align: center;
            padding: 30px;
            max-width: 600px;
            background: rgba(255, 255, 255, 0.2); /* Glass effect */
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.37);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }

        h1 {
            font-size: 2.5em;
            color: #ffffff;
            margin-bottom: 20px;
        }

        /* Button Styles */
        .btn {
            padding: 12px 25px;
            margin: 10px 10px;
            border: none;
            background: linear-gradient(135deg, #ff758c, #ff7eb3);
            color: #ffffff;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            text-decoration: none;
        }

        .btn:hover {
            background: linear-gradient(135deg, #ff7eb3, #ff758c);
        }

        /* Keyframes for Animation */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    </style>
    <script>
        // JavaScript function to log out by submitting a hidden form
        function logout() {
            document.getElementById('logoutForm').submit();
        }
    </script>
</head>
<body>
    <% 
        // Check if user is logged in by checking session attribute
        String username = (String) session.getAttribute("username");
        if (username == null) { 
            // If not logged in, redirect to login page
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <!-- Navbar -->
    <nav class="navbar">
        <div style="display: flex; align-items: center;">
            <img src="logo.jpg" alt="Anila Gas Company Logo"> <!-- Replace with your logo URL -->
            <a href="home.jsp">Home</a>
            <a href="previousconnection.jsp">Show Previous Transactions</a>
            <a href="tv.jsp">TV</a>
            <a href="registerCylinder.jsp">Create a Connection</a>
            <a href="requestCylinder.jsp">Request Cylinder</a>
            <a href="userdetails.jsp">Consumer Details</a>
            <a href="svtv.jsp">SV TV Details</a>
        </div>
        <div>
            <!-- Logout link triggers the logout function -->
            <a href="#" onclick="logout()" style="color: #ff7eb3;">Logout</a>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="content">
        <h1>Welcome to Anila Gas Company, <%= username %>!</h1>
        
        <!-- Action Buttons -->
         <div class="mt-4">
        <a href="registerCylinder.jsp" class="btn">Get a Connection</a>
        <a href="previousconnection.jsp" class="btn">Previous Connections</a></div>
    </div>

    <!-- Hidden form to terminate session on logout -->
    <form id="logoutForm" method="post" action="home.jsp" style="display: none;">
        <input type="hidden" name="logout" value="true">
    </form>

    <% 
        // Handle session termination if logout is requested
        if ("true".equals(request.getParameter("logout"))) {
            session.invalidate(); // Terminate session
            response.sendRedirect("login.jsp"); // Redirect to login page
        }
    %>
</body>
</html>